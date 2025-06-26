import 'package:flutter/material.dart';
import 'SayItRight.dart'; // ✅ Ensure this file exists
import 'MatchTheSound.dart'; // ✅ Ensure this file exists
import 'FormTheWord.dart'; // ✅ This must contain AppleWordGame
import 'WhereDoesItBelong.dart'; // ✅ Newly added
import 'LetterTracing.dart'; // ✅ Newly added tracing game

class GamesLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Games",
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4E69),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth;
                      int crossAxisCount =
                          orientation == Orientation.portrait ? 1 : 3;
                      double maxExtent = maxWidth / crossAxisCount + 80;
                      double gridWidth = maxWidth > 1200 ? 1200 : maxWidth;

                      return Center(
                        child: SizedBox(
                          width: gridWidth,
                          child: GridView(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: maxExtent,
                                  crossAxisSpacing: 40,
                                  mainAxisSpacing: 30,
                                  childAspectRatio: 0.75,
                                ),
                            children: [
                              _buildGameCard(
                                imagePath: 'assets/sayitright.png',
                                imageWidth: 270,
                                imageHeight: 370,
                                imageRadius: 15,
                                cardColor: const Color(0xFFFCF5D9),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SayItRight(),
                                    ),
                                  );
                                },
                              ),
                              _buildGameCard(
                                imagePath: 'assets/mth.png',
                                imageWidth: 270,
                                imageHeight: 370,
                                imageRadius: 15,
                                cardColor: const Color(0xFFFBEAB4),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatchSoundPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildGameCard(
                                imagePath: 'assets/d&d.png',
                                imageWidth: 270,
                                imageHeight: 370,
                                imageRadius: 15,
                                cardColor: const Color(0xFFFEF1D6),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AppleWordGame(),
                                    ),
                                  );
                                },
                              ),
                              _buildGameCard(
                                imagePath: 'assets/wdib.png',
                                imageWidth: 270,
                                imageHeight: 370,
                                imageRadius: 15,
                                cardColor: const Color(0xFFFDEFC8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const WhereDoesItBelongGame(),
                                    ),
                                  );
                                },
                              ),
                              _buildGameCard(
                                imagePath: 'assets/tracing.png',
                                imageWidth: 270,
                                imageHeight: 370,
                                imageRadius: 15,
                                cardColor: const Color(0xFFFCECC8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const LetterTracingGame(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameCard({
    required String? imagePath,
    double imageWidth = 120,
    double imageHeight = 120,
    double imageRadius = 10,
    double imageOffset = 0,
    bool showTitle = false,
    VoidCallback? onTap,
    Color cardColor = const Color(0xFFFCF5D9),
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              SafeImage(
                imagePath: imagePath,
                width: imageWidth,
                height: imageHeight,
                radius: imageRadius,
              ),
          ],
        ),
      ),
    );
  }
}

// Custom widget to handle image loading with error fallback
class SafeImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final double radius;

  const SafeImage({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey,
            child: const Icon(Icons.error, color: Colors.red),
          );
        },
      ),
    );
  }
}
