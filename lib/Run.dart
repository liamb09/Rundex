final String tableNotes = 'runs';

class RunFields {
  static final List<String> values = [
    id, title, distance, unit, time, type, notes
  ];

  static final String id = "_id";
  static final String title = "title";
  static final String distance = "distance";
  static final String unit = "unit";
  static final String time = "time";
  static final String type = "type";
  static final String notes = "notes";
}

class Run {
  final int? id;
  final String title;
  final double distance;
  final String unit;
  final int time;
  final String type;
  final String notes;

  const Run ({
    required this.id,
    required this.title,
    required this.distance,
    required this.unit,
    required this.time,
    required this.type,
    required this.notes,
  });

  Run copy({
    int? id,
    String? title,
    double? distance,
    String? unit,
    int? time,
    String? type,
    String? notes,
  }) => Run(
    id: id ?? this.id,
    title: title ?? this.title,
    distance: distance ?? this.distance,
    unit: unit ?? this.unit,
    time: time ?? this.time,
    type: type ?? this.type,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toMap () {
    return {
      "id": id,
      "title": title,
      "distance": distance,
      "unit": unit,
      "time": time,
      "type": type,
      "notes": notes,
    };
  }

  static Run fromMap (Map<String, dynamic> map) => Run(
    id: map[RunFields.id] as int?,
    title: map[RunFields.title] as String,
    distance: map[RunFields.distance] as double,
    unit: map[RunFields.unit] as String,
    time: map[RunFields.time] as int,
    type: map[RunFields.type] as String,
    notes: map[RunFields.notes] as String,
  );

  @override
  String toString() {
    return 'Run{id: $id, title: $title, distance: $distance, unit: $unit, time: $time, type: $type, notes: $notes}';
  }

}