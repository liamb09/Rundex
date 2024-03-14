import 'dart:io';
import 'package:flutter/material.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/services_and_helpers/input_boxes.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class AddRunPage extends StatefulWidget {
  @override
  State<AddRunPage> createState() => _AddRunPageState();
}

class _AddRunPageState extends State<AddRunPage> {
  final formKey = GlobalKey<FormState>();
  String _title = "";
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
  int? editID;
  bool setupForEdit = false;

  @override
  Widget build(BuildContext context) {
    final editRun = ModalRoute.of(context)!.settings.arguments == null ? null : ModalRoute.of(context)!.settings.arguments as Run;
    if (editRun != null && !setupForEdit) {
      editID = editRun.id;
      _title = editRun.title;
      _distance = editRun.distance;
      _unit = editRun.unit;
      _hours = (editRun.time / 3600).floor();
      _minutes = ((editRun.time % 3600) / 60).floor();
      _seconds = editRun.time % 60;
      _type = editRun.type;
      _notes = editRun.notes;
      perceivedEffort = editRun.perceivedEffort == null ? false : true;
      perceivedEffortRating = editRun.perceivedEffort;
      workoutStructure = editRun.reps == null ? false : (editRun.reps!.isEmpty ? false : true);
      _numSets = editRun.reps!.length;
      _reps = editRun.reps?.cast<int>();
      _descriptions = editRun.descriptions?.cast<String>();
      cardColor = editRun.color == null ? false : true;
      otherCardColor = editRun.color == null ? null : Color(int.parse(editRun.color!.substring(2, 8), radix: 16) + 0xFF000000);
      setupForEdit = true;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(editRun == null ? "Add a run" : "Edit run", style: TextStyle(color: Colors.white),),
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
                          value: _title,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Flexible(
                              child: DoubleInputBox(
                                labelText: "Distance",
                                doubleValueSetter: (value) => _distance = value,
                                value: _distance == 0 ? "" : "$_distance",
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
                                value: _hours != 0 || _hours == null ? "$_hours" : "",
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
                                value: _minutes != 0 ? "$_minutes" : "",
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
                                value: _seconds != 0 ? "$_seconds" : "",
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
                          initialValue: _notes,
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
                                          repsValue: "${_reps?[i] ?? ""}",
                                          descriptionValue: _descriptions?[i] ?? "",
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
                          id: editID,
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
                        if (editID == null) {
                          await RunsDatabase.instance.addRun(run);
                        } else {
                          await RunsDatabase.instance.updateRun(run);
                        }
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