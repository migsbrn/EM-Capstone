import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ColorAssessment.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LearnColors(),
    ));

class LearnColors extends StatefulWidget {
  @override
  _LearnColorsState createState() => _LearnColorsState();
}

class _LearnColorsState extends State<LearnColors> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> colors = [
    {'name': 'red', 'color': Colors.red},
    {'name': 'blue', 'color': Colors.blue},
    {'name': 'green', 'color': Colors.green},
    {'name': 'yellow', 'color': Colors.yellow},
    {'name': 'purple', 'color': Colors.purple},
    {'name': 'orange', 'color': Colors.orange},
    {'name': 'pink', 'color': Colors.pink},
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentIndex = prefs.getInt('colorIndex') ?? 0;
    });
    _speakColor();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('colorIndex', currentIndex);
  }

  void _speakColor() async {
    final colorName = colors[currentIndex]['name'];
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak("This is color $colorName");
  }

  void _nextColor() async {
    if (currentIndex < colors.length - 1) {
      setState(() {
        currentIndex++;
      });
      _saveProgress();
      _speakColor();
    } else {
      await flutterTts.stop();
      _showCompletionDialog();
    }
  }

  void _previousColor() {
    setState(() {
      currentIndex = (currentIndex - 1 + colors.length) % colors.length;
    });
    _saveProgress();
    _speakColor();
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
                          await prefs.setInt('colorIndex', 0);
                          setState(() {
                            currentIndex = 0;
                          });
                          Navigator.pop(context);
                          _speakColor();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C4F6B),
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
                            MaterialPageRoute(builder: (context) => ColorAssessment()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C7E71),
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
    final colorData = colors[currentIndex];
    final colorName = colorData['name'];
    final color = colorData['color'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F0DC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 180,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                const SizedBox(height: 20),
                const Text(
                  "Learn The Colors",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF648BA2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 450,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 200,
                          child: CustomPaint(
                            painter: BlobPainter(color),
                          ),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: _speakColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.volume_up, size: 45, color: Colors.black),
                              const SizedBox(width: 10),
                              Text(
                                "This is color $colorName",
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Color(0xFF648BA2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: currentIndex == 0 ? null : _previousColor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentIndex == 0 ? Colors.grey : const Color(0xFF648BA2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        fixedSize: const Size(150, 60),
                      ),
                      child: const Text(
                        "Previous",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _nextColor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF648BA2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        fixedSize: const Size(150, 60),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
}

class BlobPainter extends CustomPainter {
  final Color color;
  BlobPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.2;
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = 2 * pi * i / 6;
      final dx = center.dx + cos(angle) * radius;
      final dy = center.dy + sin(angle) * radius;
      path.addOval(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BlobPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
