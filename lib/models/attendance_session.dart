class AttendanceSession {
  final int? id;
  final String date; // YYYY-MM-DD
  final String className;
  final int period;
  final int timestamp;
  final List<int> absentRollNumbers; // List of Roll Numbers who are ABSENT

  AttendanceSession({
    this.id,
    required this.date,
    required this.className,
    required this.period,
    required this.timestamp,
    required this.absentRollNumbers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'className': className,
      'period': period,
      'timestamp': timestamp,
    };
  }

  factory AttendanceSession.fromMap(
    Map<String, dynamic> map,
    List<int> absences,
  ) {
    return AttendanceSession(
      id: map['id'],
      date: map['date'],
      className: map['className'],
      period: map['period'],
      timestamp: map['timestamp'],
      absentRollNumbers: absences,
    );
  }

  AttendanceSession copyWith({
    int? id,
    String? date,
    String? className,
    int? period,
    int? timestamp,
    List<int>? absentRollNumbers,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      date: date ?? this.date,
      className: className ?? this.className,
      period: period ?? this.period,
      timestamp: timestamp ?? this.timestamp,
      absentRollNumbers: absentRollNumbers ?? this.absentRollNumbers,
    );
  }
}
