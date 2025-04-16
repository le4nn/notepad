class Appointment {
  String doctorName;
  String date;
  String time;
  String reason;
  String? key;

  Appointment({
    required this.doctorName,
    required this.date,
    required this.time,
    required this.reason,
    this.key,
  });

  Map<String, dynamic> toJson() => {
    'doctorName': doctorName,
    'date': date,
    'time': time,
    'reason': reason,
  };

  factory Appointment.fromJson(Map<dynamic, dynamic> json, String key) {
    return Appointment(
      doctorName: json['doctorName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      reason: json['reason'] ?? '',
      key: key,
    );
  }
}