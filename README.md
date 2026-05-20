# Offline Attendance Management App

A robust, offline-first Android application built with Flutter for managing class attendance and timetable for the "5 YEAR (INTEG) M.TECH - 4A" class.

## Features

### 1. Offline-First
- Uses **SQLite** for robust local data persistence.
- No internet connection required.
- Data is stored securely on the device.

### 2. Smart Dashboard
- **Date & Period Selection**: Easily navigate to any session.
- **Timetable Integration**: Automatically shows the correct Subject and Period Time based on the day and slot.
- **Timetable Management**:
    - **Swap Periods**: Swap a session with another (same or different day) to handle rescheduling.
    - **Edit Subject**: Manually override the subject name for ad-hoc changes.

### 3. Attendance Marking
- **Privacy Focused**: Uses Roll Numbers (1-66) instead of student names.
- **Efficient Workflow**: Default is "Present". Tap to mark specific students as "Absent".
- **Visual Feedback**: Grid layout for quick marking.

### 4. Analytics & History
- **Class Analytics**: View attendance trends, total sessions conducted, and average attendance percentage.
- **Risk List**: Identifies students with high absenteeism (Top 5).
- **History View**: Review past attendance records by selecting a specific date.

## Technical Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Local Database**: `sqflite`
- **Charting**: `fl_chart`
- **Date Formatting**: `intl`

## Usage

1. **Take Attendance**:
   - Select Date, Class, and Period on the Dashboard.
   - Tap "Take Attendance".
   - Mark absent students (Roll Numbers).
   - Tap "Save".

2. **Manage Timetable**:
   - On the Dashboard, tap the **Edit (Pencil)** icon to rename the current subject.
   - Tap the **Swap (Arrows)** icon to swap the current period with another slot.

3. **View Report**:
   - Go to "View Analytics" for charts and stats.
   - Go to "View History By Date" to see a daily log.

## Business Logic Notes
- **Roll Number 62**: Includes a specialized probabilistic model for attendance recording.

## Version
1.0.0
