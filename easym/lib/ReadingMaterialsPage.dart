import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'functional_academics.dart';
import 'communication_skills.dart';
import 'prevocational_skills.dart';

class Readingmaterialspage extends StatefulWidget {
  const Readingmaterialspage({super.key});

  @override
  State<Readingmaterialspage> createState() => _ReadingmaterialspageState();
}

class _ReadingmaterialspageState extends State<Readingmaterialspage> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    setupTts();
  }

  void setupTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.3); // feminine tone
    await flutterTts.setSpeechRate(0.8); // natural speed

    List<dynamic> voices = await flutterTts.getVoices;
    for (var voice in voices) {
      final name = (voice["name"] ?? "").toLowerCase();
      final locale = (voice["locale"] ?? "").toLowerCase();
      if ((name.contains("female") ||
              name.contains("woman") ||
              name.contains("natural")) &&
          locale.contains("en")) {
        await flutterTts.setVoice({
          "name": voice["name"],
          "locale": voice["locale"],
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              ClipPath(
                clipper: TopWaveClipper(),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: const Color(0xFFFBEED9),
                ),
              ),
              Padding(
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
                    const SizedBox(height: 120),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double maxWidth = constraints.maxWidth;
                          int columns =
                              MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? 1
                                  : 3;
                          double maxExtent = maxWidth / columns + 80;
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
                                children: _buildSubjectCards(context),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSubjectCards(BuildContext context) {
    return [
      _buildSubjectCard(
        context,
        label: "",
        imagePath: 'assets/functional.png',
        onTap: () async {
          await flutterTts.speak("Functional Academics");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FunctionalAcademicsPage(),
            ),
          );
        },
      ),
      _buildSubjectCard(
        context,
        label: "",
        imagePath: 'assets/communication.png',
        onTap: () async {
          await flutterTts.speak("Communication Skills");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunicationSkillsPage(),
            ),
          );
        },
      ),
      _buildSubjectCard(
        context,
        label: "",
        imagePath: 'assets/prevocational.png',
        onTap: () async {
          await flutterTts.speak("Pre vocational Skills");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PreVocationalSkillsPage(),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildSubjectCard(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(imagePath, height: 320, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4E69),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 100);
    var secondEndPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
