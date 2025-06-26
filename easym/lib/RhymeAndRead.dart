import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RhymeAssessment.dart';

class RhymeAndRead extends StatefulWidget {
  @override
  _RhymeAndReadState createState() => _RhymeAndReadState();
}

class _RhymeAndReadState extends State<RhymeAndRead> {
  int currentIndex = 0;
  FlutterTts flutterTts = FlutterTts();

  final List<Map<String, String>> rhymes = [
    {
      "image": "assets/cat_mat.jpg",
      "word": "Cat – Mat",
      "sentence": "The cat sat on a mat"
    },
    {
      "image": "assets/hen_pen.jpg",
      "word": "Hen – Pen",
      "sentence": "The hen is in the pen"
    },
    {
      "image": "assets/hand_sand.jpg",
      "word": "Hand – Sand",
      "sentence": "A hand touches the sand."
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedIndex();
  }

  Future<void> _loadSavedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedIndex = prefs.getInt('rhymeCurrentIndex') ?? 0;
    setState(() {
      currentIndex = savedIndex;
    });
    _speak(rhymes[currentIndex]["sentence"]!);
  }

  Future<void> _saveCurrentIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rhymeCurrentIndex', currentIndex);
  }

  void nextRhyme() {
    if (currentIndex < rhymes.length - 1) {
      setState(() => currentIndex++);
      _saveCurrentIndex();
      _speak(rhymes[currentIndex]["sentence"]!);
    } else {
      _showCompletionDialog();
    }
  }

  void previousRhyme() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _saveCurrentIndex();
      _speak(rhymes[currentIndex]["sentence"]!);
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.7);
    await flutterTts.speak(text);
  }

  Future<void> _resetCurrentIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rhymeCurrentIndex', 0);
    setState(() {
      currentIndex = 0;
    });
  }

  void _showCompletionDialog() async {
    await flutterTts.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFFF6DC),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/star.png', height: 150, width: 150),
                  const SizedBox(height: 20),
                  const Text(
                    "What would you like to do next?",
                    style: TextStyle(
                      fontSize: 26,
                      color: Color(0xFF4C4F6B),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDialogButton(
                        label: "Restart Module",
                        color: const Color(0xFF4C4F6B),
                        onPressed: () async {
                          await _resetCurrentIndex();
                          Navigator.pop(context);
                          _speak(rhymes[0]["sentence"]!);
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDialogButton(
                        label: "Take Assessment",
                        color: const Color(0xFF3C7E71),
                        onPressed: () {
                          _resetCurrentIndex();
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RhymeAssessment(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // Go Back Button with top padding to move it down a bit
              Padding(
                padding: const EdgeInsets.only(top: 20), // space above button
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    height: 60,
                    width: 180,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF648BA2),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.circleArrowLeft,
                      size: 60,
                      color: currentIndex > 0 ? Colors.blue : Colors.grey,
                    ),
                    onPressed: currentIndex > 0 ? previousRhyme : null,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        rhymes[currentIndex]["image"]!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.circleArrowRight,
                      size: 60,
                      color: Colors.blue,
                    ),
                    onPressed: nextRhyme,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                rhymes[currentIndex]["word"]!,
                style: const TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4E69),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _speak(rhymes[currentIndex]["sentence"]!),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: FaIcon(
                        FontAwesomeIcons.volumeHigh,
                        size: 35,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      rhymes[currentIndex]["sentence"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
