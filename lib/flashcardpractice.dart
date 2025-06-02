import 'package:flashcards/practicetest.dart';
import 'package:flutter/material.dart';

class FlashcardPracticePage extends StatefulWidget {
  final List<Map<String, String>> flashcards;

  // Constructor to receive flashcards data
  FlashcardPracticePage({required this.flashcards});

  @override
  _FlashcardPracticePageState createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  int currentIndex = 0; // To keep track of the current flashcard
  bool isFlipped = false; // To check if the card is flipped

  // Function to go to the next flashcard
  void _nextFlashcard() {
    setState(() {
      if (currentIndex < widget.flashcards.length - 1) {
        currentIndex++;
        isFlipped = false; // Reset flip state for the new flashcard
      }
    });
  }

  // Function to go to the previous flashcard
  void _previousFlashcard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        isFlipped = false; // Reset flip state for the new flashcard
      }
    });
  }

  // Function to toggle the card between word and definition
  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped; // Flip the card
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentFlashcard = widget.flashcards[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Flashcards'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Flashcard Container
            GestureDetector(
              onTap: _flipCard, // Flip the card when tapped
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey<int>(currentIndex),
                  width: 320, // Increased width for larger text
                  height: 250, // Increased height for larger text
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isFlipped
                          ? currentFlashcard['definition']!
                          : currentFlashcard['word']!,
                      style: TextStyle(
                        fontSize: 20, // Adjusted font size for better fit
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      // Allow text to wrap without truncating it with ellipsis
                      maxLines: null,  // Remove the maxLines limit
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Mastery Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle mastering the word
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You mastered the word!')),
                    );
                  },
                  child: Text('Mastered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle not mastering the word
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Try again later')),
                    );
                  },
                  child: Text('Not Mastered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Navigation Arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _previousFlashcard,
                  icon: Icon(Icons.arrow_back),
                  iconSize: 30,
                  color: Colors.blue,
                ),
                SizedBox(width: 20),
                IconButton(
                  onPressed: _nextFlashcard,
                  icon: Icon(Icons.arrow_forward),
                  iconSize: 30,
                  color: Colors.blue,
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the PracticeTestPage with the current flashcards
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PracticeTestPage(flashcards: widget.flashcards),
                  ),
                );
              },
              child: Text('Practice Questions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade200,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
