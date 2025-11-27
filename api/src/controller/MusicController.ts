import { LoggerContext } from "../LoggerContext";
import DBContext from "../DBContext";
import UserContext from "../UserContext";

class MusicController {
	uc: UserContext;
	logger = new LoggerContext('MusicController');

	public constructor() {
		this.uc = UserContext.getInstance();
	}

	public async search(query: string, filter: 'album' | 'song' | null = 'song'): Promise<Array<IMusic & { relevance: number }>> {
		const user = this.uc.getUser();
		
		const sql = `
			SELECT
				music.hash,
				CONCAT(music.hash, '.', music.extension) as file,
				a.artist,
				a.name as album,
				music.song,
				music.track_number as trackNumber,
				a.cover_path as cover,
				CASE WHEN ls.user_id IS NOT NULL THEN TRUE ELSE FALSE END AS liked,
				(
					(CASE WHEN a.artist = :search THEN 5 ELSE 0 END) +
					(CASE WHEN music.song = :search THEN 5 ELSE 0 END) +
					(CASE WHEN a.name = :search THEN 3 ELSE 0 END) +
					(CASE WHEN a.artist LIKE CONCAT('%', :search, '%') THEN 2 ELSE 0 END) +
					(CASE WHEN music.song LIKE CONCAT('%', :search, '%') THEN 2 ELSE 0 END) +
					(CASE WHEN a.name LIKE CONCAT('%', :search, '%') THEN 1 ELSE 0 END)
				) AS relevance
			FROM music
			JOIN album a ON music.album_id = a.id
			LEFT JOIN liked_songs ls ON ls.song_hash = music.hash AND ls.user_id = :userId
			WHERE
				a.artist LIKE CONCAT('%', :search, '%')
				OR a.name LIKE CONCAT('%', :search, '%')
				OR music.song LIKE CONCAT('%', :search, '%')
			ORDER BY relevance DESC, a.artist, music.song
			LIMIT 15
		`

		const result = await DBContext.namedQuery(sql, { search: query, userId: user.id })
		return result;
	}

	public async getMusic(hash: string): Promise<IMusic[]> {
		const user = this.uc.getUser();

		const sql = `
			SELECT
				CONCAT(hash, '.', extension) as file,
				music.hash,
				a.artist,
				a.name as album,
				music.song,
				music.track_number as trackNumber,
				a.cover_path as cover,
				CASE WHEN ls.user_id IS NOT NULL THEN TRUE ELSE FALSE END AS liked
			FROM music
			JOIN album a on music.album_id = a.id
			LEFT JOIN liked_songs ls ON ls.song_hash = music.hash AND ls.user_id = :userId
			WHERE music.hash = :hash;
		`

		const result = await DBContext.namedQuery(sql, { hash, userId: user.id });

		if (result.length === 0) {
			throw new Error('NO_AVAILABLE_MUSIC');
		}

		return result[0]
	}

	public async getAlbum(id: Id): Promise<IAlbum> {
		const user = this.uc.getUser()

		const sql = `
			SELECT
				CONCAT(hash, '.', extension) as file,
				music.hash,
				a.artist,
				a.name as album,
				music.song,
				music.track_number as trackNumber,
				a.cover_path as cover,
				CASE WHEN ls.user_id IS NOT NULL THEN TRUE ELSE FALSE END AS liked
			FROM music
			JOIN album a on music.album_id = a.id
			LEFT JOIN liked_songs ls ON ls.song_hash = music.hash AND ls.user_id = :userId
			WHERE a.id = :id
			ORDER BY music.track_number ASC
		`

		const result = await DBContext.namedQuery(sql, { id, userId: user.id });

		if (result.length === 0) {
			throw new Error('ALBUM_NOT_FOUND');
		}

		return {
			albumId: id,
			album: result[0].album,
			cover: result[0].cover,
			artist: result[0].artist,
			songs: result
		}
	}

	public async like(hash: string): Promise<boolean> {
		const user = this.uc.getUser();

		const sql = `
			INSERT INTO liked_songs (user_id, song_hash)
			VALUES (:userId, :songHash)
		`

		const result = await DBContext.namedExec(sql, { userId: user.id, songHash: hash });
		return result.affectedRows > 0;
	}

	public async unlike(hash: string): Promise<boolean> {
		const user = this.uc.getUser();

		const sql = `
			DELETE FROM liked_songs
			WHERE user_id = :userId AND song_hash = :songHash
		`

		const result = await DBContext.namedExec(sql, { userId: user.id, songHash: hash });
		return result.affectedRows > 0;
	}

	public async checkLiked(hash: string): Promise<boolean> {
		const user = this.uc.getUser();

		const sql = `
			SELECT COUNT(*) as count
			FROM liked_songs
			WHERE user_id = :userId AND song_hash = :songHash
		`

		const result = await DBContext.namedQuery(sql, { userId: user.id, songHash: hash });
		return result[0].count > 0;
	}
}

export default MusicController;