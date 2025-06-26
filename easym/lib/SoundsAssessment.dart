import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'SoftLoudSoundsPage.dart';

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
    {
      'name': 'Alarm Clock',
      'image': 'assets/clock.png',
      'category': 'loud',
      'position': -1,
    },
    {
      'name': 'Bird Chirping',
      'image': 'assets/bird.png',
      'category': 'soft',
      'position': -1,
    },
    {
      'name': 'Police Siren',
      'image': 'assets/police.jpg',
      'category': 'loud',
      'position': -1,
    },
    {
      'name': 'Wind',
      'image': 'assets/wind.jpg',
      'category': 'soft',
      'position': -1,
    },
    {
      'name': 'Fireworks',
      'image': 'assets/fireworks.jpg',
      'category': 'loud',
      'position': -1,
    },
    {
      'name': 'Dripping Water',
      'image': 'assets/water.png',
      'category': 'soft',
      'position': -1,
    },
    {
      'name': 'Chainsaw',
      'image': 'assets/chainsaw.png',
      'category': 'loud',
      'position': -1,
    },
    {
      'name': 'Whispering',
      'image': 'assets/whisper.png',
      'category': 'soft',
      'position': -1,
    },
    {
      'name': 'Dog Barking',
      'image': 'assets/dog_barking.png',
      'category': 'loud',
      'position': -1,
    },
    {
      'name': 'Snake Hiss',
      'image': 'assets/snake.png',
      'category': 'soft',
      'position': -1,
    },
  ];
  final List<int> loudDropped = [];
  final List<int> softDropped = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
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
      await flutterTts.speak(
        "Drag each sound to the correct loud or soft category.",
      );
    } catch (e) {
      if (mounted) {
        print("TTS Error in _speakInstruction: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to speak instructions: $e")),
        );
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
    score =
        items.where((item) {
          if (item['position'] == -1) return false;
          return (item['category'] == 'loud' &&
                  loudDropped.contains(item['position'])) ||
              (item['category'] == 'soft' &&
                  softDropped.contains(item['position']));
        }).length;
  }

  void _onAccept(int itemIndex, String category) {
    if (!mounted) return;
    setState(() {
      if (itemIndex >= 0 &&
          itemIndex < items.length &&
          items[itemIndex]['position'] == -1) {
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
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            backgroundColor: const Color(0xFFF7F9FC),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.purple,
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Great Job!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Your score: $score/${items.length}",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF34495E),
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DB2FF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const SoftLoudSoundsPage(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                          child: const Text(
                            "Back to Learning",
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
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
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Skip Assessment",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "Are you sure you want to skip the assessment?",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const SoftLoudSoundsPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  child: const Text(
                    "Yes, Skip",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.width < 600;
    final itemSize =
        isSmall ? screenSize.width * 0.25 : screenSize.width * 0.15;

    return WillPopScope(
      onWillPop: () async {
        if (items.every((item) => item['position'] != -1)) {
          return true;
        }
        _showSkipConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE9D5),
        body: SafeArea(
          child: Stack(
            children: [
              // Background decorations placeholder
              Positioned(
                bottom: 20,
                right: 0,
                child: SizedBox(
                  width: isSmall ? 200 : 350,
                  height: isSmall ? 200 : 350,
                ),
              ),

              // Close button (unchanged)
              Positioned(
                top: 24,
                right: 24,
                child: ElevatedButton(
                  onPressed: _showSkipConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E69),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Sounds Assessment",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4E69),
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Instruction Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Drag each image to the correct category: Loud or Soft sounds.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Draggables Grid
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
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return item['position'] == -1
                              ? Draggable<int>(
                                data: index,
                                feedback: Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: itemSize * 0.8,
                                    height: itemSize * 0.8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(
                                  width: itemSize,
                                  height: itemSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      item['image'],
                                      fit: BoxFit.cover,
                                      color: Colors.grey.withOpacity(0.4),
                                      colorBlendMode: BlendMode.modulate,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.error,
                                                color: Colors.red,
                                              ),
                                    ),
                                  ),
                                ),
                                child: Semantics(
                                  label: item['name'] as String,
                                  child: Container(
                                    width: itemSize,
                                    height: itemSize,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                onDragStarted: () async {
                                  try {
                                    final bool isAvailable = await flutterTts
                                        .isLanguageAvailable("en-US");
                                    if (!isAvailable || !mounted) return;
                                    await flutterTts.setLanguage("en-US");
                                    await flutterTts.setSpeechRate(0.5);
                                    await flutterTts.setVolume(1.0);
                                    await flutterTts.stop();
                                    await flutterTts.speak(
                                      item['name'] as String,
                                    );
                                  } catch (e) {
                                    if (mounted) {
                                      print("TTS Error in onDragStarted: $e");
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Failed to speak item name: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              )
                              : Container(
                                width: itemSize,
                                height: itemSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                  color: Colors.grey.shade200,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: itemSize * 0.9,
                                      height: itemSize * 0.9,
                                      child: Image.asset(
                                        item['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['name'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Drop targets
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Loud container
                          Expanded(
                            child: DragTarget<int>(
                              builder:
                                  (
                                    context,
                                    candidateData,
                                    rejectedData,
                                  ) => Container(
                                    height: isSmall ? 140 : 180,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF657DFF),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            candidateData.isNotEmpty
                                                ? Colors.white
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Loud",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            children:
                                                loudDropped.map((index) {
                                                  if (index < 0 ||
                                                      index >= items.length)
                                                    return const SizedBox.shrink();
                                                  final item = items[index];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8.0,
                                                        ),
                                                    child: Container(
                                                      width: itemSize * 0.9,
                                                      height: itemSize * 0.9,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              (item['category']
                                                                          as String) ==
                                                                      'loud'
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: Image.asset(
                                                          item['image']
                                                              as String,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) => const Icon(
                                                                Icons.error,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              onWillAccept:
                                  (data) =>
                                      data != null &&
                                      data >= 0 &&
                                      data < items.length &&
                                      items[data]['category'] == 'loud' &&
                                      loudDropped.length < 5,
                              onAccept: (data) => _onAccept(data, 'loud'),
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Soft container
                          Expanded(
                            child: DragTarget<int>(
                              builder:
                                  (
                                    context,
                                    candidateData,
                                    rejectedData,
                                  ) => Container(
                                    height: isSmall ? 140 : 180,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFC857),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            candidateData.isNotEmpty
                                                ? Colors.black87
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Soft",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            children:
                                                softDropped.map((index) {
                                                  if (index < 0 ||
                                                      index >= items.length)
                                                    return const SizedBox.shrink();
                                                  final item = items[index];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8.0,
                                                        ),
                                                    child: Container(
                                                      width: itemSize * 0.9,
                                                      height: itemSize * 0.9,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              (item['category']
                                                                          as String) ==
                                                                      'soft'
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: Image.asset(
                                                          item['image']
                                                              as String,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) => const Icon(
                                                                Icons.error,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              onWillAccept:
                                  (data) =>
                                      data != null &&
                                      data >= 0 &&
                                      data < items.length &&
                                      items[data]['category'] == 'soft' &&
                                      softDropped.length < 5,
                              onAccept: (data) => _onAccept(data, 'soft'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
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
