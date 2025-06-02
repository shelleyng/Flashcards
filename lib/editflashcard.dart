import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditFlashcardSetPage extends StatefulWidget {
  final List<Map<String, String>> flashcards;
  final String title;

  EditFlashcardSetPage({required this.flashcards, required this.title});

  @override
  _EditFlashcardSetPageState createState() => _EditFlashcardSetPageState();
}

class _EditFlashcardSetPageState extends State<EditFlashcardSetPage> {
  final _titleController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title; // Set the initial title from the passed data
  }

  // Save the edited flashcard set to Firebase
  void _saveEditedFlashcardSet() async {
    final title = _titleController.text;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && title.isNotEmpty) {
      try {
        // Update the flashcard set in Firebase
        await databaseReference.child('flashcards/${user.uid}/$title').update({
          'title': title,
          'flashcards': widget.flashcards.map((flashcard) {
            return {
              'word': flashcard['word'],
              'definition': flashcard['definition'],
            };
          }).toList(),
        });

        // After saving the changes, navigate back to the HomePage
        Navigator.pop(context);
      } catch (error) {
        print("Error updating flashcard set: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating flashcard set')),
        );
      }
    } else {
      // Handle the case where the user is not logged in
      print('User is not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Flashcard Set'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input Section
            Text('Title:', style: TextStyle(fontSize: 18, color: Colors.black)),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter title',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Editable Flashcards
            Text('Words and Definitions:', style: TextStyle(fontSize: 18, color: Colors.black)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.flashcards.length,
                itemBuilder: (context, index) {
                  final _wordController = TextEditingController();
                  final _definitionController = TextEditingController();

                  // Initialize text controllers with the flashcard's word and definition
                  _wordController.text = widget.flashcards[index]['word']!;
                  _definitionController.text = widget.flashcards[index]['definition']!;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Word ${index + 1}:'),
                          TextField(
                            controller: _wordController,
                            onChanged: (value) {
                              widget.flashcards[index]['word'] = value;
                            },
                          ),
                          SizedBox(height: 8),
                          Text('Definition:'),
                          TextField(
                            controller: _definitionController,
                            onChanged: (value) {
                              widget.flashcards[index]['definition'] = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveEditedFlashcardSet,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade200,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
