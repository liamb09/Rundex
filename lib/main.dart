import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/GPXHelper.dart';
import 'package:running_log/Run.dart';
import 'package:running_log/RunsDatabase.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //print(GPXHelper.coordsToPolyline(GPXHelper.gpxToLatLong(await GPXHelper.readFromFile("assets/example_run.gpx"))));
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Running Log',
        theme: Provider.of<ThemeProvider>(context).themeData,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text("Running Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        child: Card(
                          elevation: 3,
                          color: run.color == null ? null : Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                run.title, 
                                style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
                              ),
                            ),
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
                                            child: Text(run.type, style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                          ),
                                        ],
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                                Builder(
                                  builder: (context) {
                                    if (run.perceivedEffort != null) {
                                      return Column(
                                        children: [
                                          Divider(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("Perceived Effort: ", style: TextStyle(fontWeight: FontWeight.bold, color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                              Text("${run.perceivedEffort} / 10", style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                                Builder(
                                  builder: (context) {
                                    if (run.time > 0 && run.distance > 0) {
                                      return Column(
                                        children: [
                                          Divider(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Text("${run.distance} ${run.unit}", style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                                    Text("Distance", style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Text(secondsToTime(run.time), style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                                    Text("Time", style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
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
                                          Divider(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
                                          Column(
                                            children: [
                                              Text(secondsToTime(run.time), style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                              Text("Time", style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else if (run.time == 0 && run.distance > 0) {
                                      return Column(
                                        children: [
                                          Divider(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
                                          Column(
                                            children: [
                                              Text("${run.distance} ${run.unit}", style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
                                              Text("Distance", style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),),
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
                                          Divider(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
                                          Text(
                                            run.notes,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
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
                                      result.add(Divider(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)));
                                      for (int i = 0; i < run.reps!.length; i++) {
                                        reps.add(
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "${run.reps![i]}X",
                                              style: TextStyle(fontWeight: FontWeight.bold, color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
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
                                              style: TextStyle(color: (run.color != null ? Color(int.parse(run.color!.substring(2, 8), radix: 16) + 0xFF000000).computeLuminance() > 0.5 ? Colors.black : Colors.white : Colors.black)),
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
          //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: CircleBorder(),
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return AddRunPage();
                },
              )).then((_) => setState(() {}));
              // showModalBottomSheet(
              //   context: context,
              //   builder: (context) => SizedBox(height: constraints.maxHeight, child: AddRunPage()),
              // ).then((_) => setState(() {}));
            },
          ),
        );
      }
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
  bool perceivedEffort = false;
  double? perceivedEffortRating;
  bool workoutStructure = false;
  int _numSets = 2;
  List<int>? _reps;
  List<String>? _descriptions;
  bool cardColor = false;
  Color? otherCardColor;

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
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text("Add a run", style: TextStyle(color: Colors.white),),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                              value: perceivedEffort,
                              onChanged: (bool? value) {
                                setState(() {
                                  perceivedEffort = value!;
                                });
                              }
                            ),
                            Text("Perceived Effort", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            if (perceivedEffort) {
                              return Column(
                                children: [
                                  Slider(
                                    value: perceivedEffortRating ?? 5,
                                    min: 0,
                                    max: 10,
                                    inactiveColor: Theme.of(context).colorScheme.secondary,
                                    onChanged: (value) {
                                      setState(() {
                                        perceivedEffortRating = value;
                                      });
                                    },
                                  ),
                                ],
                              );
                            }
                            return Container();
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              activeColor: Theme.of(context).primaryColor,
                              value: workoutStructure,
                              onChanged: (bool? value) {
                                setState(() {
                                  workoutStructure = value!;
                                });
                              }
                            ),
                            Text("Workout Structure", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            if (workoutStructure) {
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
                                          backgroundColor: Theme.of(context).colorScheme.primary,
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
                                          backgroundColor: Theme.of(context).colorScheme.primary,
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
                                  SizedBox(height: 6),
                                ],
                              );
                            }
                            return Container();
                          }
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              activeColor: Theme.of(context).primaryColor,
                              value: cardColor,
                              onChanged: (bool? value) {
                                setState(() {
                                  cardColor = value!;
                                });
                                print(cardColor);
                              }
                            ),
                            Text("Card Color", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            if (cardColor) {
                              return ColorPicker(
                                enableShadesSelection: false,
                                pickersEnabled: <ColorPickerType, bool>{
                                  ColorPickerType.primary: false,
                                  ColorPickerType.accent: false,
                                  ColorPickerType.wheel: true,
                                },
                                height: 40,
                                showColorCode: true,
                                colorCodeHasColor: true,
                                copyPasteBehavior: ColorPickerCopyPasteBehavior(
                                  copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
                                ),
                                color: otherCardColor ?? Theme.of(context).colorScheme.secondary,
                                onColorChanged: (Color color) => setState(() => otherCardColor = color),
                              );
                            }
                            return Container();
                          },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                          perceivedEffort: perceivedEffortRating == null ? null : (perceivedEffortRating!*100).round()/100,
                          type: _type,
                          notes: _notes,
                          reps: _reps,
                          descriptions: _descriptions,
                          color: cardColor ? (otherCardColor ?? Theme.of(context).colorScheme.secondary).value.toRadixString(16) : null,
                        );
                        await RunsDatabase.instance.addRun(run);
                        // return to homepage
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Save", style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                  ),
                ),
                SizedBox(height: 10),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text("Profile", style: TextStyle(color: Colors.white),),
            iconTheme: IconThemeData(color: Colors.white),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return SettingsPage();
                    },
                  ));
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Center(child: 
                      Text(
                        "L",
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 100),
                      )
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Name")),
                      Expanded(child: Text("First Last", textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Age")),
                      Expanded(child: Text("--", textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Height")),
                      Expanded(child: Text("Xft Yin", textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Weight")),
                      Expanded(child: Text("Xlb", textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider()
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Settings", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              Divider(),
              Row(
                children: [
                  Expanded(child: Text("Theme")),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(Provider.of<ThemeProvider>(context).themeData == lightMode ? "Light" : "Dark", textAlign: TextAlign.right,),
                        IconButton(
                          icon: Icon(Provider.of<ThemeProvider>(context).themeData == lightMode ? Icons.light_mode : Icons.dark_mode),
                          onPressed: () {
                            if (Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode) {
                              Provider.of<ThemeProvider>(context, listen: false).themeData = darkMode;
                            } else {
                              Provider.of<ThemeProvider>(context, listen: false).themeData = lightMode;
                            }
                          }
                        ),
                      ],
                    )
                  ),
                ],
              ),
              Divider(),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Expanded(child: Text("Your data", style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
                    Expanded(child: Text("→", textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
                  ],
                ),
              ),
              Divider(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(textStyle: TextStyle(fontSize: 15),),
                onPressed: () {
                  RunsDatabase.instance.clearDatabase();
                  setState(() {});
                },
                child: Text("Clear Data", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}