import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageData {
  File file;
  String personName;

  ImageData(this.file, this.personName);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ImageData> _images = [];
  double _imageWidth = 200; // Initial width of each image in the grid

  Future _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      setState(() {
        _images.insert(0, ImageData(file, "John Doe"));
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Upload'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _getImage,
          ),
        ],
      ),
      body: ListView.builder(
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
    );
  }

  Widget _buildGridItem(ImageData imageData) {
    final imageFile = imageData.file;
    return GestureDetector(
      onTap: () {
        _showImageDialog(imageFile);
      },
      child: FutureBuilder<double>(
        future: _calculateImageAspectRatio(imageFile),
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(); // Placeholder widget while calculating aspect ratio
          } else if (snapshot.hasData) {
            final aspectRatio = snapshot.data!;
            final height = _imageWidth / aspectRatio;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    imageFile,
                    width: _imageWidth,
                    height: height,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(imageData.personName),
                    IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () {
                        _saveImage(imageFile);
                      },
                    ),
                  ],
                ),
              ],
            );
          } else {
            return SizedBox(); // Placeholder widget when aspect ratio calculation fails
          }
        },
      ),
    );
  }

  Future<double> _calculateImageAspectRatio(File imageFile) async {
    final image = Image.file(imageFile);
    final completer = Completer<double>();
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      final aspectRatio = info.image.width / info.image.height;
      completer.complete(aspectRatio);
    });

    image.image.resolve(ImageConfiguration()).addListener(listener);

    return completer.future;
  }
}
