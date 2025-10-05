import 'package:flutter/material.dart';
import 'LearnTheAlphabets.dart';
import 'RhymeAndRead.dart';
import 'LearnColors.dart';
import 'LearnShapes.dart';
import 'LearnMyFamily.dart'; // ✅ Import the My Family module
import 'package:flutter_tts/flutter_tts.dart'; // TTS package

class FunctionalAcademicsPage extends StatefulWidget {
  const FunctionalAcademicsPage({super.key});

  @override
  _FunctionalAcademicsPageState createState() =>
      _FunctionalAcademicsPageState();
}

class _FunctionalAcademicsPageState extends State<FunctionalAcademicsPage> {
  final FlutterTts flutterTts = FlutterTts();
  final bool _isDisposed = false; // Track disposal state

  @override
  void initState() {
    super.initState();
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5); // Slower speech rate
      await flutterTts.setPitch(1.0); // Normal pitch
      await flutterTts.setVolume(1.0); // Full volume
    } catch (e) {
      print("TTS setup error: $e");
    }
  }

  Future<void> _speakIntro(String module) async {
    if (_isDisposed) return;
    try {
      await flutterTts.stop();
      await flutterTts.speak("Let's learn the $module");
      await flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      print("TTS speak error: $e");
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
                      "alphabet",
                    ),
                    _buildImageCard(
                      context,
                      'assets/rhyme.png',
                      RhymeAndRead(),
                      "rhyme and read",
                    ),
                    _buildImageCard(
                      context,
                      'assets/color.png',
                      LearnColors(),
                      "colors",
                    ),
                    _buildImageCard(
                      context,
                      'assets/shape.png',
                      LearnShapes(),
                      "shapes",
                    ),
                    _buildImageCard(
                      context,
                      '', // ❌ Empty string to simulate no cover image
                      LearnMyFamily(),
                      "my family",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generic image card with fixed height and placeholder logic
  Widget _buildImageCard(
    BuildContext context,
    String imagePath,
    Widget destination,
    String moduleName,
  ) {
    const double cardHeight = 200; // ✅ Fixed height for all cards

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () async {
          if (!_isDisposed) {
            try {
              await _speakIntro(moduleName);
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
              );
            }
          }
        },
        child: Container(
          height: cardHeight,
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
            child: imagePath.isNotEmpty
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: cardHeight,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: cardHeight,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 50,
                        ),
                      );
                    },
                  )
                : Container(
                    height: cardHeight,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.family_restroom, // Placeholder icon
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
