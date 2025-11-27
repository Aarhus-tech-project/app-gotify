import { Request, Response, NextFunction } from "express";
import { verifyToken } from "../utils/JWT";
import UserContext, { IUserContext } from "../UserContext";

export const AuthMiddleware = (req: Request, res: Response, next: NextFunction) => {
	const authHeader = req.headers.authorization;
	if (!authHeader || !authHeader.startsWith("Bearer ")) {
		return res.status(401).json({ message: "Missing or invalid Authorization header" });
	}

	const token = authHeader.split(" ")[1];
	const decoded = verifyToken(token);

	if (!decoded) {
		return res.status(403).json({ message: "Invalid or expired token" });
	}

	// Optionally attach the decoded payload to the request object
	(req as any).user = decoded;
	const uc = UserContext.getInstance()
	uc.setUser(decoded as IUserContext)
	next();
};

export const GetAuthInformation = (req: Request, res: Response) => {
	const authHeader = req.headers.authorization;
	if (!authHeader || !authHeader.startsWith("Bearer ")) {
		res.status(401).json({ message: "Missing or invalid Authorization header" });
		return false;
	}

	const token = authHeader.split(" ")[1];
	const decoded = verifyToken(token);

	if (!decoded) {
		res.status(403).json({ message: "Invalid or expired token" });
		return false;
	}

	return decoded as IUserContext;
}
