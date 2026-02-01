import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About SINO")),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              "SINO v1.0",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Your AI Companion for Learning and Mindfulness.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text("Created for the User"),
          ],
        ),
      ),
    );
  }
}
