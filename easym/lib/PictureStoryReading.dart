import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'PictureStoryAssessment.dart'; // Make sure this file exists

class PictureStoryReading extends StatefulWidget {
  @override
  _PictureStoryReadingState createState() => _PictureStoryReadingState();
}

class _PictureStoryReadingState extends State<PictureStoryReading> {
  final FlutterTts flutterTts = FlutterTts();

  final String storyText =
      "A little puppy named Bella got lost in the park. She barked for help, and a kind girl found her. They searched for Bella’s owner together, and soon they reunited.";

  @override
  void initState() {
    super.initState();
    _setupTTS();
    _speakStory();
  }

  void _setupTTS() async {
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage("en-US");
  }

  void _speakStory() async {
    await flutterTts.stop();
    await Future.delayed(Duration(milliseconds: 300));
    await flutterTts.speak(storyText);
  }

  void _showAssessmentDialog() async {
    await flutterTts.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Color(0xFFFFF6DC),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/star.png',
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Ready for a quick assessment?",
                      style: TextStyle(
                        fontSize: 26,
                        color: Color(0xFF4C4F6B),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PictureStoryAssessment()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF648BA2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Take Assessment",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Go Back Button
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: SizedBox(
                      width: 180,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          await flutterTts.stop();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF648BA2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Center(
                child: Text(
                  "Picture Reading Story",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF648BA2),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Story Card
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 1000,
                  height: 700,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D8C4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Speaker Icon
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.volumeHigh,
                            size: 40,
                            color: Colors.blueAccent,
                          ),
                          onPressed: _speakStory,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/puppy.jpg',
                          fit: BoxFit.cover,
                          height: 270,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Story Title
                      const Text(
                        "The Adventure of the Lost Puppy",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Story Text
                      Text(
                        storyText,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Assessment Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _showAssessmentDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF648BA2),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Proceed to Assessment",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
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
