import express from "express";
import swaggerUi from 'swagger-ui-express';
import UserRouter from "./router/UserRouter";
import PlaylistRouter from './router/PlaylistRouter';
import MusicRouter from './router/MusicRouter';
import { RequestLogger } from "./middleware/RequestLogger";
import { swaggerSpec } from './swagger/swagger.config';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(RequestLogger)

app.use('/user', UserRouter);
app.use('/playlist', PlaylistRouter)
app.use('/music', MusicRouter)

app.use('/swagger', swaggerUi.serve, swaggerUi.setup(swaggerSpec));


app.get("/", (_req, res) => {
	res.send("🚀 Hello from Express + TypeScript + Hot Reload!");
});

app.listen(PORT, () => {
	console.log(`✅ Server running at http://localhost:${PORT}`);
});
