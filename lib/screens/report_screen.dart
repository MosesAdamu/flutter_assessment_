import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _titleController = TextEditingController();
  File? _image;

  String _location = "Not set";

Future<void> _getLocation() async {
  final position = await Geolocator.getCurrentPosition();
  setState(() {
    _location = "${position.latitude}, ${position.longitude}";
  });
}

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Report")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Attach Image"),
            ),
            if (_image != null) Image.file(_image!, height: 200),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Report submitted!")),
                );
              },
              child: Text("Submit Report"),
            ),
          ],
        ),
      ),
    );
  }
}