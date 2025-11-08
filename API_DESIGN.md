# 🔌 FocusFlow - Backend API Design (Future Implementation)

This document outlines the planned backend API architecture for FocusFlow using NestJS, Prisma, and PostgreSQL.

---

## 🏗️ Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Backend Framework** | NestJS | RESTful API server |
| **ORM** | Prisma | Database management |
| **Database** | PostgreSQL | Data storage |
| **Authentication** | JWT | User authentication |
| **Validation** | class-validator | Input validation |
| **Documentation** | Swagger | API documentation |

---

## 📊 Database Schema

### User Table
```prisma
model User {
  id            String    @id @default(uuid())
  email         String    @unique
  password      String
  name          String
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  
  tasks         Task[]
  sessions      PomodoroSession[]
  appLimits     AppLimit[]
  achievements  Achievement[]
}
```

### Task Table
```prisma
model Task {
  id            String    @id @default(uuid())
  userId        String
  title         String
  description   String?
  priority      Priority
  isCompleted   Boolean   @default(false)
  dueDate       DateTime?
  completedAt   DateTime?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  
  user          User      @relation(fields: [userId], references: [id])
}

enum Priority {
  HIGH
  MEDIUM
  LOW
}
```

### PomodoroSession Table
```prisma
model PomodoroSession {
  id              String    @id @default(uuid())
  userId          String
  startTime       DateTime
  endTime         DateTime?
  focusDuration   Int
  breakDuration   Int
  isCompleted     Boolean   @default(false)
  createdAt       DateTime  @default(now())
  
  user            User      @relation(fields: [userId], references: [id])
}
```

### AppLimit Table
```prisma
model AppLimit {
  id                String    @id @default(uuid())
  userId            String
  appName           String
  isEnabled         Boolean   @default(false)
  blockedSections   String[]
  triggeredCount    Int       @default(0)
  createdAt         DateTime  @default(now())
  updatedAt         DateTime  @updatedAt
  
  user              User      @relation(fields: [userId], references: [id])
}
```

### Achievement Table
```prisma
model Achievement {
  id            String    @id @default(uuid())
  userId        String
  type          AchievementType
  unlockedAt    DateTime  @default(now())
  
  user          User      @relation(fields: [userId], references: [id])
}

enum AchievementType {
  FIVE_TASKS_MASTER
  FOCUS_STREAK
  PRODUCTIVITY_STAR
  TASK_WARRIOR
}
```

---

## 🔐 Authentication Endpoints

### POST /auth/register
Register a new user

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "John Doe"
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe"
  },
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

### POST /auth/login
Login existing user

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe"
  },
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

### POST /auth/refresh
Refresh access token

**Request:**
```json
{
  "refreshToken": "refresh_token"
}
```

**Response:**
```json
{
  "accessToken": "new_jwt_token"
}
```

---

## ✅ Task Endpoints

### GET /tasks
Get all tasks for authenticated user

**Headers:**
```
Authorization: Bearer {jwt_token}
```

**Query Parameters:**
- `completed` (optional): boolean
- `priority` (optional): HIGH | MEDIUM | LOW
- `sortBy` (optional): createdAt | dueDate | priority

**Response:**
```json
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Complete project",
      "description": "Finish the mobile app",
      "priority": "HIGH",
      "isCompleted": false,
      "dueDate": "2024-12-31T23:59:59Z",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 10
}
```

### POST /tasks
Create a new task

**Request:**
```json
{
  "title": "Complete project",
  "description": "Finish the mobile app",
  "priority": "HIGH",
  "dueDate": "2024-12-31T23:59:59Z"
}
```

**Response:**
```json
{
  "id": "uuid",
  "title": "Complete project",
  "description": "Finish the mobile app",
  "priority": "HIGH",
  "isCompleted": false,
  "dueDate": "2024-12-31T23:59:59Z",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### PATCH /tasks/:id
Update a task

**Request:**
```json
{
  "title": "Updated title",
  "isCompleted": true
}
```

### DELETE /tasks/:id
Delete a task

**Response:**
```json
{
  "message": "Task deleted successfully"
}
```

---

## ⏱️ Pomodoro Session Endpoints

### GET /sessions
Get all Pomodoro sessions

**Query Parameters:**
- `startDate` (optional): ISO date
- `endDate` (optional): ISO date
- `completed` (optional): boolean

**Response:**
```json
{
  "sessions": [
    {
      "id": "uuid",
      "startTime": "2024-01-01T10:00:00Z",
      "endTime": "2024-01-01T10:25:00Z",
      "focusDuration": 25,
      "breakDuration": 5,
      "isCompleted": true
    }
  ],
  "total": 50
}
```

### POST /sessions
Create a new session

**Request:**
```json
{
  "startTime": "2024-01-01T10:00:00Z",
  "focusDuration": 25,
  "breakDuration": 5
}
```

### PATCH /sessions/:id
Complete a session

**Request:**
```json
{
  "endTime": "2024-01-01T10:25:00Z",
  "isCompleted": true
}
```

### GET /sessions/stats
Get session statistics

**Response:**
```json
{
  "today": {
    "count": 4,
    "totalMinutes": 100
  },
  "week": {
    "count": 20,
    "totalMinutes": 500
  },
  "month": {
    "count": 80,
    "totalMinutes": 2000
  }
}
```

---

## 🚫 App Limit Endpoints

### GET /app-limits
Get all app limits

**Response:**
```json
{
  "appLimits": [
    {
      "id": "uuid",
      "appName": "Instagram",
      "isEnabled": true,
      "blockedSections": ["Reels", "Stories"],
      "triggeredCount": 15
    }
  ]
}
```

### POST /app-limits
Create app limit

**Request:**
```json
{
  "appName": "Instagram",
  "isEnabled": true,
  "blockedSections": ["Reels", "Stories"]
}
```

### PATCH /app-limits/:id
Update app limit

**Request:**
```json
{
  "isEnabled": false,
  "blockedSections": ["Reels"]
}
```

### POST /app-limits/:id/trigger
Increment trigger count

**Response:**
```json
{
  "triggeredCount": 16
}
```

---

## 🏆 Achievement Endpoints

### GET /achievements
Get user achievements

**Response:**
```json
{
  "achievements": [
    {
      "id": "uuid",
      "type": "FIVE_TASKS_MASTER",
      "unlockedAt": "2024-01-01T12:00:00Z"
    }
  ]
}
```

### POST /achievements/check
Check and unlock achievements

**Response:**
```json
{
  "newAchievements": [
    {
      "type": "PRODUCTIVITY_STAR",
      "unlockedAt": "2024-01-01T12:00:00Z"
    }
  ]
}
```

---

## 📊 Analytics Endpoints

### GET /analytics/dashboard
Get dashboard statistics

**Response:**
```json
{
  "today": {
    "tasksCompleted": 5,
    "pomodoroSessions": 4,
    "focusMinutes": 100
  },
  "week": {
    "tasksCompleted": 25,
    "pomodoroSessions": 20,
    "focusMinutes": 500
  },
  "achievements": 3,
  "weeklyChart": [
    { "day": "Mon", "sessions": 3 },
    { "day": "Tue", "sessions": 4 },
    { "day": "Wed", "sessions": 5 }
  ]
}
```

---

## 🔄 Sync Endpoints

### POST /sync/upload
Upload local data to cloud

**Request:**
```json
{
  "tasks": [...],
  "sessions": [...],
  "appLimits": [...]
}
```

### GET /sync/download
Download cloud data

**Response:**
```json
{
  "tasks": [...],
  "sessions": [...],
  "appLimits": [...],
  "lastSyncAt": "2024-01-01T12:00:00Z"
}
```

---

## 🛡️ Error Responses

### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Invalid credentials"
}
```

### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "statusCode": 500,
  "message": "Internal server error"
}
```

---

## 🚀 Implementation Steps

1. **Setup NestJS Project**
   ```bash
   npm i -g @nestjs/cli
   nest new focusflow-api
   ```

2. **Install Dependencies**
   ```bash
   npm install @prisma/client prisma
   npm install @nestjs/jwt @nestjs/passport passport-jwt
   npm install class-validator class-transformer
   ```

3. **Initialize Prisma**
   ```bash
   npx prisma init
   ```

4. **Create Modules**
   - Auth Module
   - Tasks Module
   - Sessions Module
   - App Limits Module
   - Achievements Module

5. **Deploy**
   - Heroku
   - AWS
   - DigitalOcean
   - Vercel

---

**This API design is ready for implementation in Phase 2!** 🚀

