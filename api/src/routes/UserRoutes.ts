import { Request, Response } from "express";
import { LoggerContext } from "../LoggerContext";
import UserController from "../controller/UserController";
import { GetAuthInformation } from "../middleware/AuthMiddleware";
import UserContext from "../UserContext";

const logger = new LoggerContext('UserRoutes');

const validErrors = ['USERNAME_NOT_AVAILABLE', 'USER_NOT_FOUND', 'USERNAME_OR_PASSWORD_MISSING', 'TOKEN_EXPIRED', 'INVALID_TOKEN', 'UNKNOWN_ERROR', 'NO_IMAGE_SUPPLIED']

export const login = async (req: Request, res: Response) => {
	try {
		const response = await UserController.login(req.body.username, req.body.password);
		res.send(response)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('login', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');

	}
}

export const register = async (req: Request, res: Response) => {
	try {
		const response = await UserController.register(req.body.username, req.body.password);
		res.send(response) 
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('Register', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

// user check token validity
export const checkToken = async (req: Request, res: Response) => {
	try {
		const { token } = req.body;
		const response = await UserController.checkToken(token);
		res.send(response)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('checkToken', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const updateUser = async (req: Request, res: Response) => {
	try {
		const uc = UserContext.getInstance();
		const user = uc.getUser();

		if (!user) {
			return;
		}

		const { username } = req.body;

		const response = await UserController.updateUser(user.id, username);
		res.send(response)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('checkToken', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const updateUserPicture = async (req: Request, res: Response) => {
	try {
		const uc = UserContext.getInstance();
		const user = uc.getUser();

		if (!user) {
			return;
		}

		const response = await UserController.updateUserPicture(user.id, req.file);
		res.send(response)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('checkToken', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}

export const deleteUser = async (req: Request, res: Response) => {
	try {
		const uc = UserContext.getInstance();
		const user = uc.getUser();

		if (!user) {
			return;
		}

		const response = await UserController.deleteUser(user.id);
		res.send(response)
	} catch (error) {
		const errorMessage = error instanceof Error ? error.message : String(error);
		logger.error('checkToken', errorMessage)
		res.status(404).send(validErrors.includes(errorMessage) ? errorMessage : 'UNKNOWN_ERROR');
	}
}
