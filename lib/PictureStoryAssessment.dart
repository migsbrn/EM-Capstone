import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../ReadingMaterialsPage.dart';

class PictureStoryAssessment extends StatefulWidget {
  const PictureStoryAssessment({super.key});

  @override
  State<PictureStoryAssessment> createState() => _PictureStoryAssessmentState();
}

class _PictureStoryAssessmentState extends State<PictureStoryAssessment> {
  final FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;

  int currentQuestion = 0;
  int score = 0;
  String? selectedOption;
  late List<String?> userAnswers;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Who is lost in the park?",
      "image": 'assets/puppy.png',
      "options": ["puppy", "dog", "cat", "bird"],
      "answer": "puppy",
    },
    {
      "question": "Who finds the lost puppy?",
      "image": 'assets/grl.jpg',
      "options": ["boy", "girl", "dog", "cat"],
      "answer": "girl",
    },
    {
      "question": "Who reunites with the puppy?",
      "image": 'assets/girl.png',
      "options": ["puppy", "owner", "boy", "cat"],
      "answer": "owner",
    },
  ];

  List<String> shuffledOptions = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    userAnswers = List<String?>.filled(questions.length, null);
    _configureTts();
    _shuffleOptions();
    _speakQuestion();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.4);

    try {
      await flutterTts.setVoice({"name": "en-us-x-tpf#female_1-local", "locale": "en-US"});
    } catch (e) {
      try {
        await flutterTts.setVoice({"name": "en-us-x-sfg#female_2-local", "locale": "en-US"});
      } catch (e) {
        print("TTS voice configuration failed: $e");
      }
    }
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speakQuestion() async {
    await flutterTts.stop();
    await flutterTts.speak(questions[currentQuestion]["question"]);
  }

  Future<void> _speakOption(String option) async {
    await flutterTts.stop();
    await flutterTts.speak(option);
  }

  void _shuffleOptions() {
    shuffledOptions = List<String>.from(questions[currentQuestion]["options"]);
    shuffledOptions.shuffle(Random());
  }

  void _checkAnswer(String selected) async {
    await flutterTts.stop();
    setState(() {
      selectedOption = selected;
      userAnswers[currentQuestion] = selected;
    });

    if (selected == questions[currentQuestion]["answer"]) {
      score++;
      await flutterTts.speak("Correct");
    } else {
      await flutterTts.speak("Wrong");
    }

    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        selectedOption = null;
      });

      if (currentQuestion < questions.length - 1) {
        setState(() {
          currentQuestion++;
          _shuffleOptions();
        });
        _speakQuestion();
      } else {
        _showResultDialog();
      }
    });
  }

  void _resetAssessment() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedOption = null;
      userAnswers = List<String?>.filled(questions.length, null);
      _shuffleOptions();
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
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Skip Assessment?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22223B),
                  ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const Readingmaterialspage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
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
    final reflection = List.generate(questions.length, (index) => {
          'question': questions[index]['question'],
          'userAnswer': userAnswers[index] ?? "-",
          'correctAnswer': questions[index]['answer'],
        });

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
              colors: const [
                Color(0xFF5DB2FF),
                Color(0xFF4A4E69),
                Color(0xFF22223B)
              ],
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
                      const Text(
                        "Great Job!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22223B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your score: $score / ${questions.length}",
                        style: const TextStyle(fontSize: 22, color: Color(0xFF4A4E69)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Answer Summary",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22223B),
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                "Question: ${item['question']}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Answer: ${item['userAnswer']}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: isCorrect ? Colors.green[800] : Colors.red[800]),
                                  ),
                                  if (!isCorrect)
                                    Text(
                                      "Correct Answer: ${item['correctAnswer']}",
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
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
                              MaterialPageRoute(builder: (_) => const Readingmaterialspage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text(
                            "Back to Learning",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
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
  Widget build(BuildContext context) {
    final questionData = questions[currentQuestion];
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.width < 600;

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
              // Top Close & Reset Buttons
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCE5FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Question ${currentQuestion + 1} of ${questions.length}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCE5FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          questionData["question"],
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          questionData["image"],
                          fit: BoxFit.contain,
                          height: 250,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: shuffledOptions.map((option) {
                          return SizedBox(
                            width: isSmall ? screenSize.width * 0.8 : 300,
                            child: ElevatedButton(
                              onPressed: () => _checkAnswer(option),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedOption == option ? Colors.orange[300] : Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                minimumSize: const Size(double.infinity, 70),
                                side: const BorderSide(color: Color(0xFF66B3FF), width: 3),
                                elevation: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      option,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, color: Colors.black87, size: 30),
                                    onPressed: () => _speakOption(option),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.volume_up),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D94FF),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _speakQuestion(),
                        label: const Text("Repeat Question", style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                      const SizedBox(height: 40),
                    ],
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
