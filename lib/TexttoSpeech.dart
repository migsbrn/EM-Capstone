import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class LearningMaterialsPage extends StatefulWidget {
  const LearningMaterialsPage({super.key});

  @override
  _LearningMaterialsPageState createState() => _LearningMaterialsPageState();
}

class _LearningMaterialsPageState extends State<LearningMaterialsPage> {
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "";

  // Lessons per category
  final Map<String, List<String>> lessons = {
    "Alphabet": [
      "A is for Apple",
      "B is for Ball",
      "C is for Cat",
      "D is for Dog",
    ],
    "Numbers": ["1 is One", "2 is Two", "3 is Three", "4 is Four"],
    "Colors": ["Red", "Blue", "Yellow", "Green"],
    "Shapes": ["Circle", "Square", "Triangle", "Rectangle"],
    "Animals": ["Dog", "Cat", "Elephant", "Lion"],
  };

  String selectedCategory = "Alphabet";
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestMicPermission();
  }

  /// Request microphone permission
  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  /// Speak lesson (TTS)
  Future _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  /// Start/Stop listening (STT)
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print("Status: $val"),
        onError: (val) => print("Error: $val"),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult:
              (val) => setState(() {
                _spokenText = val.recognizedWords;
              }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  /// Get current lesson text
  String get currentLesson => lessons[selectedCategory]![currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0DC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Go Back Button
              Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF648BA2),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 26,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Category Selector (row of buttons)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      lessons.keys.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedCategory = category;
                                currentIndex = 0;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  selectedCategory == category
                                      ? const Color(0xFF2A9D8F)
                                      : const Color(0xFFB0BEC5),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Lesson Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentLesson,
                      style: const TextStyle(
                        fontSize: 40, // BIG text
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Next & Previous Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed:
                        currentIndex > 0
                            ? () {
                              setState(() {
                                currentIndex--;
                              });
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Previous",
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        currentIndex < lessons[selectedCategory]!.length - 1
                            ? () {
                              setState(() {
                                currentIndex++;
                              });
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Speech-to-Text Output
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFE9E9E9),
                ),
                child: Text(
                  _spokenText.isEmpty
                      ? "Your speech will appear here..."
                      : _spokenText,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF333333),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Buttons for Listen / Speak
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _speak(currentLesson),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077B6),
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Listen Lesson",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _listen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isListening
                                ? Colors.redAccent
                                : const Color(0xFF2A9D8F),
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _isListening ? "Listening..." : "Speak Now",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
