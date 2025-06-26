import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'GamesLandingPage.dart';

void main() {
  runApp(const AppleWordGame());
}

class AppleWordGame extends StatelessWidget {
  const AppleWordGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Game',
      theme: ThemeData(fontFamily: 'Arial'),
      home: const WordGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WordGameScreen extends StatefulWidget {
  const WordGameScreen({super.key});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> wordData = [
    {
      'word': 'APPLE',
      'image': 'assets/apt.jpg',
      'jumbled': ['P', 'A', 'P', 'E', 'L'],
      'tts': 'Apple',
    },
    {
      'word': 'BALL',
      'image': 'assets/pic1.jpg',
      'jumbled': ['B', 'L', 'L', 'A'],
      'tts': 'Ball',
    },
    {
      'word': 'CAT',
      'image': 'assets/pic4.jpg',
      'jumbled': ['A', 'C', 'T'],
      'tts': 'Cat',
    },
    {
      'word': 'COW',
      'image': 'assets/pic2.jpg',
      'jumbled': ['O', 'W', 'C'],
      'tts': 'Cow',
    },
    {
      'word': 'MANGO',
      'image': 'assets/pic3.jpg',
      'jumbled': ['M', 'O', 'A', 'G', 'N'],
      'tts': 'Mango',
    },
  ];

  int currentWordIndex = 0;
  List<String> selectedLetters = [];
  List<int> selectedIndices = [];
  List<bool> isLetterUsed = [];
  bool isCorrect = false;
  bool isIncorrect = false;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  List<Map<String, dynamic>> answerSummary = [];

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  String get correctWord => wordData[currentWordIndex]['word'];
  String get wordImage => wordData[currentWordIndex]['image'];
  List<String> get jumbledLetters => wordData[currentWordIndex]['jumbled'];
  String get ttsWord => wordData[currentWordIndex]['tts'];

  @override
  void initState() {
    super.initState();
    isLetterUsed = List.filled(jumbledLetters.length, false);
    speakWord();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void speakWord() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(ttsWord);
  }

  void onLetterTap(String letter, int index) {
    if (selectedLetters.length < correctWord.length && !isLetterUsed[index]) {
      setState(() {
        selectedLetters.add(letter);
        selectedIndices.add(index);
        isLetterUsed[index] = true;
      });

      if (selectedLetters.length == correctWord.length) {
        String formedWord = selectedLetters.join('');
        answerSummary.add({
          'word': correctWord,
          'userAnswer': formedWord,
          'isCorrect': formedWord == correctWord,
        });

        if (formedWord == correctWord) {
          flutterTts.speak("Correct!");
          setState(() {
            isCorrect = true;
            isIncorrect = false;
            correctAnswers++;
          });
          goToNextWord();
        } else {
          setState(() {
            isCorrect = false;
            isIncorrect = true;
            incorrectAnswers++;
          });

          _shakeController.forward(from: 0);

          Future.delayed(const Duration(milliseconds: 700), () {
            setState(() {
              selectedLetters.clear();
              selectedIndices.clear();
              isLetterUsed = List.filled(jumbledLetters.length, false);
              isIncorrect = false;
            });
            goToNextWord();
          });
        }
      }
    }
  }

  void onSelectedLetterTap(int index) {
    if (index < selectedLetters.length) {
      setState(() {
        int jumbledIndex = selectedIndices[index];
        isLetterUsed[jumbledIndex] = false;
        selectedLetters.removeAt(index);
        selectedIndices.removeAt(index);
        isCorrect = false;
        isIncorrect = false;
      });
    }
  }

  void goToNextWord() {
    Future.delayed(const Duration(seconds: 2), () {
      if (currentWordIndex < wordData.length - 1) {
        setState(() {
          currentWordIndex++;
          selectedLetters.clear();
          selectedIndices.clear();
          isLetterUsed = List.filled(
            wordData[currentWordIndex]['jumbled'].length,
            false,
          );
          isCorrect = false;
          isIncorrect = false;
        });
        speakWord();
      } else {
        flutterTts.speak("You finished the game!");
        showScoreDialog();
      }
    });
  }

  void showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFBEED9),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: 400,
              height: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.volume_up,
                      size: 50,
                      color: Color(0xFF4A6C82),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Score",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22223B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$correctAnswers",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Answer Summary",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: answerSummary.length,
                      itemBuilder: (_, index) {
                        final item = answerSummary[index];
                        final isCorrect = item['isCorrect'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isCorrect ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Word: ${item['word']}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Your Answer: ${item['userAnswer']}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                  ),
                                ),
                                if (!isCorrect)
                                  Text(
                                    "Correct Answer: ${item['word']}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentWordIndex = 0;
                                correctAnswers = 0;
                                incorrectAnswers = 0;
                                answerSummary.clear();
                                selectedLetters.clear();
                                selectedIndices.clear();
                                isLetterUsed = List.filled(
                                  wordData[currentWordIndex]['jumbled'].length,
                                  false,
                                );
                                isCorrect = false;
                                isIncorrect = false;
                              });
                              Navigator.of(context).pop();
                              speakWord();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5DB2FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.replay, size: 24),
                                SizedBox(width: 8),
                                Text("Retry"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GamesLandingPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF648BA2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text("Back to Games"),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF0EBD8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: 60,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamesLandingPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF648BA2),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Form The Word",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6C82),
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    width: screenWidth * 0.40,
                    height: screenWidth * 0.40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(wordImage, fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: speakWord,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF648BA2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = _shakeAnimation.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(correctWord.length, (index) {
                      return Transform.translate(
                        offset: Offset(
                          isIncorrect ? sin(index + offset) * 4 : 0,
                          0,
                        ),
                        child: GestureDetector(
                          onTap: () => onSelectedLetterTap(index),
                          child: Container(
                            width: 70,
                            height: 70,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color:
                                  isIncorrect && selectedLetters.length > index
                                      ? Colors.red
                                      : const Color(0xFFE7F0F9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              selectedLetters.length > index
                                  ? selectedLetters[index]
                                  : correctWord[index],
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color:
                                    selectedLetters.length > index
                                        ? const Color(0xFF4A6C82)
                                        : Colors.grey.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: List.generate(jumbledLetters.length, (index) {
                  return GestureDetector(
                    onTap: () => onLetterTap(jumbledLetters[index], index),
                    child: Opacity(
                      opacity: isLetterUsed[index] ? 0.3 : 1.0,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A6C82),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          jumbledLetters[index],
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),
              if (isCorrect)
                const Text(
                  "Great Job!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
