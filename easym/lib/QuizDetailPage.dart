import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class QuizDetailPage extends StatefulWidget {
  final String category;

  const QuizDetailPage({Key? key, required this.category}) : super(key: key);

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool? isCorrect;
  Map<String, dynamic>? quizData;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    _fetchQuiz();
  }

  Future<void> _fetchQuiz() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('assessments')
        .where('category', isEqualTo: widget.category)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        quizData = snapshot.docs.first.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quizData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFE9D5),
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: const Color(0xFF648BA2),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final questions = quizData!['questions'] as List<dynamic>? ?? [];
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFE9D5),
        appBar: AppBar(
          title: Text(quizData!['title'] ?? 'Quiz'),
          backgroundColor: const Color(0xFF648BA2),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = questions[currentQuestionIndex] as Map<String, dynamic>;
    final questionText = question['questionText'] ?? 'No question';
    final options = question['type'] == 'multiple_choice' ? (question['options'] as List<dynamic>?) ?? [] : [];
    final correctAnswer = question['correctAnswer'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      appBar: AppBar(
        title: Text(quizData!['title'] ?? 'Quiz'),
        backgroundColor: const Color(0xFF648BA2),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4E69),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: const Color(0xFFD5D8C4),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questionText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (question['type'] == 'multiple_choice') ...[
                      ...options.asMap().entries.map((entry) {
                        final option = entry.value as String;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedAnswer == option
                                  ? (isCorrect == true ? Colors.green : Colors.red)
                                  : const Color(0xFF648BA2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: selectedAnswer == null
                                ? () {
                                    setState(() {
                                      selectedAnswer = option;
                                      isCorrect = option == correctAnswer;
                                    });
                                  }
                                : null,
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            selectedAnswer = value;
                            isCorrect = value.trim().toLowerCase() == correctAnswer?.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Type your answer here',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                    if (selectedAnswer != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        isCorrect == true ? 'Correct!' : 'Incorrect. Try again!',
                        style: TextStyle(
                          color: isCorrect == true ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                        selectedAnswer = null;
                        isCorrect = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Previous', style: TextStyle(color: Colors.white)),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (currentQuestionIndex < questions.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                        selectedAnswer = null;
                        isCorrect = null;
                      });
                    } else {
                      Navigator.pop(context); // Return to previous screen
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF648BA2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    currentQuestionIndex < questions.length - 1 ? 'Next' : 'Finish',
                    style: const TextStyle(color: Colors.white),
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