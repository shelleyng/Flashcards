import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ViewAllFlashcardsPage extends StatefulWidget {
  @override
  _ViewAllFlashcardsPageState createState() => _ViewAllFlashcardsPageState();
}

class _ViewAllFlashcardsPageState extends State<ViewAllFlashcardsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final databaseReference = FirebaseDatabase.instance.ref();
  List<String> allFlashcards = [];
  List<String> recentFlashcards = [];

  @override
  void initState() {
    super.initState();
    // Fetch all flashcards from Firebase
    _fetchFlashcards();
  }

  void _fetchFlashcards() {
    databaseReference.child('flashcards/${user.uid}').get().then((snapshot) {
      if (snapshot.exists) {
        // Ensure snapshot.value is a Map
        if (snapshot.value is Map) {
          setState(() {
            // Convert map values to a list of strings
            recentFlashcards = List<String>.from((snapshot.value as Map).values);
          });
        } else {
          // Handle case when the value is not a map (if needed)
          print("Data is not a Map");
        }
      }
    }).catchError((error) {
      print("Error fetching flashcards: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Flashcards"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: allFlashcards.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(allFlashcards[index]),
            );
          },
        ),
      ),
    );
  }
}