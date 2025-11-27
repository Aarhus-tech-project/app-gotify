import { Request, Response } from "express";
import { LoggerContext } from "../LoggerContext";
import PlaylistController from "../controller/PlaylistController";

const logger = new LoggerContext('UserRoutes');

const validErrors = ['PLAYLIST_NOT_FOUND', 'ACCESS_DENIED']


// Get all playlists from user
export const getPlaylists = async (req: Request, res: Response) => {
	try {
		const controller = new PlaylistController();
		const result = await controller.getPlaylists();
		res.send(result)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('getPlaylists', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

// Get playlist by id (this includes track list of playlist in ADDED BY order)
export const getPlaylistById = async (req: Request<{id: Id}>, res: Response) => {
	try {
		const controller = new PlaylistController();
		const playlistId = req.params.id;

		const result = await controller.getPlaylistById(playlistId);
		res.send(result)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('getPlaylistById', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const createPlaylist = async (req: Request, res: Response) => {
	try {
		const controller = new PlaylistController();
		const body = req.body as { name: string };

		const result = await controller.createPlaylist(body.name);
		res.send(result)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('createPlaylist', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const deletePlaylist = async (req: Request<{id: Id}>, res: Response) => {
	try {
		const controller = new PlaylistController();
		const playlistId = req.params.id;

		const result = await controller.deletePlaylist(playlistId);
		res.send(result)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('deletePlaylist', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const renamePlaylist = async (req: Request<{id: Id}>, res: Response) => {
	try {
		const controller = new PlaylistController();
		const playlistId = req.params.id;
		const body = req.body as { name: string };

		const result = await controller.renamePlaylist(playlistId, body.name);
		res.send(result);
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('renamePlaylist', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const getCollabrationUsers = async (req: Request<{playlistId: Id}>, res: Response) => {
	try {
		const controller = new PlaylistController();
		const playlistId = req.params.playlistId;

		const result = await controller.getCollabrationUsers(playlistId);
		res.send(result);
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('getCollabrationUsers', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const inviteUserToCollabration = async (req: Request<{playlistId: Id}>, res: Response) => {
	try {
		const controller = new PlaylistController();

		const { username } = req.body as { username: string };
		const { playlistId } = req.params

		const result = await controller.inviteUserToCollabration(playlistId, username);
		res.send(result);
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('inviteUserToCollabration', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const removeUserFromCollabration = async (req: Request<{playlistId: Id}>, res: Response) => {
	try {
		const controller = new PlaylistController();

		const { userId } = req.body as { userId: Id }
		const { playlistId } = req.params

		const result = await controller.removeUserFromCollabration(playlistId, userId);
		res.send(result);
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('removeUserFromCollabration', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const addSongToPlaylist = async (req: Request<{id: Id}>, res: Response) => {
	try {
		const controller = new PlaylistController()
		const playlistId = req.params.id;
		const songHash = req.body.hash;

		const result = controller.addSongToPlaylist(playlistId, songHash)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('patchPlaylistAdd', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const removeSongFromPlaylist = async (req: Request<{id: Id}>, res: Response) => {
	try {
		const controller = new PlaylistController()
		const playlistId = req.params.id;
		const songHash = req.body.hash;

		const result = controller.removeSongFromPlaylist(playlistId, songHash);
		res.send(result)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('patchPlaylistRemove', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}