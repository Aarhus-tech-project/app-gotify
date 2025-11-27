import fs from "fs";
import path from "path";

type LogLevel = "INFO" | "WARN" | "ERROR" | "DEBUG";

export class LoggerContext {
	private context: string;
	private logFilePath: string;

	constructor(context: string = "App") {
		this.context = context;

		const logsDir = path.resolve(__dirname, "logs");
		if (!fs.existsSync(logsDir)) {
			fs.mkdirSync(logsDir, { recursive: true });
		}

		const dateStr = new Date().toISOString().split("T")[0];
		this.logFilePath = path.join(logsDir, `${dateStr}.log`);
	}

	private formatMessage(level: LogLevel, func: string, ...args: any[]): string {
		const timestamp = new Date().toISOString();
		const message = args
			.map((arg) =>
				typeof arg === "object"
					? JSON.stringify(arg, null, 2)
					: String(arg)
			)
			.join(" ");
		return `[${timestamp}] [${level}] [${this.context}::${func}] ${message}`;
	}

	private writeToFile(message: string) {
		fs.appendFileSync(this.logFilePath, message + "\n", "utf8");
	}

	private log(level: LogLevel, func: string, ...args: any[]) {
		const formatted = this.formatMessage(level, func, ...args);

		switch (level) {
			case "INFO":
				console.log(formatted);
				break;
			case "WARN":
				console.warn(formatted);
				break;
			case "ERROR":
				console.error(formatted);
				break;
			case "DEBUG":
				console.debug(formatted);
				break;
		}

		this.writeToFile(formatted);
	}

	info = (func: string, ...args: any[]) => this.log("INFO", func, ...args);
	warn = (func: string, ...args: any[]) => this.log("WARN", func, ...args);
	error = (func: string, ...args: any[]) => this.log("ERROR", func, ...args);
	debug = (func: string, ...args: any[]) => this.log("DEBUG", func, ...args);
}