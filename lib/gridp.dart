// import 'package:gallery_saver/gallery_saver.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class TabbedScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _TabbedScreenState createState() => _TabbedScreenState();
}

Future<ui.Image> loadImage(Uint8List bytes) async {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, (image) => completer.complete(image));
  return completer.future;
}

class _TabbedScreenState extends State<TabbedScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  File? _imageFile; // Added variable to store the selected image file
  int _gridLines = 0; // Number of grid lines

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 107, 105, 103),
        title: Text(
          'Apply grid',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Grid on paper',
            ),
            Tab(
              text: 'Grid setting',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1 content
          Container(
            child: Center(
              child: Stack(
                children: [
                  if (_imageFile !=
                      null) // Conditionally show the image if it's selected
                    Image.file(_imageFile!),
                  if (_gridLines >
                      0) // Conditionally show grid lines if the count is greater than 0
                    CustomPaint(
                      painter: GridPainter(
                        lineCount: _gridLines,
                      ),
                      child: Container(),
                    ),
                ],
              ),
            ),
          ),
          // Tab 2 content
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('image/home.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(
                          255, 21, 22, 22), // Background color of the button
                      onPrimary: Colors.white, // Text color
                      elevation: 8, // Elevation/shadow of the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ), // Padding around the button content
                    ),
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Grid Lines: '),
                      DropdownButton<int>(
                        value: _gridLines,
                        onChanged: (value) {
                          setState(() {
                            _gridLines = value!;
                          });
                        },
                        items: [
                          DropdownMenuItem<int>(
                            value: 0,
                            child: Text('None'),
                          ),
                          DropdownMenuItem<int>(
                            value: 3,
                            child: Text('3'),
                          ),
                          DropdownMenuItem<int>(
                            value: 5,
                            child: Text('5'),
                          ),
                          DropdownMenuItem<int>(
                            value: 8,
                            child: Text('8'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(
                          255, 21, 22, 22), // Background color of the button
                      onPrimary: Colors.white, // Text color
                      elevation: 8, // Elevation/shadow of the button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ), // Padding around the button content
                    ),
                    onPressed: _saveImage,
                    child: Text('Save Image'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      setState(() {
        _imageFile = imageFile; // Update the state with the selected image file
      });
    }
  }

  void _saveImage() async {
    if (_imageFile != null) {
      final bytes = await _imageFile!.readAsBytes();
      final image = await loadImage(bytes);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImage(image, Offset.zero, Paint());

      if (_gridLines > 0) {
        final paint = Paint()
          ..color = ui.Color.fromARGB(255, 0, 0, 0)
          ..strokeWidth = 2.0;

        final width = image.width.toDouble();
        final height = image.height.toDouble();
        final dx = width / (_gridLines + 1);
        final dy = height / (_gridLines + 1);

        for (int i = 1; i <= _gridLines; i++) {
          final x = dx * i;
          final y = dy * i;

          canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
          canvas.drawLine(Offset(0, y), Offset(width, y), paint);
        }
      }

      final picture = recorder.endRecording();
      final imageWithGrid = await picture.toImage(image.width, image.height);

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/image_with_grid.png';
      final imageFile = File(imagePath);

      await imageFile.writeAsBytes(
          (await imageWithGrid.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List());

      await GallerySaver.saveImage(imagePath); // Save the image to the gallery

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No image selected'),
        ),
      );
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class GridPainter extends CustomPainter {
  final int lineCount;

  GridPainter({required this.lineCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 209, 13, 13)
      ..strokeWidth = 1.0;
    final dx = size.width / (lineCount + 1);
    final dy = size.height / (lineCount + 1);

    for (int i = 1; i <= lineCount; i++) {
      final x = dx * i;
      final y = dy * i;

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) =>
      oldDelegate.lineCount != lineCount;
}
