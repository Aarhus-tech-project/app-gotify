import { LoggerContext } from "../LoggerContext";
import DBContext from "../DBContext";
import UserContext from "../UserContext";

class PlaylistController {
	uc: UserContext;
	logger = new LoggerContext('PlaylistController');

	public constructor()
	{
		this.uc = UserContext.getInstance();
	}

	public async getPlaylists(): Promise<IPlaylist[]> {
		const user = this.uc.getUser();

		const sql = `
			SELECT id, name
			FROM playlist
			WHERE user_id = :userId
			OR id IN (SELECT playlist_id FROM playlist_user WHERE user_id = :userId)
		`

		const result = await DBContext.namedQuery(sql, { userId: user.id })
		const playlists = [
			{
			id: 'liked',
			name: 'Liked songs'
			}
		].concat(...result);

		return playlists;
	}

	public async getPlaylistById(playlistId: Id): Promise<IPlaylistWithMusic> {
		const user = this.uc.getUser();

		if (playlistId == 'liked') {
			const sql = `
				SELECT
					CONCAT(music.hash, '.', music.extension) AS file,
					music.hash,
					a.artist,
					a.name as album,
					music.song,
					music.track_number as trackNumber,
					a.cover_path as cover,
					CASE WHEN ls.user_id IS NOT NULL THEN TRUE ELSE FALSE END AS liked
				FROM music
				JOIN liked_songs ls ON music.hash = ls.song_hash
				JOIN album a ON music.album_id = a.id
				WHERE ls.user_id = :userId
				ORDER BY ls.created_at
			`

			const result = await DBContext.namedQuery(sql, { userId: user.id })

			return {
				id: 'liked',
				name: 'Liked songs',
				music: result
			}
		}

		let sql = `
			SELECT id, name
			FROM playlist
			WHERE id = :playlistId
			AND (
				user_id = :userId
				OR id IN (SELECT playlist_id FROM playlist_user WHERE user_id = :userId)
			)
		`

		const playlistResult = await DBContext.namedQuery(sql, { playlistId, userId: user.id })
		const playlistName = playlistResult[0].name

		sql = `
			SELECT
				CONCAT(music.hash, '.', music.extension) AS file,
				music.hash,
				a.artist,
				a.name as album,
				music.song,
				music.track_number as trackNumber,
				a.cover_path as cover,
				CASE WHEN ls.user_id IS NOT NULL THEN TRUE ELSE FALSE END AS liked
			FROM playlist_music pm
			JOIN music ON music.hash = pm.hash
			JOIN album a ON music.album_id = a.id
			LEFT JOIN liked_songs ls ON ls.song_hash = music.hash AND ls.user_id = :userId
			WHERE pm.playlist_id = :playlistId
			ORDER BY pm.created_at
		`

		const musicResult = await DBContext.namedQuery(sql, { playlistId, userId: user.id });

		return {
			id: playlistId,
			name: playlistName,
			music: musicResult

		} as IPlaylistWithMusic
	}

	public async createPlaylist(name: string): Promise<boolean> {
		const user = this.uc.getUser();

		const sql = `
			INSERT INTO playlist (user_id, \`name\`)
			VALUES (:userId, :name)
		`

		const result = await DBContext.namedExec(sql, { userId: user.id, name })
		return result.affectedRows == 1;
	}

	public async deletePlaylist(playlistId: Id): Promise<boolean> {
		const user = this.uc.getUser();

		const sql = `
			DELETE FROM playlist
			WHERE id = :playlistId
			AND user_id = :userId
		`

		const result = await DBContext.namedExec(sql, { playlistId, userId: user.id })
		return result.affectedRows == 1;
	}

	public async renamePlaylist(playlistId: Id, name: string): Promise<boolean> {
		if (!this.checkPlaylistOwnership(playlistId)) {
			return false;
		}

		const sql = `
			UPDATE playlist
			SET name = :name
			WHERE id = :playlistId
		`

		const result = await DBContext.namedExec(sql, { playlistId, name })
		return result.affectedRows == 1;
	}

	public async getCollabrationUsers(playlistId: Id): Promise<IUsers[]> {
		if (!this.checkPlaylistOwnership(playlistId)) {
			throw new Error("ACCESS_DENIED");
		}

		const sql = `
			SELECT u.id, u.username, u.picture
			FROM playlist_user pu
			JOIN user u ON u.id = pu.user_id
			WHERE pu.playlist_id = :playlistId
		`

		const result = await DBContext.namedQuery(sql, { playlistId })
		return result;
	}

	public async inviteUserToCollabration(playlistId: Id, username: string): Promise<boolean> {
		if (!this.checkPlaylistOwnership(playlistId)) {
			return false;
		}

		const sql = `
			INSERT INTO playlist_user (playlist_id, user_id)
			VALUES (:playlistId, (SELECT id FROM user WHERE username = :username))
		`

		const result = await DBContext.namedExec(sql, { playlistId, username })
		return result.affectedRows == 1;
	}

	public async removeUserFromCollabration(playlistId: Id, userId: Id): Promise<boolean> {
		const user = this.uc.getUser();
		if (!this.checkPlaylistOwnership(playlistId) || userId == user.id) {
			return false;
		}

		const sql = `
			DELETE FROM playlist_user
			WHERE playlist_id = :playlistId
			AND user_id = :userId
		`

		const result = await DBContext.namedExec(sql, { playlistId, userId })
		return result.affectedRows == 1;
	}

	public async addSongToPlaylist(playlistId: Id, hash: string): Promise<boolean> {
		const isOwner = this.checkPlaylistOwnership(playlistId);
		const isMember = this.checkPartialAccess(playlistId);

		if (!isOwner || !isMember) {
			throw new Error('PLAYLIST_NOT_FOUND');
		}

		const sql = `
			INSERT INTO playlist_music (playlist_id, hash)
			VALUES (:playlistId, :hash)
			ON DUPLICATE KEY UPDATE hash = hash;
		`

		const result = await DBContext.namedExec(sql, { playlistId, hash })
		return result.affectedRows == 1;
	}

	public async removeSongFromPlaylist(playlistId: Id, hash: string): Promise<boolean> {
		const isOwner = this.checkPlaylistOwnership(playlistId);
		const isMember = this.checkPartialAccess(playlistId);

		if (!isOwner || !isMember) {
			throw new Error('PLAYLIST_NOT_FOUND');
		}

		const sql = `
			DELETE FROM playlist_music
			WHERE playlist_id = :playlistId
			AND hash = :hash
		`

		const result = await DBContext.namedExec(sql, { playlistId, hash })
		return result.affectedRows == 1;
	}

	/* Private */

	private async checkPlaylistOwnership(playlistId: Id): Promise<boolean> {
		const user = this.uc.getUser();
		const sql = `
			SELECT 1
			FROM playlist
			WHERE id = :playlistId
			AND user_id = :userId
		`

		const result = await DBContext.namedQuery(sql, { playlistId, userId: user.id });
		if (result.length == 0) {
			return false;
		}

		return true;
	}

	private async checkPartialAccess(playlistId: Id): Promise<boolean> {
		const user = this.uc.getUser();
		const sql = `
			SELECT 1
			FROM playlist_user
			WHERE playlist_id = :playlistId
			AND user_id = :userId
		`

		const result = await DBContext.namedQuery(sql, { playlistId, userId: user.id });
		if (result.length == 0) {
			return false;
		}

		return true;
	}
}

export default PlaylistController;