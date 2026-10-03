class Event {
  final DateTime date;
  final String address;
  final bool samePPE;

  Event({
    required this.date,
    required this.address,
    required this.samePPE,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'address': address,
      'samePPE': samePPE,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      date: DateTime.parse(json['date']),
      address: json['address'],
      samePPE: json['samePPE'],
    );
  }
}
