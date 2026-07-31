# API Reference

## Base URL

| Environment | URL |
|-------------|-----|
| Development | `http://10.0.2.2:5000` |
| Staging | `https://staging.api.profitconnect.app` |
| Production | `https://api.profitconnect.app` |

## Authentication

All authenticated requests require a Bearer token in the Authorization header.

### Token Storage
- Stored in FlutterSecureStorage under key `auth_token`
- Refresh token stored under key `refresh_token`
- Automatically attached by ApiService interceptor
- Auto-refreshed on 401 responses

### Endpoints

#### POST `/api/auth/login`
```json
{
  "email": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "token": "jwt_token",
  "user": { ... }
}
```

#### POST `/api/auth/refresh`
```json
{ "refreshToken": "string" }
```

**Response:**
```json
{ "token": "new_jwt_token" }
```

#### POST `/api/auth/forgot-password`
```json
{ "email": "string" }
```

#### POST `/api/auth/reset-password`
```json
{ "email": "string", "otp": "string", "newPassword": "string" }
```

---

## Posts

#### GET `/api/posts?page=1&limit=10`
Returns paginated list of posts.

#### GET `/api/posts/:id`
Returns single post by ID.

#### POST `/api/posts`
Create new post (multipart for media uploads).

#### POST `/api/posts/:id/like`
Toggle like on post.

#### POST `/api/posts/:id/comments`
```json
{ "content": "string" }
```

---

## Jobs

#### GET `/api/jobs?search=&type=&workPlace=&workLevel=&page=1&limit=20`
Returns paginated jobs with optional filters.

**Query Parameters:**
- `search` - Text search in title, description, location
- `type` - Full-time, Part-time, Contract, Internship
- `workPlace` - Remote, On-site, Hybrid
- `workLevel` - Entry, Mid, Senior, Lead
- `page`, `limit` - Pagination
- `cursor` - Cursor-based pagination

#### POST `/api/jobs/:id/apply`
Apply to a job.

---

## Messages

#### GET `/api/messages/conversations`
List user's conversations.

#### POST `/api/messages/conversations`
```json
{ "recipientId": "string" }
```
Create or get existing conversation.

#### GET `/api/messages/conversations/:conversationId`
Get messages in a conversation.

#### POST `/api/messages/conversations/:conversationId`
```json
{ "content": "string" }
```
Send a message.

---

## Projects

#### GET `/api/projects?page=1&limit=10`
List projects with optional filters.

#### POST `/api/projects`
Create new project.

---

## Translate

#### POST `/api/translate`
```json
{ "text": "string" }
```
Translate text to the user's locale.

---

## Companies

#### GET `/api/companies`
List companies with optional filters.

#### POST `/api/companies`
Create company (admin only).

---

## User Profile

#### PUT `/api/user/profile`
Update user profile fields:
- `firstName`, `lastName`, `headline`, `bio`
- `skills` (array)
- `location`, `phoneNumber`

---

## Error Response

```json
{
  "success": false,
  "message": "Error description",
  "statusCode": 400
}
```

---

## HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (triggers token refresh) |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Server Error |