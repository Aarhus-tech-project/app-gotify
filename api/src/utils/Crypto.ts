import bcrypt from "bcrypt";

export class Crypto {
	// number of rounds (higher = slower but more secure)
	private static saltRounds = 12;

	// hash a password
	static async hash(password: string): Promise<string> {
		return bcrypt.hash(password, this.saltRounds);
	}

	// compare a password with a stored hash
	static async compare(suppliedPassword: string, storedHash: string): Promise<boolean> {
		return bcrypt.compare(suppliedPassword, storedHash);
	}
}
