import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'GamesLandingPage.dart';

class WhereDoesItBelongGame extends StatelessWidget {
  const WhereDoesItBelongGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Where Does It Belong?',
      debugShowCheckedModeBanner: false,
      home: const WhereGameScreen(),
    );
  }
}

class WhereGameScreen extends StatefulWidget {
  const WhereGameScreen({super.key});

  @override
  State<WhereGameScreen> createState() => _WhereGameScreenState();
}

class _WhereGameScreenState extends State<WhereGameScreen> {
  final List<Map<String, String>> items = [
    {'image': 'assets/spoon.png', 'category': 'Kitchen'},
    {'image': 'assets/Fork.png', 'category': 'Kitchen'},
    {'image': 'assets/plate.png', 'category': 'Kitchen'},
    {'image': 'assets/cup.png', 'category': 'Kitchen'},
    {'image': 'assets/toothbrush.png', 'category': 'Bathroom'},
    {'image': 'assets/soap.png', 'category': 'Bathroom'},
    {'image': 'assets/towel.png', 'category': 'Bathroom'},
    {'image': 'assets/pillow.png', 'category': 'Bedroom'},
    {'image': 'assets/blanket.png', 'category': 'Bedroom'},
    {'image': 'assets/lamp.png', 'category': 'Bedroom'},
  ];

  final Map<String, List<String>> acceptedItems = {
    'Kitchen': [],
    'Bathroom': [],
    'Bedroom': [],
  };

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  void handleAccept(String category, String imagePath) {
    setState(() {
      acceptedItems[category]?.add(imagePath);
      items.removeWhere(
        (item) => item['image'] == imagePath && item['category'] == category,
      );
    });

    if (items.isEmpty) {
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 80, color: Colors.amber),
                          const SizedBox(height: 16),
                          const Text(
                            "You have finished the game!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
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
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(); // Dismiss dialog from root navigator
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GamesLandingPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Back to Games",
                              style: TextStyle(
                                fontSize: 22,
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
        );
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => GamesLandingPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
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
                "Where Does It Belong?",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Expanded(
                flex: 2,
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children:
                      items.map((item) {
                        return Draggable<Map<String, String>>(
                          data: item,
                          feedback: Image.asset(
                            item['image']!,
                            width: 120,
                          ), // Increased from 80
                          childWhenDragging: const SizedBox(
                            width: 120,
                            height: 120,
                          ),
                          child: Image.asset(
                            item['image']!,
                            width: 120,
                          ), // Increased from 80
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:
                      ['Kitchen', 'Bathroom', 'Bedroom'].map((category) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DragTarget<Map<String, String>>(
                              builder:
                                  (
                                    context,
                                    candidateData,
                                    rejectedData,
                                  ) => Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 10,
                                            runSpacing: 10,
                                            children:
                                                acceptedItems[category]!
                                                    .map(
                                                      (img) => Image.asset(
                                                        img,
                                                        width: 100,
                                                      ),
                                                    ) // Increased from 60
                                                    .toList(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24, // Increased from 18
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              onWillAccept: (data) => true,
                              onAccept: (data) {
                                if (data['category'] == category) {
                                  handleAccept(category, data['image']!);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Oops! That item does not belong there.',
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
