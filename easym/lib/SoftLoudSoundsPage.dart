import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'SoundsAssessment.dart';

class SoftLoudSoundsPage extends StatefulWidget {
  const SoftLoudSoundsPage({super.key});

  @override
  _SoftLoudSoundsPageState createState() => _SoftLoudSoundsPageState();
}

class _SoftLoudSoundsPageState extends State<SoftLoudSoundsPage> {
  final FlutterTts flutterTts = FlutterTts();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _items = [
    {
      'type': 'sound',
      'name': 'Whispering',
      'image': 'assets/whisper.png',
      'category': 'soft',
    },
    {
      'type': 'sound',
      'name': 'Hiss of Snake',
      'image': 'assets/snake.png',
      'category': 'soft',
    },
    {
      'type': 'sound',
      'name': 'Wind',
      'image': 'assets/wind.jpg',
      'category': 'soft',
    },
    {
      'type': 'sound',
      'name': 'Dripping Water',
      'image': 'assets/water.png',
      'category': 'soft',
    },
    {
      'type': 'sound',
      'name': 'Bird Chirping',
      'image': 'assets/bird.png',
      'category': 'soft',
    },
    {
      'type': 'sound',
      'name': 'Alarm Clock',
      'image': 'assets/clock.png',
      'category': 'loud',
    },
    {
      'type': 'sound',
      'name': 'Fireworks',
      'image': 'assets/fireworks.jpg',
      'category': 'loud',
    },
    {
      'type': 'sound',
      'name': 'Chainsaw',
      'image': 'assets/chainsaw.png',
      'category': 'loud',
    },
    {
      'type': 'sound',
      'name': 'Police Siren',
      'image': 'assets/police.jpg',
      'category': 'loud',
    },
    {
      'type': 'sound',
      'name': 'Barking of a Dog',
      'image': 'assets/dog_barking.png',
      'category': 'loud',
    },
  ];

  void _speakContent() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(1.0);
    final item = _items[_currentIndex];
    if (item['type'] == 'sound') {
      await flutterTts.speak(item['name']!);
    }
  }

  void _nextShape() {
    if (_currentIndex < _items.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _previousShape() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _resetCurrentIndex() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _showCompletionDialog() async {
    await flutterTts.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                        onPressed: () {
                          _resetCurrentIndex();
                          Navigator.pop(context);
                          _speakContent();
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDialogButton(
                        label: "Take Assessment",
                        color: const Color(0xFF3C7E71),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SoundsAssessment(),
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
    final item = _items[_currentIndex];
    String title =
        'Learn ${item['category'] == 'soft' ? 'Soft' : 'Loud'} Sounds';

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 180,
                    height: 60,
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
                const SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4E69),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 600,
                  height: 600,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['type'] == 'sound' ? item['name']! : 'Example',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4E69),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              Icons.volume_up,
                              size: 55,
                              color: Color(0xFF648BA2),
                            ),
                            onPressed: _speakContent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Image.asset(
                        item['image']!,
                        height: 350,
                        width: 400,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentIndex == 0 ? null : _previousShape,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentIndex == 0
                                ? Colors.grey
                                : const Color(0xFF648BA2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _nextShape,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF648BA2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 25, color: Colors.white),
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
