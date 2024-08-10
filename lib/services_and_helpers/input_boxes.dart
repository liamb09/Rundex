import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

import 'User.dart';

class IntInputBox extends StatelessWidget {
  const IntInputBox({
    super.key,
    required this.labelText,
    required this.value,
    required this.intValueSetter,
    required this.validator,
  });

  final String labelText;
  final String value;
  final void Function(int value) intValueSetter;
  final Function(String value) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
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
    required this.value,
    required this.doubleValueSetter,
  });

  final String labelText;
  final String value;
  final void Function(double? value) doubleValueSetter;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //initialValue: value,
      controller: TextEditingController(text: value),
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
      onChanged: (value) => doubleValueSetter(value == "" ? 0 : double.tryParse(value)),
      onSaved: (newValue) => doubleValueSetter(newValue == "" ? 0.0 : double.parse("$newValue")),
    );
  }
}

class InputBox extends StatelessWidget {
  const InputBox({
    super.key,
    required this.labelText,
    required this.value,
    required this.setter,
    required this.validator,
    this.maxLines,
    this.keyboardType,
  });

  final String labelText;
  final String value;
  final void Function(String value) setter;
  final String? Function (String value) validator;
  final int? maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      keyboardType: keyboardType,
      initialValue: value,
      onSaved:  (newValue) => setter("$newValue"),
      validator: (value) => validator(value!),
      maxLines: maxLines,
    );
  }
}

class WorkoutStructureFormField extends StatelessWidget {
  const WorkoutStructureFormField({
    super.key,
    required this.repsValue,
    required this.descriptionValue,
    required this.paceValue,
    required this.repsSetter,
    required this.descriptionSetter,
    required this.paceSetter,
    required this.repsValidator,
    required this.descriptionValidator,
    required this.user,
    required this.routeSetter,
    required this.mileageImageSetter,
  });

  final String repsValue;
  final String descriptionValue;
  final dynamic paceValue;
  final void Function(String value) repsSetter;
  final void Function(String value) descriptionSetter;
  final void Function(dynamic value) paceSetter;
  final Function(String value) repsValidator;
  final Function(String value) descriptionValidator;
  final User user;
  final Function(MapEntry<String, Map<Uint8List?, double?>>? value) routeSetter;
  final Function() mileageImageSetter;

  Future<User> getUserFromDB () async {
    var user = await UserDatabase.instance.getUser();
    //UserDatabase.instance.clearDatabase();
    if (user.isEmpty) {
      UserDatabase.instance.addDefaultUser();
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }

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
    return FutureBuilder<User>(
      future: getUserFromDB(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data;
        if (user == null) {
          return CircularProgressIndicator();
        }
        return Row(
          children: [
            SizedBox(
              width: 65,
              child: TextFormField(
                initialValue: repsValue,
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
                //initialValue: descriptionValue,
                controller: TextEditingController(text: descriptionValue),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Description"),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(40),
                ],
                validator: (value) {
                  return descriptionValidator(value!);
                },
                onSaved: (value) {
                  descriptionSetter(value!);
                },
                onChanged: (value) {
                  descriptionSetter(value);
                },
              ),
            ),
            SizedBox(width: 4),
            Builder(
              builder: (context) {
                if (paceValue != null) {
                  return Row(
                    children: [
                      Text(
                        "@ ${paceValue is String ? "$paceValue pace" : "${secondsToTime(paceValue!)}/${user.distUnit}"}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                    ],
                  );
                }
                return Container();
              },
            ),
            IconButton(
              icon: Icon(Icons.timer_outlined),
              onPressed: () {
                final formKey = GlobalKey<FormState>();
                int _minutes = 0;
                int _seconds = 0;
                if (paceValue != null && paceValue is! String) {
                  _minutes = (paceValue! / 60).floor();
                  _seconds = paceValue! % 60;
                }
                String paceType = "time";
                String relativePace = "";
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Set pace for \"$descriptionValue\"",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(height: 12),
                                  CupertinoSlidingSegmentedControl(
                                    groupValue: paceType,
                                    onValueChanged: (String? value) {
                                      setState(() => paceType = value!);
                                    },
                                    children: <String, Widget>{
                                      "time": Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        child: Text("min/${user.distUnit}"),
                                      ),
                                      "relative": Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        child: Text("Relative")
                                      )
                                    },
                                  ),
                                  SizedBox(height: 12),
                                  Builder(
                                    builder: (context) {
                                      if (paceType == "time") {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 60,
                                              child: IntInputBox(
                                                value: _minutes != 0 ? "$_minutes" : "",
                                                labelText: "MIN",
                                                intValueSetter: (value) => _minutes = value,
                                                validator: (value) {
                                                  if (value != "" && int.tryParse(value) == null) {
                                                    return "# only";
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
                                            SizedBox(
                                              width: 60,
                                              child: IntInputBox(
                                                value: _seconds != 0 ? "$_seconds" : "",
                                                labelText: "SEC",
                                                intValueSetter: (value) => _seconds = value,
                                                validator: (value) {
                                                  if (value != "" && int.tryParse(value) == null) {
                                                    return "# only";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 6,),
                                            Text("/${user.distUnit}", style: const TextStyle(fontSize: 20)),
                                          ],
                                        );
                                      }
                                      return Container();
                                    }
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (paceType == "relative") {
                                        return TextFormField(
                                          initialValue: "",
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Relative pace",
                                          ),
                                          onSaved: (value) {
                                            relativePace = value!;
                                          },
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MaterialButton(
                              color: Theme.of(context).cardColor.darken(20),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text("Cancel", style: TextStyle(
                                  color: Provider.of<ThemeProvider>(context).themeData == lightMode ? Colors.black : Colors.white,
                                ),),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(width: 10,),
                            MaterialButton(
                              color: Theme.of(context).colorScheme.secondary,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text("Save", style: TextStyle(color: Provider.of<ThemeProvider>(context).themeData == lightMode ? Colors.white : Colors.black),),
                              ),
                              onPressed: () {
                                if (formKey.currentState?.validate() == true) {
                                  formKey.currentState?.save();
                                  if (paceType == "time") {
                                    paceSetter(_minutes*60 + _seconds);
                                  } else {
                                    paceSetter(relativePace);
                                  }
                                  Navigator.pop(context);
                                }
                              },
                            )
                          ],
                        )
                      ],
                    );
                  }
                );
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.route_outlined),
            //   onPressed: () {
            //     MapEntry<String, Map<Uint8List?, double?>>? chosenRoute;
            //     List<DropdownMenuItem<Object>>? userRoutes = [];
            //     for (String route in user.routes!.keys) {
            //       userRoutes.add(DropdownMenuItem(value: route, child: Text(route)));
            //     }
            //     showDialog(
            //       context: context,
            //       builder: (context) {
            //         return AlertDialog(
            //           backgroundColor: Theme.of(context).colorScheme.tertiary,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(15),
            //           ),
            //           content: StatefulBuilder(
            //             builder: (BuildContext context, StateSetter setState) {
            //               return Padding(
            //                 padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            //                 child: Column(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   mainAxisSize: MainAxisSize.min,
            //                   children: [
            //                     Text(
            //                       "Choose a route",
            //                       style: TextStyle(fontSize: 20),
            //                     ),
            //                     SizedBox(height: 12,),
            //                     DropdownButtonFormField(
            //                       decoration: InputDecoration(
            //                         border: OutlineInputBorder(),
            //                         labelText: "Route",
            //                       ),
            //                       items: userRoutes,
            //                       onChanged: (value) {
            //                         chosenRoute = user.routes!.entries.elementAt(user.routes!.keys.toList().indexOf(value as String));
            //                       },
            //                     ),
            //                   ],
            //                 ),
            //               );
            //             },
            //           ),
            //           actionsAlignment: MainAxisAlignment.center,
            //           actions: [
            //             Row(
            //               mainAxisSize: MainAxisSize.min,
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 MaterialButton(
            //                   color: Theme.of(context).cardColor.darken(20),
            //                   child: Padding(
            //                     padding: const EdgeInsets.all(6),
            //                     child: Text("Cancel", style: TextStyle(
            //                       color: Provider.of<ThemeProvider>(context).themeData == lightMode ? Colors.black : Colors.white,
            //                     ),),
            //                   ),
            //                   onPressed: () {
            //                     Navigator.pop(context);
            //                   },
            //                 ),
            //                 SizedBox(width: 10,),
            //                 MaterialButton(
            //                   color: Theme.of(context).colorScheme.secondary,
            //                   child: Padding(
            //                     padding: const EdgeInsets.all(6),
            //                     child: Text("Choose", style: TextStyle(color: Provider.of<ThemeProvider>(context).themeData == lightMode ? Colors.white : Colors.black),),
            //                   ),
            //                   onPressed: () {
            //                     Navigator.pop(context);
            //                     routeSetter(chosenRoute);
            //                     mileageImageSetter();
            //                   },
            //                 )
            //               ],
            //             )
            //           ],
            //         );
            //       }
            //     );
            //   },
            // ),
          ],
        );
      }
    );
  }
}