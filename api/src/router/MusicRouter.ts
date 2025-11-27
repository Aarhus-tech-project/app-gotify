import { Router } from "express";
import { AuthMiddleware } from "../middleware/AuthMiddleware";
import * as routes from '../routes/MusicRoutes';

const router = Router();
router.use(AuthMiddleware)

/**
 * @openapi
 * /api/music/search:
 *   post:
 *     summary: Search for songs or albums
 *     description: Searches the music database by query and optional filter (either `song` or `album`). Returns a list of matching music items ordered by relevance.
 *     tags:
 *       - Music
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - query
 *             properties:
 *               query:
 *                 type: string
 *                 description: Search text for songs, albums, or artists.
 *                 example: "Coldplay"
 *               filter:
 *                 type: string
 *                 enum: [song, album]
 *                 default: song
 *                 description: Type of search filter to apply.
 *     responses:
 *       200:
 *         description: Successfully retrieved search results
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   hash:
 *                     type: string
 *                     example: "abc123xyz"
 *                   file:
 *                     type: string
 *                     example: "abc123xyz.mp3"
 *                   artist:
 *                     type: string
 *                     example: "Fentanil"
 *                   album:
 *                     type: string
 *                     example: "Desmaterialização"
 *                   song:
 *                     type: string
 *                     example: "Desmaterialização - Iii"
 *                   trackNumber:
 *                     type: integer
 *                     example: 3
 *                   cover:
 *                     type: string
 *                     example: "/covers/Desmaterialização.jpg"
 *                   liked:
 *                     type: boolean
 *                     example: true
 *                   relevance:
 *                     type: integer
 *                     example: 10
 *       404:
 *         description: Search failed or unknown error
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [UNKNOWN_ERROR]
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.post('/search', routes.search);

/**
 * @openapi
 * /api/music/{hash}:
 *   get:
 *     summary: Get detailed information about a music track
 *     description: Retrieves metadata for a single music track by its hash. Includes file info, album, artist, and liked status.
 *     tags:
 *       - Music
 *     parameters:
 *       - in: path
 *         name: hash
 *         required: true
 *         schema:
 *           type: string
 *         description: Unique hash identifier of the music file.
 *         example: "a8f3b1c2d9"
 *     responses:
 *       200:
 *         description: Successfully retrieved music information
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 file:
 *                   type: string
 *                   example: "a8f3b1c2d9.mp3"
 *                 hash:
 *                   type: string
 *                   example: "a8f3b1c2d9"
 *                 artist:
 *                   type: string
 *                   example: "Fentanil"
 *                 album:
 *                   type: string
 *                   example: "Desmaterialização"
 *                 song:
 *                   type: string
 *                   example: "Desmaterialização - Iii"
 *                 trackNumber:
 *                   type: integer
 *                   example: 7
 *                 cover:
 *                   type: string
 *                   example: "/covers/Desmaterialização.jpg"
 *                 liked:
 *                   type: boolean
 *                   example: true
 *       404:
 *         description: No music found or unknown error occurred
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [NO_AVAILABLE_MUSIC, UNKNOWN_ERROR]
 *               example: NO_AVAILABLE_MUSIC
 *       500:
 *         description: Internal server error
 */
router.get('/:hash', routes.getMusic);

/**
 * @openapi
 * /api/music/album/{id}:
 *   get:
 *     summary: Get album details and track list
 *     description: Retrieves metadata for an album and all its songs, ordered by track number.
 *     tags:
 *       - Music
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The album's unique ID.
 *         example: "42"
 *     responses:
 *       200:
 *         description: Successfully retrieved album information
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 albumId:
 *                   type: string
 *                   example: "42"
 *                 album:
 *                   type: string
 *                   example: "Desmaterialização"
 *                 artist:
 *                   type: string
 *                   example: "Fentanil"
 *                 cover:
 *                   type: string
 *                   example: "/covers/Desmaterialização.jpg"
 *                 songs:
 *                   type: array
 *                   description: List of songs in the album, ordered by track number.
 *                   items:
 *                     type: object
 *                     properties:
 *                       file:
 *                         type: string
 *                         example: "a8f3b1c2d9.mp3"
 *                       hash:
 *                         type: string
 *                         example: "a8f3b1c2d9"
 *                       song:
 *                         type: string
 *                         example: "Desmaterialização - Iii"
 *                       trackNumber:
 *                         type: integer
 *                         example: 7
 *                       cover:
 *                         type: string
 *                         example: "/covers/Desmaterialização.jpg"
 *                       liked:
 *                         type: boolean
 *                         example: true
 *       404:
 *         description: Album not found or unknown error occurred
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [ALBUM_NOT_FOUND, UNKNOWN_ERROR]
 *               example: ALBUM_NOT_FOUND
 *       500:
 *         description: Internal server error
 */
router.get('/album/:id', routes.getAlbum);

/**
 * @openapi
 * /api/music/like/{hash}:
 *   post:
 *     summary: Toggle like/unlike for a song
 *     description: Likes a song if it is not already liked, or unlikes it if it is already liked by the authenticated user. Returns `true` if the operation was successful.
 *     tags:
 *       - Music
 *     parameters:
 *       - in: path
 *         name: hash
 *         required: true
 *         schema:
 *           type: string
 *         description: The unique hash of the song to like or unlike.
 *         example: "a8f3b1c2d9"
 *     responses:
 *       200:
 *         description: Successfully liked or unliked the song
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Song not found or unknown error
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [UNKNOWN_ERROR]
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.post('/like/:hash', routes.likeSong);

export default router;