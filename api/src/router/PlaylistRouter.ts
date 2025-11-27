import { Router } from "express";
import { AuthMiddleware } from "../middleware/AuthMiddleware";
import * as routes from '../routes/PlaylistRoutes';

const router = Router();
router.use(AuthMiddleware)

/**
 * @openapi
 * /api/playlist:
 *   get:
 *     summary: Get user playlists
 *     description: Retrieves all playlists that belong to the authenticated user or are shared with them.
 *     tags:
 *       - Playlist
 *     responses:
 *       200:
 *         description: Successfully retrieved playlists
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: string
 *                     example: "123"
 *                   name:
 *                     type: string
 *                     example: "My Favorite Songs"
 *       404:
 *         description: Could not retrieve playlists (invalid user or unknown error)
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.get('/', routes.getPlaylists);

/**
 * @openapi
 * /api/playlist/{id}:
 *   get:
 *     summary: Get playlist details by ID
 *     description: Retrieves a playlist by its ID, including its track list in the order they were added. The playlist must belong to or be shared with the authenticated user.
 *     tags:
 *       - Playlist
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: The ID of the playlist to retrieve
 *         schema:
 *           type: string
 *           example: "123"
 *     responses:
 *       200:
 *         description: Successfully retrieved playlist with tracks
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                   example: "123"
 *                 name:
 *                   type: string
 *                   example: "Road Trip Mix"
 *                 music:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       file:
 *                         type: string
 *                         description: Full file name including extension
 *                         example: "abc123.mp3"
 *                       hash:
 *                         type: string
 *                         description: Unique hash of the song
 *                         example: "abc123"
 *                       artist:
 *                         type: string
 *                         example: "Fentanil"
 *                       album:
 *                         type: string
 *                         example: "Desmaterialização"
 *                       song:
 *                         type: string
 *                         example: "Desmaterialização - Iii"
 *                       trackNumber:
 *                         type: integer
 *                         example: 3
 *                       cover:
 *                         type: string
 *                         description: Path to album cover image
 *                         example: "/covers/Desmaterialização.jpg"
 *                       liked:
 *                         type: boolean
 *                         description: Whether the current user has liked the song
 *                         example: true
 *       404:
 *         description: Playlist not found or user does not have access
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.get('/:id', routes.getPlaylistById);

/**
 * @openapi
 * /api/playlist:
 *   post:
 *     summary: Create a new playlist
 *     description: Creates a new playlist for the authenticated user. Returns `true` if the playlist was successfully created.
 *     tags:
 *       - Playlist
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: The name of the new playlist
 *                 example: "Workout Mix"
 *     responses:
 *       200:
 *         description: Playlist successfully created
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Failed to create playlist (invalid input or unknown error)
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.post('/', routes.createPlaylist);

/**
 * @openapi
 * /api/playlist/{id}:
 *   delete:
 *     summary: Delete a playlist
 *     description: Deletes a playlist owned by the authenticated user. Returns `true` if the playlist was successfully deleted.
 *     tags:
 *       - Playlist
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: The ID of the playlist to delete
 *         schema:
 *           type: string
 *           example: "123"
 *     responses:
 *       200:
 *         description: Playlist successfully deleted
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Playlist not found or user not authorized to delete it
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.delete('/:id', routes.deletePlaylist);

/**
 * @openapi
 * /api/playlist/{id}:
 *   put:
 *     summary: Rename a playlist
 *     description: Updates the name of a playlist owned by the authenticated user. Returns `true` if the rename was successful.
 *     tags:
 *       - Playlist
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: The ID of the playlist to rename
 *         schema:
 *           type: string
 *           example: "123"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: The new name for the playlist
 *                 example: "Chill Vibes"
 *     responses:
 *       200:
 *         description: Playlist successfully renamed
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Playlist not found, user not authorized, or unknown error
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.put('/:id', routes.renamePlaylist);

/**
 * @openapi
 * /api/playlist/collabration/{playlistId}/users:
 *   get:
 *     summary: Get users in a playlist collaboration
 *     description: Retrieves the list of users who have access to collaborate on a specific playlist. The requesting user must own the playlist.
 *     tags:
 *       - Playlist
 *     parameters:
 *       - name: playlistId
 *         in: path
 *         required: true
 *         description: The ID of the playlist
 *         schema:
 *           type: string
 *           example: "123"
 *     responses:
 *       200:
 *         description: Successfully retrieved collaboration users
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: string
 *                     example: "456"
 *                   username:
 *                     type: string
 *                     example: "alice"
 *       404:
 *         description: Playlist not found, access denied, or unknown error
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [ACCESS_DENIED, UNKNOWN_ERROR]
 *               example: ACCESS_DENIED
 *       500:
 *         description: Internal server error
 */
router.get('/collabration/:playlistId/users', routes.getCollabrationUsers);

/**
 * @openapi
 * /api/playlist/collabration/{playlistId}/invite:
 *   post:
 *     summary: Invite a user to collaborate on a playlist
 *     description: Adds a user to a playlist's collaboration list. The requesting user must own the playlist. Returns `true` if the invitation was successful.
 *     tags:
 *       - Playlist
 *     parameters:
 *       - name: playlistId
 *         in: path
 *         required: true
 *         description: The ID of the playlist
 *         schema:
 *           type: string
 *           example: "123"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *             properties:
 *               username:
 *                 type: string
 *                 description: The username of the user to invite
 *                 example: "alice"
 *     responses:
 *       200:
 *         description: User successfully invited
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Failed to invite user (playlist not owned, user not found, or unknown error)
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.post('/collabration/:playlistId/invite', routes.inviteUserToCollabration);

/**
 * @openapi
 * /api/playlist/collabration/{playlistId}/remove:
 *   post:
 *     summary: Remove a user from a playlist collaboration
 *     description: Removes a user from a playlist's collaboration list. The requesting user must own the playlist. Returns `true` if the removal was successful.
 *     tags:
 *       - Playlist
 *     parameters:
 *       - name: playlistId
 *         in: path
 *         required: true
 *         description: The ID of the playlist
 *         schema:
 *           type: string
 *           example: "123"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *             properties:
 *               userId:
 *                 type: string
 *                 description: The ID of the user to remove
 *                 example: "456"
 *     responses:
 *       200:
 *         description: User successfully removed from collaboration
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Failed to remove user (playlist not owned or unknown error)
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.post('/collabration/:playlistId/remove', routes.removeUserFromCollabration);

/**
 * @openapi
 * /api/playlist/add/{id}:
 *   patch:
 *     summary: Add a song to a playlist
 *     description: Adds a song to the specified playlist. The user must be the owner or have partial access to the playlist. Returns `true` if the song was successfully added.
 *     tags:
 *       - Playlist
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: The ID of the playlist
 *         schema:
 *           type: string
 *           example: "123"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - hash
 *             properties:
 *               hash:
 *                 type: string
 *                 description: The hash of the song to add
 *                 example: "abc123def456"
 *     responses:
 *       200:
 *         description: Song successfully added to playlist
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Playlist not found or user does not have access
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [PLAYLIST_NOT_FOUND, UNKNOWN_ERROR]
 *               example: PLAYLIST_NOT_FOUND
 *       500:
 *         description: Internal server error
 */
router.patch('/add/:id', routes.addSongToPlaylist);

/**
 * @openapi
 * /api/playlist/remove/{id}:
 *   patch:
 *     summary: Remove a song from a playlist
 *     description: Removes a song from the specified playlist. The user must be the owner or have partial access. Returns `true` if the song was successfully removed.
 *     tags:
 *       - Playlist
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: The ID of the playlist
 *         schema:
 *           type: string
 *           example: "123"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - hash
 *             properties:
 *               hash:
 *                 type: string
 *                 description: The hash of the song to remove
 *                 example: "abc123def456"
 *     responses:
 *       200:
 *         description: Song successfully removed from playlist
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Playlist not found or user does not have access
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [PLAYLIST_NOT_FOUND, UNKNOWN_ERROR]
 *               example: PLAYLIST_NOT_FOUND
 *       500:
 *         description: Internal server error
 */
router.patch('/remove/:id', routes.removeSongFromPlaylist);

export default router;