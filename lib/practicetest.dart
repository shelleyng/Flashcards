import 'dart:math';

import 'package:flutter/material.dart';

class PracticeTestPage extends StatefulWidget {
  final List<Map<String, String>> flashcards;

  PracticeTestPage({required this.flashcards});

  @override
  _PracticeTestPageState createState() => _PracticeTestPageState();
}

class _PracticeTestPageState extends State<PracticeTestPage> {
  List<Map<String, dynamic>> questions = [];
  int score = 0;
  List<String?> selectedOptions = []; // To track selected options for each question

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    // Initialize selected options list with null values (none selected)
    selectedOptions = List.generate(15, (_) => null);
  }

  // Generate questions with randomized options
  void _generateQuestions() {
    List<Map<String, String>> flashcards = widget.flashcards;
    Set<int> usedIndexes = {}; // To make sure we don't repeat flashcards

    // Generate 15 questions
    for (int i = 0; i < 15; i++) {
      int randomIndex = Random().nextInt(flashcards.length);

      // Ensure unique questions
      while (usedIndexes.contains(randomIndex)) {
        randomIndex = Random().nextInt(flashcards.length);
      }
      usedIndexes.add(randomIndex);

      String correctWord = flashcards[randomIndex]['word']!;
      String correctDefinition = flashcards[randomIndex]['definition']!;

      // Get incorrect definitions by random selection
      List<String> allDefinitions = flashcards.map((flashcard) => flashcard['definition']!).toList();
      allDefinitions.remove(correctDefinition);

      // Pick 2 random incorrect definitions
      allDefinitions.shuffle();
      String incorrectDefinition1 = allDefinitions[0];
      String incorrectDefinition2 = allDefinitions[1];

      // Randomize the answer options
      List<String> options = [correctDefinition, incorrectDefinition1, incorrectDefinition2]..shuffle();

      questions.add({
        'word': correctWord,
        'correctDefinition': correctDefinition,
        'options': options,
      });
    }
  }

  // Handle answer selection
  void _handleAnswer(int questionIndex, String selectedOption) {
    setState(() {
      selectedOptions[questionIndex] = selectedOption;
    });

    if (selectedOption == questions[questionIndex]['correctDefinition']) {
      setState(() {
        score++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Practice Test')),
        body: Center(child: CircularProgressIndicator()), // Show loading if no questions
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Practice Test')),
      body: Container(
        color: Colors.lightBlue[50],
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test your knowledge!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // The question text (word and definition)
                          Text(
                            'What is the definition of "${questions[index]['word']}"?',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          // Answer options (with bigger boxes and smaller font)
                          for (var option in questions[index]['options'])
                            InkWell(
                              onTap: () => _handleAnswer(index, option),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: option,
                                      groupValue: selectedOptions[index], // Track which option is selected
                                      onChanged: (value) {
                                        _handleAnswer(index, value!);
                                      },
                                    ),
                                    // Allowing longer text to expand with no limit
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(fontSize: 14), // Smaller font size to fit more text
                                        softWrap: true, // Ensure text wraps without cutting off
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show score after the test is finished
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Test Finished!'),
                    content: Text('Your score is: $score / 15 (${(score / 15) * 100}%)'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Pop the dialog and go back to HomePage
                          Navigator.pop(context); // Close the dialog
                          Navigator.pop(context); // Go back to HomePage
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Finish Test'),
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
