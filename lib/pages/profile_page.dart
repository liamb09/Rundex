import 'package:flutter/material.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:running_log/services_and_helpers/profile_edit_field.dart';

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

  String? newUnit;
  String inEdit = "";

  @override
  Widget build(BuildContext context) {

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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        userData.name.substring(0, 1),
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 100),
                      )
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(
                    height: 0,
                    thickness: 1,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text("Name")),
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
                  Divider(
                    height: 0,
                    thickness: 1,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text("Age")),
                      ProfileEditField(
                        value: "${userData.age}",
                        identifier: "age",
                        inEdit: inEdit == "age",
                        user: userData,
                        intOnly: true,
                        toggleEdit: () {
                          setState(() {
                            if (inEdit == "age") {
                              inEdit = "";
                            } else {
                              inEdit = "age";
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  // Divider(),
                  // Row(
                  //   children: [
                  //     Expanded(child: Text("Height")),
                  //     Expanded(child: Text("${userData.height}", textAlign: TextAlign.right,)),
                  //   ],
                  // ),
                  // Divider(),
                  // Row(
                  //   children: [
                  //     Expanded(child: Text("Weight")),
                  //     Expanded(child: Text("${userData.weight}", textAlign: TextAlign.right,)),
                  //   ],
                  // ),
                  Divider(
                    height: 0,
                    thickness: 1,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text("Weekly mileage goal")),
                      ProfileEditField(
                        value: "${userData.goal}",
                        identifier: "goal",
                        inEdit: inEdit == "goal",
                        user: userData,
                        intOnly: true,
                        toggleEdit: () {
                          setState(() {
                            if (inEdit == "goal") {
                              inEdit = "";
                            } else {
                              inEdit = "goal";
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Divider(
                    height: 0,
                    thickness: 1,
                  ),
                  // todo: put dropdown when clicked to edit units
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(child: Text("Units")),
                        Row(
                          children: [
                            Card(
                              color: userData.distUnit == "mi" ? Theme.of(context).colorScheme.secondary : null,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  if (userData.distUnit != "mi") {
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                  child: Text("mi", style: TextStyle(color: userData.distUnit == "mi" ? Theme.of(context).colorScheme.tertiary : null),),
                                ),
                              ),
                            ),
                            SizedBox(width: 2,),
                            Text("|"),
                            SizedBox(width: 2,),
                            Card(
                              color: userData.distUnit == "km" ? Theme.of(context).colorScheme.secondary : null,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  if (userData.distUnit != "km") {
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
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                  child: Text("km", style: TextStyle(color: userData.distUnit == "km" ? Theme.of(context).colorScheme.tertiary : null),),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0,
                    thickness: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}