import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'AlphabetAssessment.dart';

class LearnTheAlphabets extends StatefulWidget {
  @override
  _LearnTheAlphabetsState createState() => _LearnTheAlphabetsState();
}

class _LearnTheAlphabetsState extends State<LearnTheAlphabets> {
  final FlutterTts flutterTts = FlutterTts();
  final List<String> alphabetList = List.generate(26, (i) => String.fromCharCode(65 + i));
  int currentIndex = 0;
  bool canReplay = false;
  bool isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
    _setupTTS();
  }

  Future<void> loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedIndex = prefs.getInt('alphabetProgress') ?? 0;
    if (savedIndex >= alphabetList.length) {
      savedIndex = 0;
    }
    setState(() {
      currentIndex = savedIndex;
    });
  }

  Future<void> _setupTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.5);
    await flutterTts.setVolume(1.0);

    if (isFirstLaunch) {
      await flutterTts.speak("Listen carefully. What letter is this?");
      await flutterTts.awaitSpeakCompletion(true);
      isFirstLaunch = false;
    }

    await _speakLetter();
  }

  Future<void> _speakLetter() async {
    String letter = alphabetList[currentIndex];

    setState(() {
      canReplay = false;
    });

    await flutterTts.stop();

    // Adding "Letter" before the letter improves TTS clarity
    await flutterTts.speak("Letter $letter");
    await flutterTts.awaitSpeakCompletion(true);

    setState(() {
      canReplay = true;
    });
  }

  void changeCard(int step) async {
    int newIndex = currentIndex + step;

    if (newIndex < 0) return;

    if (newIndex < alphabetList.length) {
      setState(() {
        currentIndex = newIndex;
        canReplay = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('alphabetProgress', currentIndex);

      await _speakLetter();
    } else if (newIndex == alphabetList.length) {
      _showCompletionDialog();
    }
  }

  Future<bool> _onWillPop() async {
    if (currentIndex < alphabetList.length) {
      bool? shouldLeave = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
              'You have not completed the module. Do you want to continue learning or skip to the assessment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continue Learning'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Skip to Assessment'),
            ),
          ],
        ),
      );
      if (shouldLeave == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AlphabetAssessment()),
        );
        return false;
      }
      return false;
    }
    return true;
  }

  void _showCompletionDialog() async {
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('alphabetProgress', 0);
                          setState(() {
                            currentIndex = 0;
                          });
                          Navigator.pop(context);
                          _speakLetter();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4C4F6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Restart Module",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AlphabetAssessment()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3C7E71),
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
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.9 > 900 ? 900.0 : screenWidth * 0.9;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE9D5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: [
                Align(
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
                const SizedBox(height: 40),
                const Text(
                  "Learn The Alphabets",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF648BA2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: containerWidth,
                      height: 500,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5D8C4),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              "${alphabetList[currentIndex]}${alphabetList[currentIndex].toLowerCase()}",
                              style: const TextStyle(
                                fontSize: 200,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF648BA2),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: IconButton(
                              iconSize: 60,
                              icon: FaIcon(
                                FontAwesomeIcons.volumeHigh,
                                color: canReplay
                                    ? const Color(0xFF4C4F6B)
                                    : Colors.grey,
                              ),
                              onPressed: canReplay ? _speakLetter : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: currentIndex > 0 ? () => changeCard(-1) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C4F6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fixedSize: const Size(150, 50),
                        ),
                        child: const Text(
                          "Previous",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => changeCard(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C4F6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fixedSize: const Size(150, 50),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
