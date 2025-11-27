import jwt, { JsonWebTokenError, TokenExpiredError } from "jsonwebtoken";
import dotenv from "dotenv";
import { LoggerContext } from "../LoggerContext";

dotenv.config();

const logger = new LoggerContext('Utils::JWT');

const JWT_DEFAULT_EXPIRES = 365 * 24 * 60 * 60; // 1 year
const JWT_SECRET = process.env.JWT_SECRET || "very_secret_key";
const JWT_EXPIRES = parseInt(process.env.JWT_EXPIRES_IN ?? JWT_DEFAULT_EXPIRES.toString()) || JWT_DEFAULT_EXPIRES;

export const generateToken = ( payload: object): string => {
	return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES });
};

export const verifyToken = (token: string) => {
	try {
		return jwt.verify(token, JWT_SECRET);
	} catch (err) {
		return err;
	}
};

export const checkTokenForLogin = (token: string) => {
	try {
		if (!token) {
			logger.error('checkTokenForLogin', 'No token provided');
			throw new Error("INVALID_TOKEN");
		}

		logger.info('checkTokenForLogin', `Attempting to verify using token:`, token);
		const decoded = jwt.verify(token, JWT_SECRET);

		if (typeof decoded == 'string') {
			throw new Error("UNKNOWN_ERROR");
		}

		if (decoded.exp) {
			logger.info('checkTokenForLogin', `Successfully verified token: ${token}, for user:`, decoded.username);
			return true;
		}

		logger.info('checkTokenForLogin', `Could not verified token: `, token);
		return false;
	} catch (err) {
		let errMsg = 'UNKNOWN_ERROR';

		if (err instanceof TokenExpiredError) errMsg = 'TOKEN_EXPIRED';
		if (err instanceof JsonWebTokenError) errMsg = 'INVALID_TOKEN';

		throw new Error(errMsg);
	}
}
