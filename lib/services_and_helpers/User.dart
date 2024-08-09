import "dart:convert";
import "dart:typed_data";

class User {
  final String name;
  final int age;
  final double height;
  final int weight;
  final Map<String, String> runColors;
  final int? goal;
  final String distUnit;
  final Map<String, Map<Uint8List?, double?>>? routes;

  const User ({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.runColors,
    this.goal,
    required this.distUnit,
    this.routes,
  });

  Map<String, dynamic> toMap () {
    return {
      "name": name,
      "age": age,
      "height": height,
      "weight": weight,
      "runColors": jsonEncode(runColors),
      "goal": goal,
      "distUnit": distUnit,
      "routes": encodeRoutes(routes),
    };
  }

  static String encodeRoutes (Map<String, Map<Uint8List?, double?>>? r) {
    Map<String, Map<String?, double?>>? newR = {};
    if (r != null) {
      for (var entry in r.entries) {
        newR.addAll({entry.key : {jsonEncode(entry.value.keys.first) : entry.value.values.first}});
      }
    }
    return jsonEncode(newR);
  }

  static Map<String, Map<Uint8List?, double?>>? decodeRoutes (String r) {
    Map<String, dynamic> newMap = jsonDecode(r);
    Map<String, Map<Uint8List?, double?>>? ret = {};
    for (var entry in newMap.entries) {
      var details = entry.value as Map<String, dynamic>;
      Uint8List? image = castToUint8List(jsonDecode(details.keys.first));
      double? distance = details.values.first as double?;
      ret.addAll({entry.key : {image : distance}});
    }
    return ret;
  }

  static Uint8List? castToUint8List (List<dynamic>? l) {
    if (l != null) {
      List<int> intList = l.cast<int>().toList();
      Uint8List ret = Uint8List.fromList(intList);
      return ret;
    }
    return null;
  }

  static User fromMap (Map<String, dynamic> map) => User (
    name: map['name'],
    age: map['age'],
    height: map['height'],
    weight: map['weight'],
    runColors: Map<String, String>.from(jsonDecode(map['runColors'])),
    goal: map['goal'],
    distUnit: map['distUnit'],
    routes: jsonDecode(map['routes']) == null ? null : decodeRoutes(map['routes']),
  );

  void addRoute (String name, Uint8List image, double mileage) {
    routes?.addAll({name : {image : mileage}});
  }

  @override
  String toString () {
    return "User{name: $name, age: $age, height: $height, weight: $weight, runColors: $runColors, goal: $goal, distUnit: $distUnit, routes: $routes}";
  }
}