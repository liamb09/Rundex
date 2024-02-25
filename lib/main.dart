import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/Run.dart';
import 'package:running_log/RunsDatabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //RunsDatabase.instance.clearDatabase();
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
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff012271), primary: Color(0xff012271), secondary: Color(0xffDEDA00)),
          scaffoldBackgroundColor: Color(0xffFFFFFC),
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
    //var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("Running Log", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff012271),
        iconTheme: IconThemeData(color: Colors.white,),
        actions: <Widget>[
          Row(
            children: [
              Text("You", style: TextStyle(color: Colors.white),),
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Center(child: Text(run.title)),
                        subtitle: Column(
                          children: [
                            Builder(
                              builder: (context) {
                                if (run.type != "N/A") {
                                  return Column(
                                    children: [
                                      SizedBox(height: 5),
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
                            Builder(
                              builder: (context) {
                                if (run.time > 0 && run.distance > 0) {
                                  return Column(
                                    children: [
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
                                    ],
                                  );
                                } else if (run.time > 0 && run.distance == 0) {
                                  return Column(
                                    children: [
                                      Divider(),
                                      Column(
                                        children: [
                                          Text(secondsToTime(run.time)),
                                          Text("Time"),
                                        ],
                                      ),
                                    ],
                                  );
                                } else if (run.time == 0 && run.distance > 0) {
                                  return Column(
                                    children: [
                                      Divider(),
                                      Column(
                                        children: [
                                          Text("${run.distance} ${run.unit}"),
                                          Text("Distance"),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                return SizedBox.shrink();
                              }
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
                            Builder(
                              builder: (context) {
                                List<Widget> result = [];
                                List<Widget> reps = [];
                                List<Widget> descriptions = [];
                                if (run.reps!.isNotEmpty) {
                                  result.add(Divider());
                                  for (int i = 0; i < run.reps!.length; i++) {
                                    reps.add(
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "${run.reps![i]}X",
                                          style: TextStyle(fontWeight: FontWeight.bold,),
                                          textAlign: TextAlign.right,
                                        ),
                                      )
                                    );
                                    descriptions.add(
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          run.descriptions![i],
                                          textAlign: TextAlign.left,
                                        ),
                                      )
                                    );
                                  }
                                  result.add(Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: reps,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        children: descriptions,
                                      ),
                                    ],
                                  ));
                                }
                                return Column(children: result,);
                              },
                            ),
                          ],
                        ),
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
        backgroundColor: Color(0xffDEDA00),
        label: Text("Add run", style: TextStyle(color: Color(0xff012271))),
        icon: IconTheme(data: IconThemeData(color: Color(0xff012271)), child: Icon(Icons.add)),
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
  bool isChecked = false;
  int _numSets = 2;
  List<int>? _reps;
  List<String>? _descriptions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Color(0xff012271),
            title: Text("Add Run", style: TextStyle(color: Colors.white),),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: Column(
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
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              activeColor: Theme.of(context).primaryColor,
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              }
                            ),
                            Text("Workout Structure", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        SizedBox(height: 6),
                        Builder(
                          builder: (context) {
                            if (isChecked) {
                              return Column(
                                children: [
                                  Builder(
                                    builder: (context) {
                                      List<Widget> result = [];
                                      for (int i = 0; i < _numSets; i++) {
                                        result.add(WorkoutStructureFormField(
                                          repsSetter: (value) {
                                            _reps?.add(int.parse(value));
                                          },
                                          descriptionSetter: (value) {
                                            _descriptions?.add(value);
                                          },
                                          repsValidator: (value) {
                                            if (value == "") {
                                              return "Rqd";
                                            } else if (int.tryParse(value) == null) {
                                              return "# only";
                                            }
                                            return null;
                                          },
                                          descriptionValidator: (value) {
                                            if (value == "") {
                                              return "Required";
                                            }
                                            return null;
                                          }
                                        ));
                                        if (i != _numSets-1) {
                                          result.add(SizedBox(height: 12,));
                                        }
                                      }
                                      return Column(children: result,);
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xff012271),
                                          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          if (_numSets > 1) {
                                            _numSets--;
                                            setState(() {});
                                          }
                                        },
                                        child: Text("-", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xff012271),
                                        ),
                                        onPressed: () {
                                          if (_numSets < 10) {
                                            _numSets++;
                                            setState(() {});
                                          }
                                        }, 
                                        child: Text("+", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return Container();
                          }
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffDEDA00),
                      textStyle: TextStyle(color: Color(0xff012271)),
                    ),
                    onPressed: () async {
                      _reps = [];
                      _descriptions = [];
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
                          reps: _reps,
                          descriptions: _descriptions,
                        );
                        print(run);
                        await RunsDatabase.instance.addRun(run);
                        // return to homepage
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class WorkoutStructureFormField extends StatelessWidget {
  const WorkoutStructureFormField({
    super.key,
    required this.repsSetter,
    required this.descriptionSetter,
    required this.repsValidator,
    required this.descriptionValidator,
  });

  final void Function(String value) repsSetter;
  final void Function(String value) descriptionSetter;
  final Function(String value) repsValidator;
  final Function(String value) descriptionValidator;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 65,
          child: TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Reps"),
            ),
            keyboardType: TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            validator: (value) {
              return repsValidator(value!);
            },
            onSaved: (value) {
              repsSetter(value!);
            }
          ),
        ),
        SizedBox(width: 4),
        Text("X", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 4),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Description"),
            ),
            validator: (value) {
              return descriptionValidator(value!);
            },
            onSaved: (value) {
              descriptionSetter(value!);
            }
          ),
        ),
      ],
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
          return null;
        } else if (double.tryParse(value!) == null) {
          return "Must be a number";
        }
        return null;
      },
      onSaved: (newValue) => doubleValueSetter(newValue == "" ? 0.0 : double.parse("$newValue")),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xff012271),
        title: Text("Profile", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(textStyle: TextStyle(fontSize: 15)),
          onPressed: () {
            RunsDatabase.instance.clearDatabase();
          },
          child: Text("Clear Data"),
        ),
      ),
    );
  }
}