class TimetableData {
  static const String className = "5 YEAR (INTEG) M.TECH - 4A";

  static const Map<int, String> periodTimes = {
    1: "08:00-08:45",
    2: "08:45-09:30",
    3: "09:50-10:35",
    4: "10:35-11:20",
    5: "12:20-13:05",
    6: "13:05-13:50",
    7: "14:10-14:55",
    8: "14:55-15:40",
  };

  static const Map<String, List<Map<String, dynamic>>> weeklySchedule = {
    "Monday": [
      {
        "start": 1,
        "end": 1,
        "title": "Algorithms Design and Analysis",
        "type": "theory",
      },
      {
        "start": 2,
        "end": 4,
        "title": "Algorithms Laboratory / MPC Laboratory",
        "type": "lab",
      },
      {"start": 5, "end": 5, "title": "Database Systems", "type": "theory"},
      {
        "start": 6,
        "end": 7,
        "title": "Discrete Mathematical Structures",
        "type": "theory",
      },
      {"start": 8, "end": 8, "title": "Library", "type": "other"},
    ],
    "Tuesday": [
      {
        "start": 1,
        "end": 1,
        "title": "Microprocessors and Microcontrollers",
        "type": "theory",
      },
      {"start": 2, "end": 2, "title": "Database Systems", "type": "theory"},
      {
        "start": 3,
        "end": 4,
        "title": "Database Systems Laboratory / Software Engineering Lab",
        "type": "lab",
      },
      {
        "start": 5,
        "end": 5,
        "title": "Discrete Mathematical Structures",
        "type": "theory",
      },
      {
        "start": 6,
        "end": 6,
        "title": "Algorithms Design and Analysis",
        "type": "theory",
      },
      {"start": 7, "end": 7, "title": "Indian Constitution", "type": "theory"},
      {"start": 8, "end": 8, "title": "Self Learning", "type": "other"},
    ],
    "Wednesday": [
      {
        "start": 1,
        "end": 1,
        "title": "Introduction to Artificial Intelligence",
        "type": "theory",
      },
      {
        "start": 2,
        "end": 4,
        "title": "Algorithms Laboratory / MPC Laboratory",
        "type": "lab",
      },
      {
        "start": 5,
        "end": 5,
        "title": "Microprocessors and Microcontrollers",
        "type": "theory",
      },
      {
        "start": 6,
        "end": 6,
        "title": "Algorithms Design and Analysis",
        "type": "theory",
      },
      {
        "start": 7,
        "end": 7,
        "title": "Introduction to Artificial Intelligence",
        "type": "theory",
      },
      {"start": 8, "end": 8, "title": "Mentor", "type": "other"},
    ],
    "Thursday": [
      {"start": 1, "end": 1, "title": "Database Systems", "type": "theory"},
      {
        "start": 2,
        "end": 2,
        "title": "Microprocessors and Microcontrollers",
        "type": "theory",
      },
      {"start": 3, "end": 3, "title": "Indian Constitution", "type": "theory"},
      {
        "start": 4,
        "end": 4,
        "title": "Discrete Mathematical Structures",
        "type": "theory",
      },
      {"start": 5, "end": 5, "title": "Database Systems", "type": "theory"},
      {
        "start": 6,
        "end": 8,
        "title": "Software Engineering Principles and Practices Laboratory",
        "type": "lab",
      },
    ],
    "Friday": [
      {
        "start": 1,
        "end": 1,
        "title": "Discrete Mathematical Structures",
        "type": "theory",
      },
      {
        "start": 2,
        "end": 3,
        "title": "Introduction to Artificial Intelligence",
        "type": "theory",
      },
      {
        "start": 4,
        "end": 4,
        "title": "Algorithms Design and Analysis",
        "type": "theory",
      },
      {"start": 5, "end": 5, "title": "Indian Constitution", "type": "theory"},
      {
        "start": 6,
        "end": 6,
        "title": "Microprocessors and Microcontrollers",
        "type": "theory",
      },
      {
        "start": 7,
        "end": 8,
        "title": "Software Engineering Principles and Practices Laboratory",
        "type": "lab",
      },
    ],
  };

  static String getSubject(String dayName, int period) {
    final sessions = weeklySchedule[dayName];
    if (sessions == null) return "No Class";

    for (var session in sessions) {
      if (period >= session['start'] && period <= session['end']) {
        return session['title'];
      }
    }
    return "Free Period";
  }
}
