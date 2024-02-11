import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'runs_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE runs(id INTEGER, title TEXT, distance REAL, unit TEXT, time INTEGER, type TEXT, notes TEXT)',
      );
    },
    version: 1,
  );

  Future<void> insertRun(Run run) async {
    final db = await database;
    await db.insert(
      'runs',
      run.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Run>> runs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('runs');

    return List.generate(maps.length, (i) {
      return Run(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        distance: maps[i]['distance'] as double,
        unit: maps[i]['unit'] as String,
        time: maps[i]['time'] as int,
        type: maps[i]['type'] as String,
        notes: maps[i]['type'] as String,
      );
    });
  }

  Future<void> deleteDatabase(String path) =>
    databaseFactory.deleteDatabase(path);

  var lasaTrack = const Run(
    id: 0,
    title: "LASA Track Practice",
    distance: 5.5,
    unit: "mi",
    time: 40,
    type: "Workout",
    notes: "",
  );

  //deleteDatabase(await getDatabasesPath());
  // await insertRun(lasaTrack);
  print(await runs());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Running Log',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Running Log"),
        actions: <Widget>[
          Row(
            children: [
              Text("You"),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return ProfilePage();
                    },
                  ));
                },
              ),
            ],
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Run #$index"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add run"),
        icon: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRunPage()),
          );
        },
      ),
    );
  }

}

class AddRunPage extends StatefulWidget {
  @override
  State<AddRunPage> createState() => _AddRunPageState();
}

class _AddRunPageState extends State<AddRunPage> {
  final formKey = GlobalKey<FormState>();
  String _title = "Run";
  double _distance = 0;
  String _unit = "mi";
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String _type = "N/A";
  String _notes = "";

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Add Run"),
          ),
          body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StringInputBox(
                    labelText: "Title",
                    strValueSetter: (value) => _title = value,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Flexible(
                        child: DoubleInputBox(
                          labelText: "Distance",
                          doubleValueSetter: (value) => _distance = value,
                        ),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        height: 55,
                        width: 90,
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Units",
                          ),
                          items: [
                            DropdownMenuItem(value: "mi", child: Text("mi")),
                            DropdownMenuItem(value: "km", child: Text("km")),
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              _unit = newValue!;
                            });
                          },
                          value: _unit,
                          validator: (value) {
                            if (value != "mi" && value != "km") {
                              return "Invalid input";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Flexible(
                        child: IntInputBox(
                          labelText: "Hours",
                          intValueSetter: (value) => _hours = value,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        ":",
                        style: const TextStyle(fontSize: 20)
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: IntInputBox(
                          labelText: "Minutes",
                          intValueSetter: (value) => _minutes = value,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        ":",
                        style: const TextStyle(fontSize: 20)
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: IntInputBox(
                          labelText: "Seconds",
                          intValueSetter: (value) => _seconds = value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Type",
                    ),
                    items: [
                      DropdownMenuItem(value: "N/A", child: Text("N/A")),
                      DropdownMenuItem(value: "Easy Run", child: Text("Easy Run")),
                      DropdownMenuItem(value: "Long Run", child: Text("Long Run")),
                      DropdownMenuItem(value: "Race", child: Text("Race")),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _type = newValue!;
                      });
                    },
                    value: _type,
                    validator: (value) {
                      if (value != "N/A" && value != "Easy Run" && value != "Long Run" && value != "Race") {
                        return "Invalid input";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: constraints.maxHeight-100,
                    child: StringInputBox(
                      labelText: "Notes",
                      strValueSetter: (value) => _notes = value,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: () {
              // validate form
              if (formKey.currentState?.validate() == true) {
                formKey.currentState?.save();       
                // return to homepage
                Navigator.pop(context);     
              }
            },
          ),
        );
      }
    );
  }
}

class IntInputBox extends StatelessWidget {
  const IntInputBox({
    super.key,
    required this.labelText,
    required this.intValueSetter,
  });

  final String labelText;
  final void Function(int value) intValueSetter;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      validator: (value) {
        if (value == null || int.tryParse(value) == null) {
          return "Must be an integer";
        }
        return null;
      },
      onSaved: (newValue) => intValueSetter(int.parse("$newValue")),
    );
  }
}

class DoubleInputBox extends StatelessWidget {
  const DoubleInputBox({
    super.key,
    required this.labelText,
    required this.doubleValueSetter,
  });

  final String labelText;
  final void Function(double value) doubleValueSetter;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      validator: (value) {
        if (value == null || double.tryParse(value) == null) {
          return "Must be a number";
        }
        return null;
      },
      onSaved: (newValue) => doubleValueSetter(double.parse("$newValue")),
    );
  }
}

class StringInputBox extends StatelessWidget {
  const StringInputBox({
    super.key,
    required this.labelText,
    required this.strValueSetter,
  });

  final String labelText;
  final void Function(String value) strValueSetter;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
      validator: (value) {
        if (value?.isEmpty == true) {
          return "Please fill out this field";
        }
        return null;
      },
      onSaved: (newValue) => strValueSetter("$newValue"),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Placeholder(),
    );
  }
}

class Run {
  final int id;
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

  @override
  String toString() {
    return 'Run{id: $id, itle: $title, distance: $distance, unit: $unit, time: $time, type: $type, notes: $notes}';
  }

}