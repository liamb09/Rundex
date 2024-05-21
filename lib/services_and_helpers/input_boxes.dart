import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final void Function(double value) doubleValueSetter;

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
        if (value == "") {
          return null;
        } else if (double.tryParse(value!) == null) {
          return "Must be a number";
        }
        return null;
      },
      onSaved: (newValue) => doubleValueSetter(newValue == "" ? 0.0 : double.parse("$newValue")),
    );
  }
}

class StringInputBox extends StatelessWidget {
  const StringInputBox({
    super.key,
    required this.labelText,
    required this.value,
    required this.strValueSetter,
  });

  final String labelText;
  final String value;
  final void Function(String value) strValueSetter;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
      validator: (value) {
        if (value?.isEmpty == true) {
          return "Required";
        }
        return null;
      },
      onSaved: (newValue) => strValueSetter("$newValue"),
    );
  }
}

class WorkoutStructureFormField extends StatelessWidget {
  const WorkoutStructureFormField({
    super.key,
    required this.repsValue,
    required this.descriptionValue,
    required this.repsSetter,
    required this.descriptionSetter,
    required this.repsValidator,
    required this.descriptionValidator,
  });

  final String repsValue;
  final String descriptionValue;
  final void Function(String value) repsSetter;
  final void Function(String value) descriptionSetter;
  final Function(String value) repsValidator;
  final Function(String value) descriptionValidator;

  @override
  Widget build(BuildContext context) {
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
            initialValue: descriptionValue,
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
            }
          ),
        ),
      ],
    );
  }
}