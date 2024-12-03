import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/task_screen.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Start with the Login Screen
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/tasks': (context) => TaskScreen(),
      },
    );
  }
}
