import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/collection_page.dart';
import 'package:flutter_application_1/features/my_drawer.dart';
import 'package:flutter_application_1/screens/notes_page.dart';
import 'package:flutter_application_1/screens/transfer_page.dart';

import '../utils/auth/auth_service.dart';

class IntroPage extends StatelessWidget {
  final String username;

  IntroPage({Key? key})
      : username = AuthService().getCurrentUser()!.email.toString(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Center(
          child: Text(
            'MoneyBestro',
            style: TextStyle(
              fontFamily: 'roboto',
              letterSpacing: 3.0,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome, $username!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'This app is designed to help you manage your finances better.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CollectionPage()),
                );
              },
              child: sectionWidget('Collections', Colors.greenAccent),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransferPage()),
                );
              },
              child: sectionWidget(
                  'Transactions', const Color.fromARGB(255, 202, 111, 227)),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesPage()),
                );
              },
              child: sectionWidget(
                  'Notes', const Color.fromARGB(255, 128, 117, 223)),
            )
          ],
        ),
      ),
    );
  }

  Widget sectionWidget(String title, Color color) {
    return Container(
      width: 350,
      height: 150,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Tap to manage your $title',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        ],
      ),
    );
  }
}
