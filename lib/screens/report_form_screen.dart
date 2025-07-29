import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'submissions_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({Key? key}) : super(key: key);

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categories = ['Road Hazard', 'Waste', 'Security', 'Health', 'Others'];
  String? _selectedCategory;
  File? _mediaFile;
  bool _isImage = true;
  bool _isSubmitting = false;
  Position? _location;

  final picker = ImagePicker();

  /// Pick image or video from camera/gallery
  Future<void> _pickMedia(ImageSource source, bool isImage) async {
    final picked = isImage
        ? await picker.pickImage(source: source)
        : await picker.pickVideo(source: source);

    if (picked != null) {
      setState(() {
        _mediaFile = File(picked.path);
        _isImage = isImage;
      });
    }
  }

  /// Get current GPS location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = position;
    });
  }

  /// Upload media and save report
  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty ||
        _selectedCategory == null ||
        _mediaFile == null ||
        _location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    String mediaUrl = '';
    String fileId = const Uuid().v4();

    try {
      // Upload media
      final ref = FirebaseStorage.instance
          .ref()
          .child('reports')
          .child('$fileId.${_isImage ? 'jpg' : 'mp4'}');

      await ref.putFile(_mediaFile!);
      mediaUrl = await ref.getDownloadURL();

      // Save to Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'media_url': mediaUrl,
        'is_image': _isImage,
        'lat': _location!.latitude,
        'lng': _location!.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted!')),
      );

      // Reset fields
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _mediaFile = null;
        _location = null;
        _selectedCategory = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  onPressed: () => _pickMedia(ImageSource.camera, true),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text('Gallery'),
                  onPressed: () => _pickMedia(ImageSource.gallery, true),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.videocam),
                  label: const Text('Video'),
                  onPressed: () => _pickMedia(ImageSource.gallery, false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_mediaFile != null)
              _isImage
                  ? Image.file(_mediaFile!, height: 150)
                  : const Text("Video selected"),
            const SizedBox(height: 10),
            if (_location != null)
              Text('Location: (${_location!.latitude}, ${_location!.longitude})'),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Submit Report'),
                    onPressed: _submitReport,
                  )
          ],
        ),
      ),

      /// FAB to navigate to the submissions screen
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.list),
        label: const Text('My Reports'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmissionsScreen()),
          );
        },
      ),
    );
  }
}
