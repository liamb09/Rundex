import "dart:convert";
import "dart:typed_data";

class Run {
  final int? id;
  final String title;
  final double distance;
  final String unit;
  final int time;
  final double? perceivedEffort;
  final String type;
  final String notes;
  final Map<int, List<dynamic>>? sets;
  final String? color;
  final int timestamp;
  final Uint8List? image;

  const Run ({
    this.id,
    required this.title,
    required this.distance,
    required this.unit,
    required this.time,
    this.perceivedEffort,
    required this.type,
    required this.notes,
    this.sets, // id : [description, image, reps, pace]}
    this.color,
    required this.timestamp,
    this.image,
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
      "sets": encodeSets(sets),
      "color": color,
      "timestamp": timestamp,
      "image": image,
    };
  }

  static String encodeSets (Map<int, List<dynamic>>? s) {
    Map<String, String>? newS = {};
    if (s != null) {
      for (var entry in s.entries) {
        newS.addAll({jsonEncode(entry.key) : jsonEncode(entry.value)});
      }
    }
    return jsonEncode(newS);
  }

  static Map<int, List<dynamic>>? decodeSets (String s) {
    if (s == "") return null;
    var newMap = jsonDecode(s) as Map<dynamic, dynamic>;
    Map<int, List<dynamic>>? ret = {};
    for (var entry in newMap.entries) {
      List<dynamic> details = jsonDecode(entry.value);
      ret.addAll({int.parse(entry.key) : details});
    }
    return ret;
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
    sets: decodeSets(map['sets']),
    color: map['color'],
    timestamp: map['timestamp'],
    image: map['image']
  );

  @override
  String toString() {
    return 'Run{id: $id, title: $title, distance: $distance, unit: $unit, time: $time, perceivedEffort: $perceivedEffort type: $type, notes: $notes, sets: $sets, color: $color, timestamp: $timestamp, image: $image}';
  }

}