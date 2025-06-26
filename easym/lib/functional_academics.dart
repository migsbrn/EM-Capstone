import 'package:flutter/material.dart';
import 'LearnTheAlphabets.dart';
import 'RhymeAndRead.dart';
import 'LearnColors.dart';
import 'LearnShapes.dart';
import 'LearnMyFamily.dart'; // ✅ Import the My Family module
import 'package:flutter_tts/flutter_tts.dart'; // Add TTS package

class FunctionalAcademicsPage extends StatefulWidget {
  const FunctionalAcademicsPage({super.key});

  @override
  _FunctionalAcademicsPageState createState() =>
      _FunctionalAcademicsPageState();
}

class _FunctionalAcademicsPageState extends State<FunctionalAcademicsPage> {
  final FlutterTts flutterTts = FlutterTts();
  bool _isDisposed = false; // Track disposal state

  @override
  void initState() {
    super.initState();
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5); // Slower speech rate for clarity
      await flutterTts.setPitch(1.0); // Normal pitch
      await flutterTts.setVolume(1.0); // Full volume
    } catch (e) {
      print("TTS setup error: $e"); // Log error for debugging
    }
  }

  Future<void> _speakIntro(String module) async {
    if (_isDisposed) return; // Prevent calls after disposal
    try {
      await flutterTts.stop(); // Stop any previous speech
      await flutterTts.speak("Let's learn the $module");
      await flutterTts.awaitSpeakCompletion(
        true,
      ); // Wait for speech to complete
    } catch (e) {
      print("TTS speak error: $e"); // Log error for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Go Back Button
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: 60,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 40),
              const Text(
                "Let's Start Learning",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4E69),
                ),
              ),
              const SizedBox(height: 40),

              // List of Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildImageCard(
                      context,
                      'assets/alphabet.png',
                      LearnTheAlphabets(),
                      "alphabet", // Module name for TTS
                    ),
                    _buildImageCard(
                      context,
                      'assets/rhyme.png',
                      RhymeAndRead(),
                      "rhyme and read", // Module name for TTS
                    ),
                    _buildImageCard(
                      context,
                      'assets/color.png',
                      LearnColors(),
                      "colors", // Module name for TTS
                    ),
                    _buildImageCard(
                      context,
                      'assets/shape.png',
                      LearnShapes(),
                      "shapes", // Module name for TTS
                    ),
                    _buildImageCard(
                      context,
                      'assets/family_card.png',
                      LearnMyFamily(),
                      "my family", // Module name for TTS
                    ), // ✅ Added card
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generic image card
  Widget _buildImageCard(
    BuildContext context,
    String imagePath,
    Widget destination,
    String moduleName, // Added parameter for TTS
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () async {
          if (!_isDisposed) {
            try {
              await _speakIntro(moduleName); // Play TTS before navigation
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => destination),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error playing sound: $e')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => destination),
              ); // Proceed with navigation on error
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: const Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
