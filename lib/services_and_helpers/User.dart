import "dart:convert";

class User {
  final String name;
  final int age;
  final double height;
  final int weight;
  final List<String> types;
  final List<String> colors;

  const User ({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.types,
    required this.colors,
  });

  Map<String, dynamic> toMap () {
    return {
      "name": name,
      "age": age,
      "height": height,
      "weight": weight,
      "types": jsonEncode(types),
      "colors": jsonEncode(colors),
    };
  }

  static User fromMap (Map<String, dynamic> map) => User (
    name: map['name'],
    age: map['age'],
    height: map['height'],
    weight: map['weight'],
    types: List<String>.from(jsonDecode(map['types'])),
    colors: List<String>.from(jsonDecode(map['colors'])),
  );

  @override
  String toString () {
    return "User{name: $name, age: $age, height: $height, weight: $weight, types: ${types.toString()}, colors: ${colors.toString()}}";
  }
}