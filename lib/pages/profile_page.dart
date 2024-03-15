import 'package:flutter/material.dart';
import 'package:running_log/pages/settings_page.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<User> getUserFromDB (String cardColor) async {
    var user = await UserDatabase.instance.getUser();
    //UserDatabase.instance.clearDatabase();
    print(cardColor);
    if (user.isEmpty) {
      UserDatabase.instance.addUser(User (
        name: "First Last",
        age: 30,
        height: 100,
        weight: 100,
        types: ["N/A", "Easy Run", "Long Run", "Race"],
        colors: [cardColor, cardColor, cardColor, cardColor]
      ));
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }

  @override
  Widget build(BuildContext context) {

    Future<User> user = getUserFromDB("ebedf3");

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
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Center(child: 
                      Text(
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