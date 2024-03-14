import "dart:convert";

class Run {
  final int? id;
  final String title;
  final double distance;
  final String unit;
  final int time;
  final double? perceivedEffort;
  final String type;
  final String notes;
  final List<dynamic>? reps;
  final List<dynamic>? descriptions;
  final String? color;

  const Run ({
    this.id,
    required this.title,
    required this.distance,
    required this.unit,
    required this.time,
    this.perceivedEffort,
    required this.type,
    required this.notes,
    this.reps,
    this.descriptions,
    this.color,
  });

  Map<String, dynamic> toMap () {
    return {
      "_id": id,
      "title": title,
      "distance": distance,
      "unit": unit,
      "time": time,
      "perceivedEffort": perceivedEffort,
      "type": type,
      "notes": notes,
      "reps": jsonEncode(reps),
      "descriptions": jsonEncode(descriptions),
      "color": color,
    };
  }

  static Run fromMap (Map<String, dynamic> map) => Run(
    id: map['_id'],
    title: map['title'],
    distance: map['distance'],
    unit: map['unit'],
    time: map['time'],
    perceivedEffort: map['perceivedEffort'],
    type: map['type'],
    notes: map['notes'],
    reps: jsonDecode(map['reps']),
    descriptions: jsonDecode(map['descriptions']),
    color: map['color'],
  );

  @override
  String toString() {
    return 'Run{id: $id, title: $title, distance: $distance, unit: $unit, time: $time, perceivedEffort: $perceivedEffort type: $type, notes: $notes, reps: ${reps.toString()}, descriptions: ${descriptions.toString()}, color: $color}';
  }

}