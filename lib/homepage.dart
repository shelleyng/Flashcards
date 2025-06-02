import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'createflashcard.dart';
import 'editflashcard.dart';
import 'flashcardpractice.dart';
import 'loginpage.dart';


class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> flashcardSets = [];

  // Fetch flashcard sets from Firebase
  void _fetchFlashcardSets() {
    databaseReference.child('flashcards/${user.uid}').get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          flashcardSets.clear(); // Clear previous sets before adding the new ones
          Map<dynamic, dynamic> sets = snapshot.value as Map<dynamic, dynamic>;

          sets.forEach((key, value) {
            // Assuming each set has a field "flashcards" containing the list
            List<Map<String, String>> cards = [];
            value['flashcards'].forEach((card) {
              cards.add({
                'word': card['word'] ?? 'No word',
                'definition': card['definition'] ?? 'No definition',
              });
            });

            flashcardSets.add({
              'title': key, // The set title (key)
              'flashcards': cards, // The list of flashcards for this set
            });
          });
        });
      } else {
        print('No flashcard sets available.');
      }
    }).catchError((error) {
      print('Error fetching flashcard sets: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFlashcardSets(); // Load flashcard sets when the page is initialized
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the LoginPage after signing out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to Login Screen
      );
    } catch (error) {
      print('Error signing out: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Sets'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  // Navigate to the CreateFlashcardPage when tapping "NEW FLASHCARD SET"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateFlashcardPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: 250,
                  child: Text(
                    'NEW FLASHCARD SET',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Previous Flashcard Sets Title
            Text(
              'Previous Flashcard Sets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),


            // Show up to 3 flashcard sets
            Expanded(
              child: ListView.builder(
                itemCount: flashcardSets.length > 3 ? 3 : flashcardSets.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(flashcardSets[index]['title'] ?? 'Untitled'),
                      subtitle: Text('Tap to practice'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit), // Edit icon
                        onPressed: () {
                          // Navigate to EditFlashcardSetPage when the edit icon is clicked
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditFlashcardSetPage(
                                flashcards: flashcardSets[index]['flashcards'],
                                title: flashcardSets[index]['title'],
                              ),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        // Navigate to the FlashcardPracticePage when a set is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashcardPracticePage(
                              flashcards: flashcardSets[index]['flashcards'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to another page for viewing all flashcard sets
                  print('View All Flashcards');
                },
                child: Text('View All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}