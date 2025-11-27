import fs from "fs";
import { LoggerContext } from "../LoggerContext";
import { Crypto } from "../utils/Crypto";
import DBContext from "../DBContext";
import * as JWT from "../utils/JWT";
import UserContext from "../UserContext";

class UserController {
	static logger = new LoggerContext('UserController');

    public static async login(username: string, password: string): Promise<{ token: string, picture: string }> {
		this.logger.info('login', `Attempting login with username: ${username}`);

		const sql = `
			SELECT *
			FROM user
			WHERE username = :username
			AND active = 1
		`

		const result = await DBContext.namedQuery(sql, { username });

		if (result.length == 1) {
			const user = result[0];
			const hashedPassword = user.password;
			const isValid = await Crypto.compare(password, hashedPassword);

			if (isValid) {
				delete user.password;
				this.logger.info("Login", `Successfully logged into user with username: ${username}`);
				const token = JWT.generateToken(user)
				return {
					token,
					picture: user.picture
				}
			}
		}

		throw new Error('USER_NOT_FOUND');
	}

	public static async register(username: string, password: string): Promise<boolean> {
		this.logger.info('register', `Attempting register with username: ${username}`);

		if (!username || !password) {
			throw new Error('USERNAME_OR_PASSWORD_MISSING');
		}

		const usernameAvailable = await this.checkUsernameAvailablity(username);
		if (!usernameAvailable) {
			throw new Error('USERNAME_NOT_AVAILABLE');
		}

		const hashedPassword = await Crypto.hash(password);

		const sql = `
			INSERT INTO user (username, password)
			VALUES (:username, :password)
		`

		const result = await DBContext.namedExec(sql, { username, password: hashedPassword });

		if (result.affectedRows > 0) {
			this.logger.info('register', `Successfully registered with username: ${username}`);
			return true;
		} else {
			this.logger.info('register', `Could not register with username: ${username}`);
			return false;
		}
	}

	public static async checkToken(token: string): Promise<boolean> {
		const result = JWT.checkTokenForLogin(token);
		return result;
	}

	public static async updateUser(userId: Id, username: string): Promise<boolean> {
		const uc = UserContext.getInstance();
		const user = uc.getUser();

		const sql = `
			UPDATE user
			SET username = :username
			WHERE id = :id
		`

		const result = await DBContext.namedExec(sql, { id: userId, username });

		return result.affectedRows == 1;
	}

	public static async updateUserPicture(userId: Id, file: Express.Multer.File | undefined): Promise<{ success: boolean; path: string }> {
		if (!file) {
			throw new Error('NO_IMAGE_SUPPLIED');
		}

		const path = `/var/www/user_pictures/${file.filename}`;
		const fileExists = fs.existsSync(path)

		if (fileExists) {
			const sql = `
				UPDATE user
				SET picture = :picture
				WHERE id = :id
			`

			const result = await DBContext.namedExec(sql, { picture: file.filename, id: userId })
			if(result.affectedRows) {
				return {
					success: fileExists,
					path: file.filename
				}
			}
		}
		
		if (fileExists) {
			fs.rmSync(path);
		}

		return {
			success: false,
			path: 'error'
		}
	}

	public static async deleteUser(userId: Id): Promise<boolean> {
		const sql = `
			UPDATE user
			SET active = 0
			WHERE id = :id
		`

		const result = await DBContext.namedExec(sql, { id: userId });

		return result.affectedRows == 1;
	}

	/* Private */

	private static async checkUsernameAvailablity(username: string): Promise<boolean> {
		const sql = `
			SELECT COUNT(*) as count
			FROM user
			WHERE username = :username
		`

		const result = await DBContext.namedQuery(sql, { username });
		const count = result[0].count
		
		return count <= 0;
	}
}

export default UserController;