import 'package:flutter/material.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:tinycolor2/tinycolor2.dart';

class CustomizeTypesAndColorsPage extends StatefulWidget {
  @override
  State<CustomizeTypesAndColorsPage> createState() => _CustomizeTypesAndColorsPageState();
}

class _CustomizeTypesAndColorsPageState extends State<CustomizeTypesAndColorsPage> {

  Future<User> getUserFromDB () async {
    var user = await UserDatabase.instance.getUser();
    if (user.isEmpty) {
      UserDatabase.instance.addUser(User (
        name: "First Last",
        age: 30,
        height: 100,
        weight: 100,
        types: ["N/A", "Easy Run", "Long Run", "Race"],
        colors: ["", "", "", ""]
      ));
      user = await UserDatabase.instance.getUser();
    }
    return user[0];
  }

  Color strToColor (String str) {
    return Color(int.parse(str, radix: 16) + 0xFF000000);
  }

  @override
  Widget build (BuildContext context) {

    Future<User> user = getUserFromDB();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Customize run types", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<User>(
        future: user,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          var userData = snapshot.data;
          if (userData == null) {
            return Center(child: Text("null"));
          }
          return ListView.builder(
            itemCount: userData.types.length,
            itemBuilder: (context, index) {
              var type = userData.types[index];
              var color = userData.colors[index];
              return ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(type == "N/A" ? "Default" : type)),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: strToColor(color)
                        ),
                        onPressed: () {
                          print(Theme.of(context).colorScheme.tertiary);
                          String prevColor = color;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AlertDialog(
                                    title: Text("Change color of \"${type == "N/A" ? "Default" : type}\""),
                                    content: ColorPicker(
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
                                      color: strToColor(color),
                                      onColorChanged: (Color c) {},
                                    ),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      MaterialButton(
                                        color: Theme.of(context).cardColor.darken(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Text("Cancel", style: TextStyle(
                                            color: Theme.of(context).colorScheme.tertiary == Colors.white ? Colors.black : Colors.white,
                                          ),),
                                        ),
                                        onPressed: () {
                                          color = prevColor;
                                          Navigator.pop(context);
                                        },
                                      ),
                                      MaterialButton(
                                        color: Theme.of(context).colorScheme.secondary,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Text("Select", style: TextStyle(
                                            color: Theme.of(context).colorScheme.tertiary,
                                          ),),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          );
                        },
                        child: Container(),
                      ),
                    )
                  ],
                )
              );
            },
          );
        }
      ),
    );
  }
}