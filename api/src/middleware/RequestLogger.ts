import { Request, Response, NextFunction } from "express";
import { verifyToken } from "../utils/JWT";
import { LoggerContext } from "../LoggerContext";

const logger = new LoggerContext('Middleware');

// NOTE TO SELF: DONT LOG BODY IF BODY IS EMPTY
export const RequestLogger = (req: Request, res: Response, next: NextFunction) => {
	// Log the request details
	const method = req.method;
	const path = req.path;
	const body = req.body;

	if (path.includes('/swagger')) {
		next();
		return;
	}

	let str = `Request sent to ${method.toUpperCase()} ${path}`;

	const authHeader = req.headers.authorization;
	if (authHeader && authHeader.startsWith("Bearer ")) {

		const token = authHeader.split(" ")[1];
		const decoded = verifyToken(token);
		
		if (decoded) {
			const user = (decoded as any);
			str = str.concat(` | With user ${user.username} (${user.id})`)
		}
	}

	if (body) {
		str = str.concat(' | With body');
		logger.info('RequestLogger', str, body);
		next();
		return;
	}


	logger.info('RequestLogger', str)
	next();
};