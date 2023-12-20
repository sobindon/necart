import 'package:flutter/material.dart';

class diagram extends StatelessWidget {
  const diagram({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Chords"),
        ),
        body: Column(
          children: [
            Image.network(
              "https://static.wikia.nocookie.net/naruto/images/d/d6/Naruto_Part_I.png/revision/latest/scale-to-width-down/1200?cb=20210223094656",
              fit: BoxFit.cover,
              height: 603,
              width: 490,
            ),
          ],
        ),
      );
}
