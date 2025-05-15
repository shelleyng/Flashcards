import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'newflashcards.dart'; // Import FlashcardsPage

class HomePage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // New Flashcard Set Header
            Text(
              'NEW FLASHCARD SET',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent
              ),
            ),
            SizedBox(height: 24),
            // Create new flashcard set button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FlashcardsPage()),
                );
              },
              child: Text('Create new flashcard set'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,  // Light blue button
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Recent Flashcard Sets Title
            Text(
              'Recent flashcard sets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Recent Flashcard Set List
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('Flashcard set 1'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Flashcard set 2'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Flashcard set 3'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to View all flashcards page
              },
              child: Text('View all', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}