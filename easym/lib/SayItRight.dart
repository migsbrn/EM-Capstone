import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:string_similarity/string_similarity.dart';

class SayItRight extends StatefulWidget {
  const SayItRight({super.key});

  @override
  _SayItRightState createState() => _SayItRightState();
}

class _SayItRightState extends State<SayItRight> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  String targetWord = "dog";
  String recognizedWord = "";
  int accuracy = 0;

  bool isDialogOpen = false;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _setupTTS();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakWord();
    });
  }

  void _setupTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVoice({
      "name": "en-us-x-sfg#female",
      "locale": "en-US",
    });
  }

  void _speakWord() async {
    await flutterTts.speak("Can you say the word Dog?");
  }

  void _startListening() async {
    if (isListening || isDialogOpen) return;

    setState(() {
      isListening = true;
      recognizedWord = "";
    });

    bool available = await speech.initialize();
    if (available) {
      speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            recognizedWord = result.recognizedWords.toLowerCase().trim();
            double similarity = targetWord.similarityTo(recognizedWord) * 100;
            double confidence = result.confidence * 100;

            int finalScore;
            if (confidence > 0) {
              finalScore = ((similarity + confidence) / 2).round();
            } else {
              finalScore = similarity.round();
            }

            setState(() {
              accuracy = finalScore.clamp(0, 100);
              isListening = false;
            });

            speech.stop();
            _showAccuracyDialog();
          }
        },
        listenFor: const Duration(seconds: 3),
        pauseFor: const Duration(seconds: 2),
        localeId: "en_US",
      );
    } else {
      setState(() => isListening = false);
    }
  }

  void _showAccuracyDialog() {
    if (isDialogOpen) return;

    isDialogOpen = true;

    String feedbackMessage;
    if (accuracy >= 80) {
      feedbackMessage = "Great job! You pronounced it clearly and correctly!";
    } else if (accuracy >= 41) {
      feedbackMessage =
          "Good effort! Try saying the sounds a little more clearly.";
    } else {
      feedbackMessage =
          "Try again. Speak slowly and clearly for better accuracy.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFFBEED9),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 500,
                  maxWidth: 400,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FontAwesomeIcons.microphone,
                        size: 50,
                        color: Color(0xFF4A4E69),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Your Score",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22223B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: accuracy.toDouble(),
                        ),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: value / 100,
                                  strokeWidth: 10,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    value >= 80
                                        ? Colors.green
                                        : value >= 41
                                        ? Colors.orange
                                        : Colors.red,
                                  ),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                              ),
                              Text(
                                "${value.toInt()}%",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "You said: \"$recognizedWord\"",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Text(
                          feedbackMessage,
                          style: const TextStyle(
                            fontSize: 18,
                            color:
                                Colors
                                    .black87, // Changed to darker color for better contrast
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                setState(() {
                                  isDialogOpen = false;
                                  recognizedWord = "";
                                  accuracy = 0;
                                });
                                _speakWord(); // Restart the speech prompt
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
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Back to games
                                isDialogOpen = false;
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
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
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
                    Navigator.pop(context);
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
              "Say It Right!",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Color(0xFF22223B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Image.asset(
                'assets/S-Dog.jpg',
                fit: BoxFit.contain,
                height: 500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "DOG",
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: _startListening,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isListening ? Colors.red[300] : const Color(0xFF6A4C93),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const FaIcon(
                    FontAwesomeIcons.microphone,
                    color: Colors.white,
                    size: 55,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isListening ? "Listening..." : "Tap to speak",
              style: const TextStyle(fontSize: 25, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
