import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class person extends StatelessWidget {
  const person({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 100,
          leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.account_balance),
          ),
          title: Text(
            'profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset('image/girl.jpg')),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'profile ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 25),
                ),
                Text(
                  'sobin2000@gmail.com',
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'edit profile',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: BorderSide.none,
                        shadowColor: Color.fromARGB(255, 105, 104, 101),
                        shape: StadiumBorder()),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(),
                profilemenuwidget(
                  endicon: true,
                  icons: '',
                  onpress: () {},
                  title: '',
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 4, // Number of grid items
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.grey,
                      child: Center(
                        child: Text('Item $index'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class profilemenuwidget extends StatelessWidget {
  const profilemenuwidget({
    Key? key,
    required this.title,
    required this.icons,
    required this.onpress,
    this.color,
    required this.endicon,
  });

  final String title;
  final String icons;
  final VoidCallback onpress;
  final Color? color;
  final bool endicon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onpress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color.fromARGB(255, 132, 54, 204),
        ),
        child: Icon(
          LineAwesomeIcons.cog,
          color: Colors.black,
        ),
      ),
      title: Text('menu'),
      trailing: endicon
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Color.fromARGB(255, 180, 176, 180),
              ),
              child: Icon(
                LineAwesomeIcons.angle_right,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
