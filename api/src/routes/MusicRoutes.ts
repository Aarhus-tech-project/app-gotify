import { Request, Response } from "express";
import { LoggerContext } from "../LoggerContext";
import MusicController from "../controller/MusicController";

const logger = new LoggerContext('MusicRoutes');

const validErrors = ['UNKNOWN_ERROR', 'NO_AVAILABLE_MUSIC', 'ALBUM_NOT_FOUND']

export const search = async (req: Request, res: Response) => {
	try {
		const { query, filter: filter = 'song' } = req.body;
		const controller = new MusicController();

		const result = await controller.search(query, filter);
		res.send(result);
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('Search', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const getMusic = async (req: Request<{hash: string}>, res: Response) => {
	try {
		const controller = new MusicController();
		const { hash } = req.params;

		const result = await controller.getMusic(hash);
		res.send(result);
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('GetMusic', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const getAlbum = async (req: Request<{id: Id}>, res: Response) => {
	try {
		const controller = new MusicController();
		const { id } = req.params;

		const result = await controller.getAlbum(id);
		res.send(result);
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('GetAlbum', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const likeSong = async (req: Request<{hash: string}>, res: Response) => {
	try {
		const controller = new MusicController();
		const { hash } = req.params;

		const isLiked = await controller.checkLiked(hash);
		const result = isLiked ? await controller.unlike(hash) : await controller.like(hash);

		res.send(result);
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('likeSong', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}
