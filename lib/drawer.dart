import 'package:flutter/material.dart';

import 'person.dart';
import 'profile.dart';

class Neviagater extends StatelessWidget {
  const Neviagater({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('image/drawer.jpg'), fit: BoxFit.cover)),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20),
            buildMenuItem(
              text: 'Log in ',
              icon: Icons.login,
              onClicked: () => SelectedItem(context, 0),
            ),
            const SizedBox(height: 20),
            buildMenuItem(
              text: ' profile',
              icon: Icons.account_circle,
              onClicked: () => SelectedItem(context, 1),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color.fromARGB(255, 35, 33, 33),
          width: 1.50,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        textColor: Color.fromARGB(97, 251, 251, 251),
        title: Text(
          text,
        ),
        leading: Icon(icon),
        onTap: onClicked,
      ),
    );
  }

  void SelectedItem(BuildContext context, int i) {
    switch (i) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => login(),
        ));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => person(),
        ));
        break;
    }
  }
}
