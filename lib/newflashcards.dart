import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FlashcardsPage extends StatefulWidget {
  @override
  _FlashcardsPageState createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final _titleController = TextEditingController();
  final _wordController = TextEditingController();
  final _definitionController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  final databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, String>> wordsAndDefinitions = [];

  void _addWordToFlashcard() {
    final word = _wordController.text;
    final definition = _definitionController.text;

    if (word.isNotEmpty && definition.isNotEmpty) {
      setState(() {
        wordsAndDefinitions.add({'word': word, 'definition': definition});
      });
      _wordController.clear();
      _definitionController.clear();
    }
  }

  void _saveFlashcard() {
    final title = _titleController.text;

    if (title.isNotEmpty && wordsAndDefinitions.isNotEmpty) {
      databaseReference.child('flashcards/${user.uid}/$title').set({
        'flashcards': wordsAndDefinitions,
      }).then((_) {
        Navigator.pop(context); // Go back after saving
      }).catchError((error) {
        print("Error saving flashcards: $error");
      });
    }
  }

  void _deleteFlashcardSet() {
    final title = _titleController.text;

    if (title.isNotEmpty) {
      databaseReference.child('flashcards/${user.uid}/$title').remove().then((_) {
        Navigator.pop(context); // Go back after deletion
      }).catchError((error) {
        print("Error deleting flashcard set: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Flashcard Set')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title input
            Text('Title name:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: 'Enter title'),
            ),
            SizedBox(height: 20),

            // Word and Definition Inputs
            Text('Word:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _wordController,
              decoration: InputDecoration(hintText: 'Enter word'),
            ),
            SizedBox(height: 10),
            Text('Definition:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _definitionController,
              decoration: InputDecoration(hintText: 'Enter definition'),
            ),
            SizedBox(height: 20),

            // Add word button (styled as a round button)
            ElevatedButton(
              onPressed: _addWordToFlashcard,
              child: Icon(Icons.add, size: 24),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(), backgroundColor: Colors.lightBlueAccent,
                padding: EdgeInsets.all(16),
              ),
            ),
            SizedBox(height: 20),

            // Display words and definitions
            Text('Words in this set:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: wordsAndDefinitions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text('${wordsAndDefinitions[index]['word']}'),
                      subtitle: Text('${wordsAndDefinitions[index]['definition']}'),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Finish and Delete Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveFlashcard,
                  child: Text('Finish flashcard set'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade200, // Light purple
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _deleteFlashcardSet,
                  child: Text('Delete flashcard set'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade300, // Light purple
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}