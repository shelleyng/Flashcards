import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'flashcardpractice.dart';
import 'homepage.dart';

class CreateFlashcardPage extends StatefulWidget {
  @override
  _CreateFlashcardPageState createState() => _CreateFlashcardPageState();
}

class _CreateFlashcardPageState extends State<CreateFlashcardPage> {
  final _titleController = TextEditingController();
  final _wordController = TextEditingController();
  final _definitionController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  final databaseReference = FirebaseDatabase.instance.ref();

  // List to hold added words and definitions
  List<Map<String, String>> wordsAndDefinitions = [];
  int? _editingIndex;  // To track the index of the word being edited

  // Function to add a word and its definition to the list
  void _addWordToFlashcard() {
    final word = _wordController.text;
    final definition = _definitionController.text;

    if (word.isNotEmpty && definition.isNotEmpty) {
      setState(() {
        if (_editingIndex != null) {
          // If we're editing, update the existing word and definition
          wordsAndDefinitions[_editingIndex!] = {'word': word, 'definition': definition};
          _editingIndex = null;  // Reset editing index after updating
        } else {
          // Add new word-definition pair to the list
          wordsAndDefinitions.add({'word': word, 'definition': definition});
        }
      });

      // Clear the text fields after adding or editing the word-definition pair
      _wordController.clear();
      _definitionController.clear();
    }
  }

  // Function to delete a word from the list
  void _deleteWord(int index) {
    setState(() {
      wordsAndDefinitions.removeAt(index);
    });
  }

  // Function to edit a word
  void _editWord(int index) {
    setState(() {
      // Set the text fields to the word and definition for editing
      _wordController.text = wordsAndDefinitions[index]['word']!;
      _definitionController.text = wordsAndDefinitions[index]['definition']!;
      _editingIndex = index; // Track the index of the word being edited
    });
  }

  // Save flashcard set to Firebase
  void _saveFlashcard() {
    final title = _titleController.text;

    if (title.isNotEmpty && wordsAndDefinitions.isNotEmpty) {
      // Save the flashcard set to Firebase
      databaseReference.child('flashcards/${user.uid}/$title').set({
        'flashcards': wordsAndDefinitions,
      }).then((_) {
        // After saving, navigate to the FlashcardPracticePage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashcardPracticePage(
              flashcards: wordsAndDefinitions, // Pass the flashcards to practice page
            ),
          ),
        );
      }).catchError((error) {
        print("Error saving flashcards: $error");
      });
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Flashcard Set'),
          content: Text('Are you sure you want to delete this flashcard set?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Proceed to delete the flashcard set
                _deleteFlashcardSet();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete the flashcard set from Firebase and navigate back to the HomePage
  void _deleteFlashcardSet() async {
    final title = _titleController.text; // The set title entered by the user

    if (title.isNotEmpty) {
      try {
        print('Deleting flashcard set from path: flashcards/${user.uid}/$title');

        // Delete the flashcard set from Firebase
        await databaseReference.child('flashcards/${user.uid}/$title').remove();

        // After deletion, navigate back to the HomePage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false, // Removes all previous routes (HomePage becomes the root)
        );
      } catch (error) {
        print('Error deleting flashcard set: $error');
        // Handle any errors that occur while deleting
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting flashcard set')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Flashcard Set')),
      body: Container(
        color: Colors.lightBlue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input Section
            Text('Title name:', style: TextStyle(fontSize: 18, color: Colors.black)),
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

            // Word and Definition Inputs
            Text('Word:', style: TextStyle(fontSize: 18, color: Colors.black)),
            TextField(
              controller: _wordController,
              decoration: InputDecoration(
                hintText: 'Enter word',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Definition:', style: TextStyle(fontSize: 18, color: Colors.black)),
            TextField(
              controller: _definitionController,
              decoration: InputDecoration(
                hintText: 'Enter definition',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _addWordToFlashcard,
                child: Icon(Icons.add, size: 24),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  backgroundColor: Colors.lightBlueAccent.shade100,
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Display word count
            Text(
              'Words in this set: ${wordsAndDefinitions.length}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 20),

            // List of Words and Definitions with Edit and Delete Icons
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
                      contentPadding: EdgeInsets.all(16),
                      title: Text('${wordsAndDefinitions[index]['word']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${wordsAndDefinitions[index]['definition']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Edit word
                              _editWord(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Delete word
                              _deleteWord(index);
                            },
                          ),
                        ],
                      ),
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
                    backgroundColor: Colors.purple.shade200,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Show a confirmation dialog before deleting
                    _showDeleteConfirmationDialog();
                  },
                  child: Text('Delete flashcard set'),
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
          ],
        ),
      ),
    );
  }
}
