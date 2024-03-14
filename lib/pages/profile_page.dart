import 'package:flutter/material.dart';
import 'package:running_log/pages/settings_page.dart';

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