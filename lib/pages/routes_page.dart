import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:running_log/main.dart';
import 'package:running_log/services_and_helpers/GPXHelper.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/services_and_helpers/env.dart';
import 'package:running_log/services_and_helpers/input_boxes.dart';
import 'package:http/http.dart' as http;
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

class RoutesPage extends StatefulWidget {
  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {

  final formKey = GlobalKey<FormState>();
  String _title = "";
  Uint8List? _image;
  double? _distance = -1;
  List<bool?> showMap = [];

  Future<User> getUserFromDB () async {
    var user = await UserDatabase.instance.getUser();
    //UserDatabase.instance.clearDatabase();
    if (user.isEmpty) {
      UserDatabase.instance.addDefaultUser();
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }

  void launchRouteEditor (int? index, User? user) {
    if (index == null) {
      _title = "";
      _image = null;
      _distance = -1;
    }
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
              return Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              index == null || user == null ? "Add a route" : "Edit \"${user.routes!.keys.elementAt(index)}\"",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              if (index != null) {
                                return IconButton(
                                  icon: Icon(Icons.delete_outline),
                                  onPressed: () {
                                    showDialog(context: context, builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        content: Text("Delete \"$_title?\""),
                                        actionsAlignment: MainAxisAlignment.center,
                                        actions: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              MaterialButton(
                                                color: Theme.of(context).cardColor.darken(20),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(6),
                                                  child: Text("Delete", style: TextStyle(
                                                    color: Provider.of<ThemeProvider>(context).themeData == lightMode ? Colors.red.darken(20) : Colors.red.lighten(20),
                                                  ),),
                                                ),
                                                onPressed: () {
                                                  if (user != null) {
                                                    user.routes!.remove(_title);
                                                    var newUser = User(
                                                      name: user.name,
                                                      age: user.age,
                                                      height: user.height,
                                                      weight: user.weight,
                                                      runColors: user.runColors,
                                                      goal: user.goal,
                                                      distUnit: user.distUnit,
                                                      routes: user.routes,
                                                    );
                                                    UserDatabase.instance.updateUser(newUser);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                              ),
                                              SizedBox(width: 10,),
                                              MaterialButton(
                                                color: Theme.of(context).colorScheme.secondary,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(6),
                                                  child: Text("Cancel", style: TextStyle(color: Provider.of<ThemeProvider>(context).themeData == lightMode ? Colors.white : Colors.black),),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              )
                                            ],
                                          )
                                        ],
                                      );
                                    }).then((_) => Navigator.pop(context));
                                  },
                                );
                              }
                              return Container();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        initialValue: _title,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Title",
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                        ],
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return "Required";
                          } else if (user != null && user.routes!.containsKey(value)) {
                            return "Already a route";
                          }
                          return null;
                        },
                        onSaved: (newValue) => setState(() => _title = "$newValue"),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        initialValue: _distance == -1 ? null : "$_distance",
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Distance",
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        validator: (value) {
                          if (value == "") {
                            return null;
                          } else if (double.tryParse(value!) == null || double.parse(value) <= 0) {
                            return "Must be a positive, nonzero number";
                          }
                          return null;
                        },
                        onSaved: (newValue) => newValue == "" ? 0.0 : _distance = double.parse("$newValue"),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        child: Text("Upload GPX Data"),
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(withData: true);
                          if (result != null) {
                            var file = utf8.decode(result.files.single.bytes as List<int>);
                            var polyline = await GPXHelper.getPolyline(file);
                            final response = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/staticmap?size=400x400&style=feature:poi|visibility:off&style=feature:transit|visibility:off&style=feature:administrative|visibility:off&path=color:0x012271ff%7Cenc:$polyline&key=${Env.msApiKey}"));
                            if (response.statusCode == 200) {
                              print("Successfully fetched map");
                              var compressedImage = await FlutterImageCompress.compressWithList(
                                response.bodyBytes,
                                minHeight: 400,
                                minWidth: 400,
                                quality: 40
                              );
                              print("Compressed");
                              setState(() => _image = compressedImage);
                            } else {
                              print("Failed to fetch map");
                            }
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          if (_image != null) {
                            return Column(
                              children: [
                                SizedBox(height: 12),
                                Image.memory(_image!),
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        child: Text("Save"),
                        onPressed: () async {
                          if (formKey.currentState!.validate() == true) {
                            formKey.currentState?.save();
                            var user = await getUserFromDB();
                            if (index == null && user.routes!.isNotEmpty) {
                              user.routes?.addAll({_title : {_image : _distance}});
                            }
                            if (index != null) {
                              Map<String, Map<Uint8List?, double?>>? newRoutes = Map<String, Map<Uint8List?, double?>>.from(user.routes as Map<String, Map<Uint8List?, double?>>);
                              user.routes!.clear();
                              int cnt = 0;
                              for (var entry in newRoutes.entries) {
                                if (cnt == index) {
                                  user.routes!.addAll({_title : {_image : _distance}});
                                } else {
                                  user.routes!.addAll({entry.key : {entry.value.keys.first : entry.value.values.first}});
                                }
                                cnt++;
                              }
                            }
                            var newUser = User(
                              name: user.name,
                              age: user.age,
                              height: user.height,
                              weight: user.weight,
                              runColors: user.runColors,
                              goal: user.goal,
                              distUnit: user.distUnit,
                              routes: user.routes!.isEmpty ? {_title : {_image : _distance}} : user.routes,
                            );
                            UserDatabase.instance.updateUser(newUser);
                            setState(() {});
                            //print(user);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
          actionsAlignment: MainAxisAlignment.center,
        );
      }
    ).then((_) => setState(() {}));
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Customize routes", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                FutureBuilder<User>(
                  future: getUserFromDB(),
                  builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: Text("Loading..."));
                    }
                    if (snapshot.data!.routes == null || snapshot.data!.routes!.isEmpty) {
                      return Center(child: Column(
                        children: [
                          Text("You have no routes."),
                          Divider(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                            child: Text("Add Route"),
                            onPressed: () {
                              _title = "";
                              _image = null;
                              _distance = 0;
                              launchRouteEditor(null, null);
                            },
                          ),
                        ],
                      ));
                    }
                    var entries = snapshot.data!.routes!.entries;
                    for (int i = 0; i < entries.length; i++) {
                      if (i >= showMap.length) {
                        showMap.add(entries.elementAt(i).value.keys.first == null ? null : false);
                      }
                    }
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.routes!.length,
                          itemBuilder: (BuildContext context, int index) {
                            var userData = snapshot.data!;
                            String title = userData.routes!.keys.elementAt(index);
                            Uint8List? image = userData.routes!.values.elementAt(index).keys.elementAt(0);
                            double? distance = userData.routes!.values.elementAt(index).values.elementAt(0);
                            // TODO: add clear map button when editing
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text("$title${distance == null || distance <= 0 ? "" : " ($distance ${userData.distUnit})"}")),
                                    Builder(
                                      builder: (context) {
                                        if (showMap[index] != null) {
                                          return IconButton(
                                            icon: showMap[index]! ? Icon(Icons.map) : Icon(Icons.map_outlined),
                                            onPressed: () {
                                              setState(() => showMap[index] = !showMap[index]!);
                                              setState(() {});
                                            },
                                          );
                                        }
                                        return Container();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined),
                                      onPressed: () {
                                        _title = title;
                                        _image = image;
                                        _distance = distance;
                                        launchRouteEditor(index, snapshot.data!);
                                      },
                                    ),
                                  ]
                                ),
                                Builder(
                                  builder: (context) {
                                    if (showMap[index] != null && showMap[index]!) {
                                      return Image.memory(image!);
                                    }
                                    return Container();
                                  },
                                ),
                                Builder(
                                  builder: (context) {
                                    if (index != snapshot.data!.routes!.length-1) {
                                      return Divider();
                                    }
                                    return Container();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        Divider(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                          child: Text("Add Route"),
                          onPressed: () {
                            _title = "";
                            _image = null;
                            _distance = 0;
                            launchRouteEditor(null, snapshot.data!);
                          },
                        ),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}