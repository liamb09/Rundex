import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:running_log/services_and_helpers/GPXHelper.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:running_log/services_and_helpers/RunsDatabase.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/services_and_helpers/input_boxes.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:running_log/services_and_helpers/env.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  List<int?>? _reps;
  List<String>? _descriptions;
  List<MapEntry<String, Map<Uint8List?, double?>>?>? _routes;
  List<Uint8List?>? _images;
  List<int?>? _paces;
  bool cardColor = false;
  Color? otherCardColor;
  int? editID;
  bool setupForEdit = false;
  int? timestamp;
  bool isDateTime = false;
  bool isTime = false;
  Uint8List? image;
  bool distanceSetByRoute = false;
  bool imageSetByRoute = false;

  Future<User> getUserFromDB () async {
    var user = await UserDatabase.instance.getUser();
    //UserDatabase.instance.clearDatabase();
    if (user.isEmpty) {
      UserDatabase.instance.addDefaultUser();
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }

  Future<DateTime?> getDateTime () async {
    DateTime? selectedDate = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime.now(), initialDate: timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp!*1000) : DateTime.now());
    TimeOfDay? selectedTime;
    if (selectedDate != null) {
      selectedTime = await showTimePicker(context: context, initialTime: timestamp == null ? TimeOfDay.fromDateTime(DateTime.now()) : TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(timestamp!*1000)));
    }
    if (selectedTime != null) {
      isTime = true;
    }
    DateTime? dateTime = selectedTime == null ? selectedDate : DateTime(
      selectedDate!.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute
    );
    return dateTime;
  }

  // BUG: distance goes away when you add/subtract sets
  void setMilageAndImage () {
    if (workoutStructure && _routes != null) {
      MapEntry<String, Map<Uint8List?, double?>>? forMileageAndImage;
      bool multiple = false;
      double oldDistance = _distance;
      _distance = 0;
      for (var route in _routes!) {
        if (route != null) {
          if (route.value.keys.first != null || route.value.values.first != null) {
            if (forMileageAndImage == null && !multiple) {
              forMileageAndImage = route;
            } else if (forMileageAndImage != null) {
              multiple = true;
            }
          }
          if ((oldDistance == 0 || distanceSetByRoute)  && route.value.values.first != null) {
            _distance += route.value.values.first!;
            distanceSetByRoute = true;
          }
        }
      }
      if (forMileageAndImage != null) {
        if (image == null) {
          image = forMileageAndImage.value.keys.first;
          imageSetByRoute = true;
        } else if (imageSetByRoute) {
          image = null;
        }
        print(oldDistance);
        if (_distance == 0) {
          _distance = oldDistance;
        }
        // if ((_distance == 0 || distanceSetByRoute) && forMileageAndImage.value.values.first != null) {
        //   _distance += forMileageAndImage.value.values.first!;
        //   distanceSetByRoute = true;
        // }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    var user = getUserFromDB();

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
      workoutStructure = editRun.sets == null ? false : (editRun.sets!.isEmpty ? false : true);
      if (workoutStructure) {
        _numSets = editRun.sets!.length;
        _reps = [];
        _descriptions = [];
        _routes = [];
        _images = [];
        _paces = [];
        for (var entry in editRun.sets!.entries) {
          _descriptions!.add(entry.value[0]);
          _reps!.add(entry.value[2]);
          _images!.add(entry.value[1]);
          _paces!.add(entry.value[3]);
          _routes!.add(null);
        }
      }
      cardColor = editRun.color == "ffebedf3" ? false : true;
      otherCardColor = editRun.color == null ? null : Color(int.parse(editRun.color!.substring(2, 8), radix: 16) + 0xFF000000);
      setupForEdit = true;
      isDateTime = true;
      timestamp = editRun.timestamp;
      image = editRun.image;
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
            child: FutureBuilder<User>(
              future: user,
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                var userData = snapshot.data;
                if (userData == null) {
                  return CircularProgressIndicator();
                }
                if (!setupForEdit) {
                  _unit = userData.distUnit;
                }
                List<DropdownMenuItem> types = [];
                for (String type in userData.runColors.keys) {
                  types.add(DropdownMenuItem(value: type, child: Text(type)));
                }
                return Column(
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
                                    doubleValueSetter: (value) {
                                      _distance = value;
                                      distanceSetByRoute = false;
                                    },
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
                                    onSaved: (value) {
                                      setState(() {
                                        _unit = value!;
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
                                    value: _hours != 0 ? "$_hours" : "",
                                    labelText: "HR",
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
                                    labelText: "MIN",
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
                                    labelText: "SEC",
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
                              items: types,
                              onChanged: (newValue) {
                                setState(() {
                                  _type = newValue!;
                                  String currentCardColor = userData.runColors[_type]!;
                                  if (currentCardColor != "ebedf3") {
                                    otherCardColor = Color(int.parse(currentCardColor, radix: 16) + 0xff000000);
                                    cardColor = true;
                                  } else {
                                    otherCardColor = Color(0xffebedf3);
                                    cardColor = false;
                                  }
                                });
                              },
                              value: _type,
                              validator: (value) {
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
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  value: isDateTime,
                                  onChanged: (bool? value) async {
                                    setState(() {
                                      isDateTime = value!;
                                    });
                                    if (isDateTime) {
                                      DateTime? dateTime = await getDateTime();
                                      if (dateTime != null) {
                                        timestamp = (DateTime.parse(dateTime.toString()).millisecondsSinceEpoch/1000).round();
                                      } else {
                                        setState(() {
                                          isDateTime = false;
                                        });
                                      }
                                    }
                                    setState(() {});
                                  }
                                ),
                                Row(
                                  children: [
                                    Text("Date and time${isDateTime && timestamp != null ? ": ${DateFormat.yMMMEd().format(DateTime.fromMillisecondsSinceEpoch(timestamp!*1000))}" : ""}${isTime && isDateTime ? " at ${DateFormat("hh:mm a").format(DateTime.fromMillisecondsSinceEpoch(timestamp!*1000))}" : ""}", style: TextStyle(fontSize: 15)),
                                    Builder(
                                      builder: (context) {
                                        return isDateTime ? IconButton(
                                          icon: Icon(Icons.edit_outlined),
                                          onPressed: () async {
                                            DateTime? dateTime = await getDateTime();
                                            timestamp = (DateTime.parse(dateTime.toString()).millisecondsSinceEpoch/1000).round();
                                            setState(() {});
                                          },
                                        ) : Container();
                                      }
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Theme.of(context).colorScheme.primary,
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
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  value: workoutStructure,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      workoutStructure = value!;
                                    });
                                    _reps = [];
                                    _descriptions = [];
                                    _routes = [];
                                    _images = [];
                                    _paces = [];
                                    for (var i = _descriptions!.length; i < _numSets; i++) {
                                      _descriptions!.add("");
                                      _reps!.add(null);
                                      _images!.add(null);
                                      _routes!.add(null);
                                      _paces!.add(null);
                                    }
                                  }
                                ),
                                Text("Sets", style: TextStyle(fontSize: 15)),
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
                                            // TODO: make up mileage and add image from routes
                                            result.add(WorkoutStructureFormField(
                                              repsValue: "${_reps?[i] ?? ""}",
                                              descriptionValue: _descriptions![i],
                                              paceValue: _paces![i],
                                              repsSetter: (value) {
                                                _reps?[i] = int.parse(value == "" ? "1" : value);
                                              },
                                              descriptionSetter: (value) {
                                                _descriptions?[i] = value;
                                              },
                                              paceSetter: (value) {
                                                setState(() {
                                                  _paces?[i] = value;
                                                });
                                              },
                                              repsValidator: (value) {
                                                if (value != "" && int.tryParse(value) == null) {
                                                  return "# only";
                                                }
                                                return null;
                                              },
                                              descriptionValidator: (value) {
                                                if (value == "") {
                                                  return "Required";
                                                }
                                                return null;
                                              }, 
                                              user: userData,
                                              routeSetter: (value) {
                                                _routes?.add(value);
                                                setState(() {
                                                  _descriptions![i] = value!.key;
                                                });
                                              },
                                              mileageImageSetter: () {
                                                setMilageAndImage();
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
                                                _descriptions!.removeLast();
                                                _images!.removeLast();
                                                _reps!.removeLast();
                                                _paces!.removeLast();
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
                                                _descriptions!.add("");
                                                _images!.add(null);
                                                _reps!.add(null);
                                                _paces!.add(null);
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
                                  activeColor: Theme.of(context).colorScheme.primary,
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
                                  //cardColor = true;
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
                                    color: otherCardColor ?? Color(int.parse(userData.runColors[_type]!, radix: 16) + 0xff000000),
                                    onColorChanged: (Color color) => setState(() => otherCardColor = color),
                                  );
                                }
                                return Container();
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                              onPressed: () async {
                                final result = await FilePicker.platform.pickFiles(withData: true);
                                if (result != null) {
                                  imageSetByRoute = false;
                                  var file = utf8.decode(result.files.single.bytes as List<int>);
                                  var polyline = await GPXHelper.getPolyline(file);
                                  final response = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/staticmap?size=400x400&style=feature:poi|visibility:off&style=feature:transit|visibility:off&style=feature:administrative|visibility:off&path=color:0x012271ff%7Cenc:$polyline&key=${Env.msApiKey}"));
                                  if (response.statusCode == 200) {
                                    print("Successfully fetched map");
                                    image = await FlutterImageCompress.compressWithList(
                                      response.bodyBytes,
                                      minHeight: 400,
                                      minWidth: 400,
                                      quality: 40
                                    );
                                    setState(() {});
                                  } else {
                                    print("Failed to fetch map");
                                  }
                                }
                              },
                              child: Text("Upload GPS Data"),
                            ),
                            Builder(
                              builder: (context) {
                                if (image != null) {
                                  return Column(
                                    children: [
                                      SizedBox(height: 12,),
                                      Image.memory(image!),
                                    ],
                                  );
                                }
                                return Container();
                              }
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
                          // _reps = [];
                          // _descriptions = [];
                          // _routes = [];
                          // _images = [];
                          // _paces = [];
                          // for (var i = _descriptions!.length; i < _numSets; i++) {
                          //   _descriptions!.add("");
                          //   _reps!.add(null);
                          //   _images!.add(null);
                          //   _routes!.add(null);
                          //   _paces!.add(null);
                          // }
                          if (formKey.currentState?.validate() == true) {
                            formKey.currentState?.save();
                            // Add run to database
                            int timeInSeconds = (_hours*60 + _minutes)*60 + _seconds;
                            Map<int, List<dynamic>> sets = {};
                            if (_descriptions != null) {
                              for (int i = 0; i < _descriptions!.length; i++) {
                                List<dynamic> details = [_descriptions![i], _images![i], _reps![i], _paces![i]];
                                sets.addAll({i : details});
                              }
                            }
                            var run = Run(
                              id: editID,
                              title: _title,
                              distance: _distance,
                              unit: _unit,
                              time: timeInSeconds,
                              perceivedEffort: perceivedEffortRating == null ? null : (perceivedEffortRating!*100).round()/100,
                              type: _type,
                              notes: _notes,
                              sets: workoutStructure ? sets : {},
                              color: cardColor ? (otherCardColor ?? Theme.of(context).colorScheme.secondary).value.toRadixString(16) : "ffebedf3",
                              timestamp: timestamp ?? (DateTime.now().millisecondsSinceEpoch/1000).round(),
                              image: image,
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
                );
              }
            ),
          ),
        );
      }
    );
  }
}