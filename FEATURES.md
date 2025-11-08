# 📱 FocusFlow - Complete Features Documentation

This document provides detailed information about all features in the FocusFlow app.

---

## 🎯 Overview

FocusFlow is a comprehensive productivity and digital wellbeing application designed to help users:
- Reduce social media distractions
- Manage daily tasks efficiently
- Improve focus using the Pomodoro technique
- Track productivity progress

---

## 1. 🚫 App Limits Feature

### Purpose
Help users break free from social media addiction by blocking distracting app sections.

### Supported Apps
1. **Facebook** 📘
   - News Feed
   - Stories
   - Reels
   - Marketplace
   - Groups

2. **YouTube** 📺
   - Shorts
   - Trending
   - Subscriptions
   - Home Feed

3. **Instagram** 📷
   - Stories
   - Reels
   - Explore
   - Home Feed

4. **TikTok** 🎵
   - For You
   - Following
   - Live
   - Discover

5. **Snapchat** 👻
   - Stories
   - Discover
   - Snap Map
   - Chat

### How It Works

#### Step 1: Enable App Limits
- Navigate to the "App Limits" tab
- Toggle the switch next to any app to enable restrictions
- The switch turns blue when active

#### Step 2: Add Blocked Sections
- Tap "Add Section" button
- Select specific features to block (e.g., Instagram Reels)
- Blocked sections appear as chips below the app name
- Remove sections by tapping the X icon on any chip

#### Step 3: Test the Block
- Tap "Test Block" to see the motivational quote dialog
- This simulates what happens when you try to access blocked content
- A random motivational quote appears to encourage focus

### Motivational Quotes Library

The app includes 15+ inspiring quotes:
- "Every minute spent scrolling is a minute stolen from your dreams."
- "Focus on what matters. Your future self will thank you."
- "Distraction is the enemy of progress."
- "Time is your most valuable asset. Invest it wisely."
- "Success is built one focused moment at a time."
- And more...

### Future Enhancements
- Real-time app usage monitoring (Android UsageStatsManager)
- Automatic app closure when blocked sections are accessed
- Daily/weekly usage reports
- Custom time-based restrictions (e.g., block after 30 minutes)

---

## 2. ✅ To-Do List Feature

### Purpose
Organize daily tasks with a smart, color-coded priority system.

### Task Properties
- **Title**: Main task description (required)
- **Description**: Additional details (optional)
- **Priority**: Color-coded importance level
- **Due Date**: Optional deadline
- **Completion Status**: Checked/unchecked

### Priority System

#### 🔴 High Priority (Red)
- Very important and urgent tasks
- Appears at the top of the list
- Examples: Project deadlines, important meetings

#### 🟡 Medium Priority (Yellow)
- Important but not urgent
- Appears in the middle
- Examples: Weekly reports, routine tasks

#### 🟢 Low Priority (Green)
- Flexible or low-priority items
- Appears at the bottom
- Examples: Optional tasks, future planning

### Task Management

#### Adding a Task
1. Tap the "➕ Add Task" floating button
2. Enter task title (required)
3. Add description (optional)
4. Select priority level
5. Set due date (optional)
6. Tap "Add" to save

#### Editing a Task
1. Tap the three-dot menu on any task
2. Select "Edit"
3. Modify any field
4. Tap "Save"

#### Completing a Task
1. Tap the checkbox next to the task
2. Task moves to "Completed" section
3. Text appears with strikethrough
4. Completion time is recorded

#### Deleting a Task
1. Tap the three-dot menu
2. Select "Delete"
3. Task is removed
4. Tap "Undo" in the snackbar to restore

#### Clearing Completed Tasks
1. Tap the sweep icon in the app bar
2. Confirm deletion
3. All completed tasks are removed

### Auto-Sorting
Tasks automatically sort by:
1. **Completion status** (incomplete first)
2. **Priority level** (high → medium → low)

### Visual Indicators
- **Priority badge**: Shows emoji and color
- **Due date icon**: Calendar icon with date
- **Completion count**: Badge showing active tasks
- **Strikethrough text**: For completed tasks

---

## 3. ⏱️ Pomodoro Timer Feature

### Purpose
Boost productivity using the proven Pomodoro Technique.

### The Pomodoro Technique
- **25 minutes** of focused work
- **5 minutes** of break
- Repeat cycle for optimal productivity
- Based on scientific research

### Timer Modes

#### Focus Mode 🧠
- Default: 25 minutes
- Customizable: 5-60 minutes
- For deep work and concentration
- Tracks completed sessions

#### Break Mode ☕
- Default: 5 minutes
- Customizable: 5-30 minutes
- For rest and recovery
- Prevents burnout

### Controls

#### Play Button ▶️
- Starts the current timer
- Timer counts down second by second
- Circular progress indicator shows progress

#### Pause Button ⏸️
- Pauses the timer
- Preserves remaining time
- Resume by pressing play again

#### Reset Button 🔄
- Resets timer to initial duration
- Stops any running timer
- Clears current progress

### Settings ⚙️

#### Focus Duration
- Adjust in 5-minute increments
- Range: 5-60 minutes
- Default: 25 minutes

#### Break Duration
- Adjust in 5-minute increments
- Range: 5-30 minutes
- Default: 5 minutes

#### Auto-Start Break
- Automatically start break after focus session
- Toggle on/off
- Seamless workflow

#### Auto-Start Focus
- Automatically start focus after break
- Toggle on/off
- Continuous productivity

#### Background Sounds
- **None**: Silent mode
- **Rain**: Calming rain sounds
- **Coffee Shop**: Ambient café noise
- **White Noise**: Consistent background sound
- **Forest**: Nature sounds

### Session Tracking

#### Today's Stats
- 🍅 **Sessions**: Number of completed Pomodoros today
- ⏱️ **Minutes**: Total focus time today
- 🔥 **Total**: All-time session count

#### Completion Dialog
- Appears when timer reaches zero
- Congratulatory message
- Options to switch mode or continue
- Auto-start if enabled

### Visual Design
- Large circular timer (280x280)
- Color-coded progress (blue for focus, green for break)
- Real-time countdown display
- Smooth animations

---

## 4. 📊 Profile Dashboard Feature

### Purpose
Track productivity, view statistics, and manage account settings.

### Header Section

#### Personalized Greeting
- **Morning** (5 AM - 12 PM): "Good Morning 👋"
- **Afternoon** (12 PM - 5 PM): "Good Afternoon 👋"
- **Evening** (5 PM - 5 AM): "Good Evening 👋"

#### User Information
- Profile avatar with initial
- User name (editable)
- Current date (formatted)

### Daily Statistics

#### Tasks Completed ✅
- Count of tasks finished today
- Updates in real-time
- Resets at midnight

#### Focus Time ⏰
- Total minutes spent in Pomodoro sessions
- Calculated from completed sessions
- Displayed in minutes

#### Pomodoro Sessions 🍅
- Number of completed focus sessions today
- Tracks productivity consistency
- Motivates daily goals

### Weekly Progress Chart

#### Bar Chart Visualization
- Shows last 7 days of activity
- Each bar represents daily Pomodoro sessions
- Days labeled (M, T, W, T, F, S, S)
- Interactive and animated

#### Data Points
- Automatically calculates from session history
- Updates in real-time
- Helps identify productivity patterns

### Achievement System

#### Available Badges

1. **🏆 5 Tasks Master**
   - Unlock: Complete 5 tasks in one day
   - Reward: Sense of accomplishment

2. **🔥 Focus Streak**
   - Unlock: Complete 4 Pomodoro sessions in one day
   - Reward: Productivity recognition

3. **⭐ Productivity Star**
   - Unlock: Complete 10 total Pomodoro sessions
   - Reward: Milestone achievement

4. **💪 Task Warrior**
   - Unlock: Complete 20 tasks overall
   - Reward: Long-term dedication badge

5. **🎯 Getting Started**
   - Default badge for new users
   - Encourages continued use

### Settings & Options

#### Backup Data 💾
- Save progress to cloud (coming soon)
- Prevent data loss
- Sync across devices

#### Notifications 🔔
- Manage reminders and alerts
- Customize notification preferences
- Control frequency

#### About FocusFlow ℹ️
- App version information
- Developer credits
- License information

#### Edit Profile ✏️
- Change display name
- Update personal information
- Customize experience

---

## 🎨 Design Principles

### Color Scheme
- **Primary**: Indigo (#6366F1)
- **Secondary**: Purple (#8B5CF6)
- **Accent**: Cyan (#06B6D4)
- **Error**: Red (#EF4444)
- **Warning**: Amber (#F59E0B)
- **Success**: Green (#10B981)

### Typography
- **Headings**: Bold, 18-28px
- **Body**: Regular, 14-16px
- **Captions**: Light, 12-14px

### UI Components
- **Cards**: Rounded corners (16px), subtle shadows
- **Buttons**: Rounded (12px), no elevation
- **Icons**: Material Design icons
- **Animations**: Smooth, 300ms duration

---

## 📱 Navigation

### Bottom Navigation Bar
- **App Limits**: Block icon
- **To-Do**: Checklist icon
- **Pomodoro**: Timer icon
- **Profile**: Person icon

### Gestures
- **Swipe**: Navigate onboarding pages
- **Tap**: Select items, toggle switches
- **Long press**: (Future feature)
- **Pull to refresh**: Reload profile data

---

## 💾 Data Storage

### Local Storage (SharedPreferences)
- User name
- App limit settings
- To-do tasks
- Pomodoro sessions
- Pomodoro settings
- First-time flag

### Data Persistence
- Automatic saving on changes
- No manual save required
- Survives app restarts

---

## 🔔 Notifications (Coming Soon)

### Planned Notification Types
1. **Task Reminders**: Due date alerts
2. **Pomodoro Alerts**: Session start/end
3. **Daily Summary**: End-of-day report
4. **Achievement Unlocked**: Badge notifications
5. **Motivational**: Random encouragement

---

## 🌐 Future Features

### Phase 2
- [ ] Cloud backup (Firebase)
- [ ] User authentication
- [ ] Real app usage tracking
- [ ] Custom themes

### Phase 3
- [ ] Social features
- [ ] Team collaboration
- [ ] Export data (CSV/PDF)
- [ ] Widget support

### Phase 4
- [ ] AI-powered insights
- [ ] Smart scheduling
- [ ] Habit tracking
- [ ] Wellness integration

---

## 📞 Support

For feature requests or bug reports:
- GitHub Issues: [Create an issue]
- Email: support@focusflow.app
- Documentation: [Read the docs]

---

**Stay Focused, Stay Productive! 🎯**

