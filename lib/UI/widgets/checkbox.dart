import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool? _isChecked; // Nullable bool value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkbox Example'),
      ),
      body: Center(
        child: Checkbox(
          value: _isChecked ??
              false, // Provide a default value if _isChecked is null
          onChanged: (value) {
            setState(() {
              _isChecked = value; // Update _isChecked with the new value
            });
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyWidget(),
  ));
}
