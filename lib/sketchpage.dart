import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class SketchConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sketch Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SketchConverterScreen(),
    );
  }
}

class SketchConverterScreen extends StatefulWidget {
  @override
  _SketchConverterScreenState createState() => _SketchConverterScreenState();
}

class _SketchConverterScreenState extends State<SketchConverterScreen>
    with AutomaticKeepAliveClientMixin {
  File? _pickedImage;
  Uint8List? _sketchImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _convertToSketch() async {
    if (_pickedImage != null) {
      final bytes = await _pickedImage!.readAsBytes();
      final image = img.decodeImage(bytes);

      final grayscaleImage = img.grayscale(image!);
      final edgesImage = img.sobel(grayscaleImage);

      final threshold = 90;
      final sketchImage = img.Image(edgesImage.width, edgesImage.height);

      for (var y = 0; y < edgesImage.height; y++) {
        for (var x = 0; x < edgesImage.width; x++) {
          final pixel = edgesImage.getPixel(x, y);
          final intensity = img.getRed(pixel);

          final sketchColor = intensity < threshold ? 0xFFFFFFFF : 0xFF000000;
          sketchImage.setPixel(x, y, sketchColor);
        }
      }

      setState(() {
        _sketchImage = Uint8List.fromList(img.encodePng(sketchImage));
      });
    }
  }

  Future<void> _saveImage() async {
    if (_sketchImage != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/sketch_image.png';

      await File(imagePath).writeAsBytes(_sketchImage!);
      await ImageGallerySaver.saveFile(imagePath);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Sketch image saved to gallery.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No sketch image to save.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that AutomaticKeepAlive is enabled

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 107, 105, 103),
          title: Text('Sketch Converter'),
          toolbarHeight: 100,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('image/home.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    _buildConvertedTab(),
                    _buildSketchTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConvertedTab() {
    return Center(
      child: _pickedImage != null
          ? Image.file(_pickedImage!)
          : Text(
              'please  select image .',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                backgroundColor: Color.fromARGB(255, 20, 20, 20),
              ),
            ),
    );
  }

  Widget _buildSketchTab() {
    return Column(
      children: [
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Pick Image'),
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 0, 5, 8),
            onPrimary: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 24,
            ),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 35, 36, 37),
            onPrimary: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 24,
            ),
          ),
          onPressed: _convertToSketch,
          child: Text('Convert to Sketch'),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 21, 22, 22),
            onPrimary: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 24,
            ),
          ),
          onPressed: _saveImage,
          child: Text('Save Image'),
        ),
        SizedBox(height: 16),
        Expanded(
          child: _sketchImage != null
              ? Image.memory(_sketchImage!)
              : Text(
                  'No sketch image.',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 154, 154, 152),
                    backgroundColor: Colors.black,
                  ),
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true; // Preserve the state of the widget
}
