import { LoggerContext } from "./LoggerContext";

export interface IUserContext {
	id: Id;
	username: string;
}

class UserContext {
	private static instance: UserContext;
	private user: IUserContext | null = null;
	private logger = new LoggerContext("UserContext");

	private constructor() {
		// Private constructor to prevent manual instantiation
	}

	public static getInstance(): UserContext {
		if (!UserContext.instance) {
			UserContext.instance = new UserContext();
		}
		return UserContext.instance;
	}

	public setUser(user: IUserContext): void {
		this.user = user;
	}

	public async setUserFromId(id: Id) {
		const db = (await import("./DBContext")).default;

		const sql = `SELECT username FROM user WHERE id = :userId`
		const result = await db.namedQuery<{ username: string }>(sql, { userId: id });

		if (result.length === 0) {
			this.logger.error('setUserFromId', `User with id ${id} not found`);
			throw new Error("User not found");
		}

		this.user = {
			id,
			username: result[0].username
		}
	}

	public getUser(): IUserContext {
		return this.user ?? { id: 0, username: '' };
	}

	public clear(): void {
		this.user = null;
	}
}

export default UserContext;
