import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:running_log/services_and_helpers/UserDatabaseHelper.dart';

class ProfileEditField extends StatelessWidget {
  const ProfileEditField({
    super.key,
    required this.value,
    required this.identifier,
    required this.inEdit,
    required this.user,
    required this.intOnly,
    required this.toggleEdit,
  });

  final String value;
  final String identifier;
  final bool inEdit;
  final User user;
  final bool intOnly;
  final void Function() toggleEdit;

  @override
  Widget build (BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      onTap: () {
        toggleEdit();
      },
      child: IntrinsicWidth(
        child: TextField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(5, 5, -3, 5),
            border: InputBorder.none,
            fillColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          selectionWidthStyle: BoxWidthStyle.tight,
          controller: TextEditingController(text: value),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
          textAlign: TextAlign.right,
          enabled: inEdit,
          onSubmitted: (value) async {
            if ((!intOnly || int.tryParse(value) != null) && value != "") {
              toggleEdit();
              var newUser = User(
                name: identifier == "name" ? value : user.name,
                age: identifier == "age" ? int.parse(value) : user.age,
                height: user.height,
                weight: user.weight,
                runColors: user.runColors,
                goal: identifier == "goal" ? int.parse(value) : user.goal,
                distUnit: identifier == "distUnit" ? value : user.distUnit,
                routes: user.routes,
              );
              UserDatabase.instance.updateUser(newUser);
            }
          },
        ),
      )
    );
  }
}