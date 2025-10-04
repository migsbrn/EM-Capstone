import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import '../SoftLoudSoundsPage.dart';

class SoundsAssessment extends StatefulWidget {
  const SoundsAssessment({super.key});

  @override
  _SoundsAssessmentState createState() => _SoundsAssessmentState();
}

class _SoundsAssessmentState extends State<SoundsAssessment> {
  final FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  int score = 0;

  final List<Map<String, dynamic>> items = [
    {'name': 'Alarm Clock', 'image': 'assets/clock.png', 'category': 'loud', 'position': -1},
    {'name': 'Bird Chirping', 'image': 'assets/bird.png', 'category': 'soft', 'position': -1},
    {'name': 'Police Siren', 'image': 'assets/police.jpg', 'category': 'loud', 'position': -1},
    {'name': 'Wind', 'image': 'assets/wind.jpg', 'category': 'soft', 'position': -1},
    {'name': 'Fireworks', 'image': 'assets/fireworks.jpg', 'category': 'loud', 'position': -1},
    {'name': 'Dripping Water', 'image': 'assets/water.png', 'category': 'soft', 'position': -1},
    {'name': 'Chainsaw', 'image': 'assets/chainsaw.png', 'category': 'loud', 'position': -1},
    {'name': 'Whispering', 'image': 'assets/whisper.png', 'category': 'soft', 'position': -1},
    {'name': 'Dog Barking', 'image': 'assets/dog_barking.png', 'category': 'loud', 'position': -1},
    {'name': 'Snake Hiss', 'image': 'assets/snake.png', 'category': 'soft', 'position': -1},
  ];

  final List<int> loudDropped = [];
  final List<int> softDropped = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _speakInstruction();
  }

  Future<void> _speakInstruction() async {
    try {
      final bool isAvailable = await flutterTts.isLanguageAvailable("en-US");
      if (!isAvailable || !mounted) return;
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.stop();
      await flutterTts.speak("Drag each sound to the correct loud or soft category.");
    } catch (e) {
      if (mounted) {
        print("TTS Error in _speakInstruction: $e");
      }
    }
  }

  void _checkCompletion() {
    if (!mounted) return;
    final bool allPlaced = items.every((item) => item['position'] != -1);
    if (allPlaced) {
      _calculateScore();
      _showResultDialog();
    }
  }

  void _calculateScore() {
    score = items.where((item) {
      if (item['position'] == -1) return false;
      return (item['category'] == 'loud' && loudDropped.contains(item['position'])) ||
          (item['category'] == 'soft' && softDropped.contains(item['position']));
    }).length;
  }

  void _onAccept(int itemIndex, String category) {
    if (!mounted) return;
    setState(() {
      if (itemIndex >= 0 && itemIndex < items.length && items[itemIndex]['position'] == -1) {
        if (category == 'loud' && loudDropped.length < 5) {
          loudDropped.add(itemIndex);
          items[itemIndex]['position'] = itemIndex;
        } else if (category == 'soft' && softDropped.length < 5) {
          softDropped.add(itemIndex);
          items[itemIndex]['position'] = itemIndex;
        }
      }
    });
    _checkCompletion();
  }

  void _showResultDialog() {
    if (!mounted) return;
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: const Color(0xFFF7F9FC),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 80),
                    const SizedBox(height: 16),
                    const Text("Great Job!",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50))),
                    const SizedBox(height: 12),
                    Text("Your score: $score/${items.length}",
                        style: const TextStyle(fontSize: 22, color: Color(0xFF34495E))),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DB2FF),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                      ),
                      onPressed: () {
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const SoftLoudSoundsPage()),
                              (Route<dynamic> route) => false);
                        }
                      },
                      child: const Text("Back to Learning",
                          style: TextStyle(fontSize: 22, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkipConfirmation() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Skip Assessment",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black87),
        ),
        content: const Text(
          "Are you sure you want to skip the assessment?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: Colors.black87),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 22, color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SoftLoudSoundsPage()),
                    (Route<dynamic> route) => false);
              }
            },
            child: const Text("Yes, Skip", style: TextStyle(fontSize: 22, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.width < 600;
    final itemSize = isSmall ? screenSize.width * 0.25 : screenSize.width * 0.15;

    return WillPopScope(
      onWillPop: () async {
        if (items.every((item) => item['position'] != -1)) return true;
        _showSkipConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE9D5),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Sounds Assessment",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A4E69)),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmall ? 3 : 5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return item['position'] == -1
                          ? Draggable<int>(
                              data: index,
                              feedback: Material(
                                child: Image.asset(item['image'], width: itemSize, height: itemSize),
                              ),
                              child: Image.asset(item['image']),
                            )
                          : Image.asset(item['image']);
                    },
                  ),
                ),
              ),
              // Drop Targets Row
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Loud
                      Expanded(
                        child: DragTarget<int>(
                          builder: (context, candidateData, rejectedData) => Container(
                            height: 180,
                            color: Colors.blue,
                            child: Center(child: Text("Loud")),
                          ),
                          onWillAcceptWithDetails: (details) {
                            final data = details.data;
                            return data >= 0 &&
                                data < items.length &&
                                items[data]['category'] == 'loud' &&
                                loudDropped.length < 5;
                          },
                          onAcceptWithDetails: (details) => _onAccept(details.data, 'loud'),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Soft
                      Expanded(
                        child: DragTarget<int>(
                          builder: (context, candidateData, rejectedData) => Container(
                            height: 180,
                            color: Colors.yellow,
                            child: Center(child: Text("Soft")),
                          ),
                          onWillAcceptWithDetails: (details) {
                            final data = details.data;
                            return data >= 0 &&
                                data < items.length &&
                                items[data]['category'] == 'soft' &&
                                softDropped.length < 5;
                          },
                          onAcceptWithDetails: (details) => _onAccept(details.data, 'soft'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    flutterTts.stop();
    super.dispose();
  }
}
