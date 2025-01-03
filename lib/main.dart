import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/HomePage.dart';
import 'views/EventsPage.dart';
import 'package:hedieaty_app/views/ProfilePage.dart';
import 'package:hedieaty_app/NotificationsPage.dart';
import 'package:hedieaty_app/views/LoginPage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MainScreen(), // Set MainScreen as the starting point
    initialRoute: '/',
    routes: {
      '/': (context) => LoginPage(),
      '/home': (context) => MainScreen(),
      '/login': (context) => LoginPage(),
    }
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;  // Track the current index of BottomNavigationBar

  // List of widgets representing each page
  final List<Widget> _pages = [
    HomePage(),
    EventListPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hedieaty'),
      ),
      body: IndexedStack(
        index: _currentIndex,  // Show the selected page
        children: _pages,      // Page content
      ),
      bottomNavigationBar: ClipPath(
        clipper: RoundedTopNavClipper(),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          iconSize: 30,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper for Rounded Top Corners
class RoundedTopNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double roundnessFactor = 30.0;

    // Start at the top-left of the widget
    path.moveTo(0, roundnessFactor);
    path.quadraticBezierTo(0, 0, roundnessFactor, 0); // Top-left rounded corner
    path.lineTo(size.width - roundnessFactor, 0);
    path.quadraticBezierTo(size.width, 0, size.width, roundnessFactor); // Top-right rounded corner
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height); // Bottom line
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}



