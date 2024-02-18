import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/Run.dart';
import 'package:running_log/RunsDatabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  Run emptyRun = Run(id: 0, title: "", distance: 0, unit: "", time: 0, type: "", notes: "");
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String secondsToTime (int s) {
    if (s == 0) return "-:--";
    int hours = s ~/ 3600;
    int minutes = (s - hours * 3600) ~/ 60;
    int seconds = s - (hours * 3600 + minutes * 60);
    String secondsStr = "$seconds";
    if (seconds < 10) {
      secondsStr = "0$seconds";
    }
    if (hours > 0) {
      String minutesStr = "$minutes";
      if (minutes < 10) {
        minutesStr = "0$minutes";
      }
      return "$hours:$minutesStr:$secondsStr";
    } else {
      return "$minutes:$secondsStr";
    }
  }

    @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

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
      body: Center(
        child: FutureBuilder<List<Run>>(
          future: RunsDatabase.instance.getRuns(),
          builder: (BuildContext context, AsyncSnapshot<List<Run>> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: Text("Loading..."));
            }
            return snapshot.data!.isEmpty
            ? Center(child: Text("You have no runs."))
            : ListView(
              children: snapshot.data!.map((run) {
                return Center(
                  child: Card(
                    child: ListTile(
                      title: Center(child: Text(run.title)),
                      subtitle: Column(
                        children: [
                          SizedBox(height: 5),
                          Builder(
                            builder: (context) {
                              if (run.type != "N/A") {
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red),
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: Text(run.type),
                                    ),
                                    SizedBox(height: 5),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text("${run.distance} ${run.unit}"),
                                    Text("Distance"),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(secondsToTime(run.time)),
                                    Text("Time"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Builder(
                            builder: (context) {
                              if (run.notes != "") {
                                return Column(
                                  children: [
                                    Divider(),
                                    Text(
                                      run.notes,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList()
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add run"),
        icon: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRunPage()),
          ).then((_) => setState(() {}));
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

  void submitForm () async {
    if (formKey.currentState?.validate() == true) {
      formKey.currentState?.save();
      // Add run to database
      int timeInSeconds = (_hours*60 + _minutes)*60 + _seconds;
      var run = Run(
        title: _title,
        distance: _distance,
        unit: _unit,
        time: timeInSeconds,
        type: _type,
        notes: _notes,
      );
      print(run);
      await RunsDatabase.instance.addRun(run);
      // return to homepage
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Add Run"),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
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
                              validator: (value) {
                                if (value != "" && int.tryParse(value) == null) {
                                  return "Must be an integer";
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value != "" && int.tryParse(value) == null) {
                                  return "Must be an integer";
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value != "" && int.tryParse(value) == null) {
                                  return "Must be an integer";
                                }
                                return null;
                              },
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
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Notes",
                        ),
                        maxLines: 3,
                        onSaved: (value) => _notes = value!,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(textStyle: TextStyle(fontSize: 15)),
                  onPressed: submitForm,
                  child: Text("Save"),
                ),
              ),
            ],
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
    required this.validator,
  });

  final String labelText;
  final void Function(int value) intValueSetter;
  final Function(String value) validator;

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
        return validator(value!);
      },
      onSaved: (newValue) {
        if (newValue == "") {
          intValueSetter(0);
        } else {
          intValueSetter(int.parse("$newValue"));
        }
      },
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
        if (value == "") {
          return "Required";
        } else if (double.tryParse(value!) == null) {
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
          return "Required";
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