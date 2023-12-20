import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'drawer.dart';
import 'profile.dart';

class ImageData {
  File file;
  String personName;
  String imageUrl;

  ImageData(this.file, this.personName, this.imageUrl);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  List<ImageData> _images = [];
  double _imageWidth = 190; // Initial width of each image in the grid

  @override
  void initState() {
    super.initState();
    _getUser();
    _loadImages();
  }

  Future<void> _getUser() async {
    final user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  Future<void> _uploadImage(File file) async {
    try {
      // Generate a unique filename for the uploaded image
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Get a reference to the Firebase storage bucket
      final ref =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);

      // Upload the file to Firebase storage
      final uploadTask = ref.putFile(file);

      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL of the uploaded image
      final downloadURL = await snapshot.ref.getDownloadURL();

      // Save the download URL in the ImageData object
      final imageData = ImageData(file, "name", downloadURL);

      setState(() {
        _images.insert(0, imageData);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload successful!")),
      );
    } catch (e) {
      print('Failed to upload image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

  Future<void> _getImage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please sign in to upload images")),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      await _uploadImage(file);
    }
  }

  void _showImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.file(imageFile),
        );
      },
    );
  }

  Future<void> _saveImage(File imageFile) async {
    final directory = await getTemporaryDirectory();
    final imagePath = "${directory.path}/${DateTime.now().toString()}.jpg";
    await imageFile.copy(imagePath);

    final result = await ImageGallerySaver.saveFile(imagePath);
    if (result["isSuccess"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image saved successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save image")),
      );
    }
  }

  Future<void> _loadImages() async {
    final savedImageUrls = await _getSavedImageUrls();

    final savedImages = savedImageUrls.map((imageUrl) {
      final file = File('temp_file.jpg');
      return ImageData(file, "name", imageUrl);
    }).toList();

    setState(() {
      _images.addAll(savedImages);
    });
  }

  Future<List<String>> _getSavedImageUrls() async {
    // Retrieve the saved image URLs from your local storage (e.g., local database, shared preferences)
    // Return the list of saved URLs
    return [
      "https://example.com/image1.jpg",
      "https://example.com/image2.jpg",
      "https://example.com/image3.jpg",
    ];
  }

  Widget _buildGridItem(ImageData imageData) {
    return GestureDetector(
      onTap: () => _showImageDialog(imageData.file),
      onLongPress: () => _saveImage(imageData.file),
      child: Container(
        width: _imageWidth,
        height: _imageWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageData.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('𝑨𝒓𝒕𝒊𝒔𝒕i𝒔 𝑨𝒓𝒕'),
          backgroundColor: Color.fromARGB(255, 107, 105, 103),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('image/signin.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => login()),
                    );
                  },
                  child: Text(
                    'sign in ',
                    style: TextStyle(
                      fontSize: 20,
                      backgroundColor: Colors.black,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        drawer: Neviagater(),
        appBar: AppBar(
          toolbarHeight: 100,
          title: Text(
            '𝑨𝒓𝒕𝒊𝒔𝒕i𝒔 𝑨𝒓𝒕',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 107, 105, 103),
          elevation: 8,
          actions: [
            IconButton(
              icon: Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
              onPressed: _getImage,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('image/home.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView.builder(
            itemCount: (_images.length / 2).ceil(),
            itemBuilder: (BuildContext context, int index) {
              int startIndex = index * 2;
              int endIndex = startIndex + 1;
              if (endIndex >= _images.length) endIndex = _images.length - 1;

              return Row(
                children: [
                  Expanded(
                    child: _buildGridItem(_images[startIndex]),
                  ),
                  if (endIndex < _images.length) SizedBox(width: 8.0),
                  if (endIndex < _images.length)
                    Expanded(
                      child: _buildGridItem(_images[endIndex]),
                    ),
                ],
              );
            },
          ),
        ),
      );
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
