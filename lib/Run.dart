class Run {
  final int? id;
  final String title;
  final double distance;
  final String unit;
  final int time;
  final String type;
  final String notes;

  const Run ({
    this.id,
    required this.title,
    required this.distance,
    required this.unit,
    required this.time,
    required this.type,
    required this.notes,
  });

  Map<String, dynamic> toMap () {
    return {
      "_id": id,
      "title": title,
      "distance": distance,
      "unit": unit,
      "time": time,
      "type": type,
      "notes": notes,
    };
  }

  static Run fromMap (Map<String, dynamic> map) => Run(
    id: map['_id'],
    title: map['title'],
    distance: map['distance'],
    unit: map['unit'],
    time: map['time'],
    type: map['type'],
    notes: map['notes'],
  );

  @override
  String toString() {
    return 'Run{id: $id, title: $title, distance: $distance, unit: $unit, time: $time, type: $type, notes: $notes}';
  }

}