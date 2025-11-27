import { Router } from "express";
import { upload } from "../middleware/UploaderMiddleware";
import * as routes from '../routes/UserRoutes';
import { AuthMiddleware } from "../middleware/AuthMiddleware";

const router = Router();

/**
 * @openapi
 * /api/user/login:
 *   post:
 *     summary: User login
 *     description: Authenticates a user with username and password. Returns a login response including a token and the user's profile picture.
 *     tags:
 *       - User
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *                 example: johndoe
 *               password:
 *                 type: string
 *                 example: secret123
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token:
 *                   type: string
 *                   description: JWT or session token
 *                   example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *                 picture:
 *                   type: string
 *                   description: Filename of the user's profile picture
 *                   example: "user123.png"
 *       404:
 *         description: Login failed (user not found or invalid credentials)
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: USER_NOT_FOUND
 *       500:
 *         description: Internal server error
 */
router.post('/login', routes.login);

/**
 * @openapi
 * /api/user/register:
 *   post:
 *     summary: Register a new user
 *     description: Creates a new user account with the provided username and password. Returns `true` on success or throws an error on failure.
 *     tags:
 *       - User
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *                 example: johndoe
 *               password:
 *                 type: string
 *                 example: secret123
 *     responses:
 *       200:
 *         description: User successfully registered
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Registration failed (validation or unknown error)
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               example: USER_ALREADY_EXISTS
 *       500:
 *         description: Internal server error
 */
router.post('/register', routes.register);

/**
 * @openapi
 * /api/user/check-token:
 *   post:
 *     summary: Check token validity
 *     description: Verifies whether a provided authentication token is valid or expired. Returns `true` if valid, `false` if invalid, or throws an error if the token is missing, expired, or invalid.
 *     tags:
 *       - User
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *             properties:
 *               token:
 *                 type: string
 *                 example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *     responses:
 *       200:
 *         description: Token check successful
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: Token validation failed (invalid or expired token)
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [INVALID_TOKEN, TOKEN_EXPIRED, UNKNOWN_ERROR]
 *               example: INVALID_TOKEN
 *       500:
 *         description: Internal server error
 */
router.post('/check-token', routes.checkToken);

/**
 * @openapi
 * /api/user:
 *   put:
 *     summary: Update the current user's username
 *     description: Updates the authenticated user's username. Returns `true` if the update was successful.
 *     tags:
 *       - User
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
 *                 description: The new username to set for the user
 *                 example: "new_username123"
 *     responses:
 *       200:
 *         description: Username successfully updated
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: An error occurred while updating the username
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [UNKNOWN_ERROR]
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.put('/', AuthMiddleware, routes.updateUser);

/**
 * @openapi
 * /api/user/picture:
 *   post:
 *     summary: Update the authenticated user's profile picture
 *     description: Uploads a new profile picture for the authenticated user. Returns the success status and the file path of the uploaded image.
 *     tags:
 *       - User
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - image
 *             properties:
 *               image:
 *                 type: string
 *                 format: binary
 *                 description: The image file to upload
 *     responses:
 *       200:
 *         description: Profile picture updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 path:
 *                   type: string
 *                   description: The filename of the uploaded picture
 *                   example: "user123.png"
 *       404:
 *         description: No image supplied or unknown error
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [NO_IMAGE_SUPPLIED, UNKNOWN_ERROR]
 *               example: NO_IMAGE_SUPPLIED
 *       500:
 *         description: Internal server error
 */
router.post('/picture', upload.single('image'), AuthMiddleware, routes.updateUserPicture);


/**
 * @openapi
 * /api/user:
 *   delete:
 *     summary: Deactivate the current user account
 *     description: Soft deletes (deactivates) the authenticated user's account by setting `active = 0`. Returns `true` if the operation was successful.
 *     tags:
 *       - User
 *     responses:
 *       200:
 *         description: User account successfully deactivated
 *         content:
 *           application/json:
 *             schema:
 *               type: boolean
 *               example: true
 *       404:
 *         description: An error occurred while deleting the user
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 *               enum: [UNKNOWN_ERROR]
 *               example: UNKNOWN_ERROR
 *       500:
 *         description: Internal server error
 */
router.delete('/', AuthMiddleware, routes.deleteUser);

export default router;