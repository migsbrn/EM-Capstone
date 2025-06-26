import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:signature/signature.dart';
import 'package:confetti/confetti.dart';
import 'GamesLandingPage.dart';

class LetterTracingGame extends StatefulWidget {
  const LetterTracingGame({super.key});

  @override
  State<LetterTracingGame> createState() => _LetterTracingGameState();
}

class _LetterTracingGameState extends State<LetterTracingGame> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;

  int _currentIndex = 0;
  final List<String> letters = List.generate(
    26,
    (i) => String.fromCharCode(65 + i),
  );

  @override
  void initState() {
    super.initState();
    _setupTTS();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.5);
    await _flutterTts.setVolume(1.0);
    _speakLetter();
  }

  Future<void> _speakLetter() async {
    final String letter = letters[_currentIndex];
    await _flutterTts.stop();
    await _flutterTts.speak("Letter $letter");
  }

  Future<void> _checkTracing() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final points = _signatureController.points;

    // Require at least 20 points to accept as valid trace
    if (points.isNotEmpty && points.length > 20) {
      if (_currentIndex < letters.length - 1) {
        setState(() {
          _currentIndex++;
          _signatureController.clear();
        });
        await _speakLetter();
      } else {
        _showCompletionDialog();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! You traced the letter incorrectly. Try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onNextLetter() {
    if (_currentIndex < letters.length - 1) {
      setState(() {
        _currentIndex++;
        _signatureController.clear();
      });
      _speakLetter();
    } else {
      _showCompletionDialog();
    }
  }

  void _onPreviousLetter() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _signatureController.clear();
      });
      _speakLetter();
    }
  }

  void _eraseTracing() {
    _signatureController.clear();
  }

  void _showCompletionDialog() {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.purple,
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 80, color: Colors.amber),
                      const SizedBox(height: 16),
                      const Text(
                        "You have finished the game!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5DB2FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GamesLandingPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Back to Games",
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentLetter = letters[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
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
                        MaterialPageRoute(builder: (_) => GamesLandingPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
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
                'Trace the Letters',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                'Trace the letter:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentLetter,
                    style: const TextStyle(
                      fontSize: 150,
                      color: Colors.black26,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      size: 50,
                      color: Colors.black26,
                    ),
                    onPressed: _speakLetter,
                  ),
                ],
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _checkTracing,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _onPreviousLetter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _eraseTracing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Erase',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onNextLetter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Next Letter',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
