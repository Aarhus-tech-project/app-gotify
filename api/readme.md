# API Endpoints

## POST /users/register
Registers a new user.

**Responses:**

- **200 OK**  
  - `true` → User was successfully created  
  - `false` → User was not created

- **404 Not Found**  
  - `{"error": "USERNAME_NOT_AVAILABLE"}` → Username is already taken
  - `{"error": "USERNAME_OR_PASSWORD_MISSING"}` → Username or passsword missing
  - `{"error": "UNKNOWN_ERROR"}` → An unknown error occurred

---

## POST /users/login
Logs in a user.

**Responses:**

- **200 OK**  
  - `{"token": "<JWT_TOKEN>"}` → Login successful

- **404 Not Found**  
  - `{"error": "USER_NOT_FOUND"}` → User does not exist  
  - `{"error": "UNKNOWN_ERROR"}` → An unknown error occurred
