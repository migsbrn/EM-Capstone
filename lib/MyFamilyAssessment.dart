import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../LearnMyFamily.dart';
import 'dart:math';

class MyFamilyAssessment extends StatefulWidget {
  const MyFamilyAssessment({super.key});

  @override
  _MyFamilyAssessmentState createState() => _MyFamilyAssessmentState();
}

class _MyFamilyAssessmentState extends State<MyFamilyAssessment>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  int currentQuestion = 0;
  int score = 0;
  String selectedAnswer = '';
  bool answered = false;

  final List<Map<String, Object>> questions = [
    {
      'question': 'Who do I live with?',
      'image': 'assets/happy.jpg',
      'options': ['My mother and father', 'My friend and teacher', 'My neighbor'],
      'answer': 'My mother and father',
    },
    {
      'question': 'When do we eat dinner together?',
      'image': 'assets/eating_dinner.jpg',
      'options': ['Every night', 'In the morning', 'At school'],
      'answer': 'Every night',
    },
    {
      'question': 'Why do I love my family?',
      'image': 'assets/love_family.jpg',
      'options': ['They take care of me', 'They give me homework', 'They ride bikes'],
      'answer': 'They take care of me',
    },
    {
      'question': 'What do my sister and I do after school?',
      'image': 'assets/playing.jpg',
      'options': ['Play with toys', 'Do the dishes', 'Go to the store'],
      'answer': 'Play with toys',
    },
    {
      'question': 'What does my father do when my mother is working?',
      'image': 'assets/cooking.jpg',
      'options': ['He cooks dinner', 'He watches TV', 'He reads a book'],
      'answer': 'He cooks dinner',
    },
  ];

  List<Map<String, String>> reflection = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _configureTts();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakQuestion());
  }

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.4);
    try {
      await flutterTts.setVoice({"name": "en-us-x-tpf#female_1-local", "locale": "en-US"});
    } catch (e) {
      await flutterTts.setVoice({"name": "en-us-x-sfg#female_2-local", "locale": "en-US"});
    }
    await flutterTts.awaitSpeakCompletion(true);
  }

  void _speakQuestion() async {
    await flutterTts.stop();
    await flutterTts.speak(questions[currentQuestion]['question'] as String);
  }

  void _speakOption(String option) async {
    await flutterTts.stop();
    await flutterTts.speak(option);
  }

  void answerQuestion(String selected) async {
    if (answered) return;
    setState(() {
      selectedAnswer = selected;
      answered = true;
    });

    bool isCorrect = selected == questions[currentQuestion]['answer'];
    reflection.add({
      'question': questions[currentQuestion]['question'] as String,
      'userAnswer': selected,
      'correctAnswer': questions[currentQuestion]['answer'] as String,
    });

    if (isCorrect) {
      score++;
      await flutterTts.speak("Correct");
    } else {
      _shakeController.forward(from: 0);
      await flutterTts.speak("Wrong");
    }

    await Future.delayed(const Duration(seconds: 2));
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = '';
        answered = false;
      });
      _speakQuestion();
    } else {
      _showResultDialog();
    }
  }

  void _resetAssessment() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedAnswer = '';
      answered = false;
      reflection.clear();
    });
    _speakQuestion();
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF6DC),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 60, color: Color(0xFFFF6B6B)),
                const SizedBox(height: 20),
                const Text(
                  "Skip Assessment?",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF22223B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Are you sure you want to skip this assessment? Your progress will be saved.",
                  style: TextStyle(fontSize: 18, color: Color(0xFF4A4E69)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A4E69),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Cancel", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LearnMyFamily()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Skip", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog() {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF6DC),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              colors: const [Color(0xFF5DB2FF), Color(0xFF4A4E69), Color(0xFF22223B)],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 60, color: Color(0xFF5DB2FF)),
                      const SizedBox(height: 12),
                      const Text("Great Job!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF22223B)), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text("Your score: $score / ${questions.length}", style: const TextStyle(fontSize: 22, color: Color(0xFF4A4E69)), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      const Text("Answer Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF22223B)), textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reflection.length,
                        itemBuilder: (_, index) {
                          final item = reflection[index];
                          final isCorrect = item['userAnswer'] == item['correctAnswer'];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: isCorrect ? const Color(0xFFD6FFE0) : const Color(0xFFFFD6D6),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCorrect ? Colors.green : Colors.red,
                                child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(item['question']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Your Answer: ${item['userAnswer']}", style: TextStyle(fontSize: 16, color: isCorrect ? Colors.green[800] : Colors.red[800])),
                                  if (!isCorrect)
                                    Text("Correct Answer: ${item['correctAnswer']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DB2FF),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LearnMyFamily()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text("Back to Learning", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return WillPopScope(
      onWillPop: () async {
        _showSkipConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6DC),
        body: SafeArea(
          child: Column(
            children: [
              // 🔹 Top Close & Reset Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _showSkipConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22223B),
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Close", style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _resetAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4E69),
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Reset", style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // 🔹 Question and options
              Expanded(
                flex: 6,
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    double offset = sin(_shakeController.value * pi * 4) * 8;
                    return Transform.translate(offset: Offset(offset, 0), child: child);
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Question ${currentQuestion + 1} of ${questions.length}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Image.asset(
                            questions[currentQuestion]['image'] as String,
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          questions[currentQuestion]['question'] as String,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        IconButton(icon: const Icon(Icons.volume_up, size: 40), onPressed: _speakQuestion),
                        const SizedBox(height: 30),
                        ...((questions[currentQuestion]['options'] as List<String>).map((option) {
                          Color bgColor = const Color(0xFF648BA2);
                          if (answered) {
                            if (option == questions[currentQuestion]['answer']) {
                              bgColor = Colors.green;
                            } else if (option == selectedAnswer) bgColor = Colors.red;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton(
                              onPressed: () => answerQuestion(option),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bgColor,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: const Size(double.infinity, 70),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(option,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 22, color: Colors.white)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 28, color: Colors.white),
                                    onPressed: () => _speakOption(option),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  )
                                ],
                              ),
                            ),
                          );
                        }).toList()),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
