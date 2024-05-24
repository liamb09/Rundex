import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running_log/pages/settings_page.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';

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

  bool editUnits = false;
  String? newUnit;

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
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Name")),
                      Expanded(child: Text(userData.name, textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Age")),
                      Expanded(child: Text("${userData.age}", textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Height")),
                      Expanded(child: Text("${userData.height}", textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Weight")),
                      Expanded(child: Text("${userData.weight}", textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text("Weekly mileage goal")),
                      Expanded(child: Text("${userData.goal != null ? "${userData.goal} ${userData.distUnit}" : "--"} ", textAlign: TextAlign.right,)),
                    ],
                  ),
                  Divider(),
                  // TODO: put dropdown when clicked to edit units
                  Row(
                    children: [
                      Expanded(child: Text("Units")),
                      InkWell(
                        onTap: () {
                          if (!editUnits) {
                            editUnits = true;
                          } else {
                            editUnits = false;
                          }
                          setState(() {});
                        },
                        child: Builder(
                          builder: (context) {
                            if (editUnits) {
                              return DropdownButtonFormField(
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
                                    newUnit = newValue!;
                                  });
                                },
                                value: userData.distUnit,
                                validator: (value) {
                                  if (value != "mi" && value != "km") {
                                    return "Invalid input";
                                  }
                                  return null;
                                },
                              );
                            }
                            return Text(userData.distUnit, textAlign: TextAlign.right,);
                          }
                        )
                      ),
                    ],
                  ),
                  Divider(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}