import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/services_and_helpers/profile_edit_field.dart';
import 'package:running_log/theme/theme.dart';
import 'package:running_log/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<User> getUserFromDB () async {
    var user = await UserDatabase.instance.getUser();
    //UserDatabase.instance.clearDatabase();
    if (user.isEmpty) {
      UserDatabase.instance.addDefaultUser();
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }

  void setTheme (bool isLight) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("light_mode", isLight);
  }

  String? newUnit;
  String inEdit = "";
  List<Widget> oneTo200 = [];

  @override
  Widget build(BuildContext context) {

    if (oneTo200.isEmpty) {
      for (int i = 1; i <= 200; i++) {
        oneTo200.add(Center(child: Text("$i")));
      }
    }

    Future<User> user = getUserFromDB();

    return FutureBuilder<User>(
      future: user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var userData = snapshot.data;
        if (userData == null) {
          return CircularProgressIndicator();
        }
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text("Profile", textAlign: TextAlign.left, style: TextStyle(
                                fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                                fontWeight: FontWeight.w900,
                              ),),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            userData.name.substring(0, 1),
                            style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 100),
                          )
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Text("Name", style: Theme.of(context).textTheme.titleMedium,)),
                          ProfileEditField(
                            value: userData.name,
                            identifier: "name",
                            inEdit: inEdit == "name",
                            user: userData,
                            intOnly: false,
                            toggleEdit: () {
                              setState(() {
                                if (inEdit == "name") {
                                  inEdit = "";
                                } else {
                                  inEdit = "name";
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Weekly mileage goal",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                InkWell(
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  onTap: () {
                                    if (userData.distUnit == "mi") {
                                      UserDatabase.instance.updateUser(User(
                                        name: userData.name,
                                        age: userData.age,
                                        height: userData.height,
                                        weight: userData.weight,
                                        runColors: userData.runColors,
                                        goal: userData.goal,
                                        distUnit: "km",
                                        routes: userData.routes,
                                      ));
                                      setState(() {});
                                    } else {
                                      UserDatabase.instance.updateUser(User(
                                        name: userData.name,
                                        age: userData.age,
                                        height: userData.height,
                                        weight: userData.weight,
                                        runColors: userData.runColors,
                                        goal: userData.goal,
                                        distUnit: "mi",
                                        routes: userData.routes,
                                      ));
                                      setState(() {});
                                    }
                                  },
                                  child: Text(
                                    userData.distUnit == "mi" ? "Miles" : "Kilometers",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            onTap: () async {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Distance (${userData.distUnit})", style: Theme.of(context).textTheme.titleLarge),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 200,
                                                width: 100,
                                                child: CupertinoPicker(
                                                  itemExtent: 40,
                                                  onSelectedItemChanged: (index) {
                                                    UserDatabase.instance.updateUser(User(
                                                      name: userData.name,
                                                      age: userData.age,
                                                      height: userData.height,
                                                      weight: userData.weight,
                                                      runColors: userData.runColors,
                                                      goal: index+1,
                                                      distUnit: userData.distUnit,
                                                      routes: userData.routes,
                                                    ));
                                                    setState(() {});
                                                  },
                                                  scrollController: FixedExtentScrollController(
                                                    initialItem: userData.goal!-1,
                                                  ),
                                                  children: oneTo200,
                                                ),
                                              ),
                                            ],
                                          ),
                                          MaterialButton(
                                            color: Theme.of(context).colorScheme.primary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    child: Text(
                                                      "OK",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              );
                            },
                            child: Text(
                              userData.goal.toString(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ]
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(child: Text("Theme", style: Theme.of(context).textTheme.titleMedium,)),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Provider.of<ThemeProvider>(context).themeData == lightMode ? Icons.light_mode : Icons.dark_mode),
                            constraints: BoxConstraints(),
                            onPressed: () async {
                              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                              setState(() {});
                              // if (Provider.of<ThemeProvider>(context, listen: false).themeData == lightMode) {
                              //   Provider.of<ThemeProvider>(context, listen: false).themeData = darkMode;
                              //   setTheme(false);
                              // } else {
                              //   Provider.of<ThemeProvider>(context, listen: false).themeData = lightMode;
                              //   setTheme(true);
                              // }
                              // setState(() {});
                            }
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(child: Container()),
                  //     IconButton(
                  //       padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  //       icon: Icon(
                  //         Icons.settings
                  //       ),
                  //       onPressed: () {
                  //         Navigator.push(context, MaterialPageRoute<void>(
                  //           builder: (BuildContext context) {
                  //             return SettingsPage();
                  //           },
                  //         ));
                  //       },
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}