import 'package:flutter/material.dart';
import 'package:easym/ReadingMaterialsPage.dart';
import 'package:easym/GamesLandingPage.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StudentLandingPage extends StatefulWidget {
  final String nickname;

  const StudentLandingPage({super.key, required this.nickname});

  @override
  _StudentLandingPageState createState() => _StudentLandingPageState();
}

class _StudentLandingPageState extends State<StudentLandingPage> {
  final GlobalKey _readingKey = GlobalKey();
  final GlobalKey _gamesKey = GlobalKey();
  final FlutterTts flutterTts = FlutterTts();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  bool tutorialShown = false;

  @override
  void initState() {
    super.initState();
    _setupTts();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkTutorialStatus();
      if (!tutorialShown) {
        _initTargets();
        _showTutorial();
      }
    });
  }

  Future<void> _setupTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.3);
      await flutterTts.setSpeechRate(0.8);

      List<dynamic> voices = await flutterTts.getVoices;
      for (var voice in voices) {
        final name = (voice["name"] ?? "").toLowerCase();
        final locale = (voice["locale"] ?? "").toLowerCase();
        if ((name.contains("female") || name.contains("woman") || name.contains("natural")) &&
            locale.contains("en")) {
          await flutterTts.setVoice({
            "name": voice["name"],
            "locale": voice["locale"],
          });
          break;
        }
      }
    } catch (e) {
      print("TTS setup error: $e");
    }
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    tutorialShown = prefs.getBool('tutorialShown') ?? false;
  }

  void _markTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialShown', true);
    setState(() {
      tutorialShown = true;
    });
  }

  void _initTargets() {
    targets = [
      TargetFocus(
        identify: "Reading",
        keyTarget: _readingKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black.withOpacity(0.7),
              child: const Text(
                "Click here to access fun reading materials designed for you!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Games",
        keyTarget: _gamesKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black.withOpacity(0.7),
              child: const Text(
                "Click here to play educational games and test your skills!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void _showTutorial() {
    if (tutorialShown) return;

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      skipWidget: GestureDetector(
        onTap: () {
          tutorialCoachMark.finish();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          margin: const EdgeInsets.only(bottom: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'SKIP',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onFinish: () => _markTutorialShown(),
      onClickTarget: (target) {},
    );

    tutorialCoachMark.show(context: context);
  }

  Future<void> _speak(String text) async {
    try {
      await flutterTts.speak(text);
    } catch (e) {
      print("TTS error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: TopWaveClipper(),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: const Color(0xFFFBEED9),
                ),
              ),
              Positioned(
                top: 60,
                left: 40,
                child: Text(
                  'Hello, ${widget.nickname}!',
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4E69),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      CustomCardButton(
                        key: _readingKey,
                        imagePath: 'assets/lrn.png',
                        title: '',
                        width: screenWidth < 800 ? double.infinity : 600,
                        height: screenWidth < 800 ? 300 : 400,
                        onTap: () async {
                          await _speak("Learning Materials");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Readingmaterialspage()),
                          );
                        },
                      ),
                      CustomCardButton(
                        key: _gamesKey,
                        imagePath: 'assets/games.png',
                        title: '',
                        width: screenWidth < 800 ? double.infinity : 600,
                        height: screenWidth < 800 ? 300 : 400,
                        onTap: () async {
                          await _speak("Games");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GamesLandingPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCardButton extends StatelessWidget {
  final double width;
  final double height;
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const CustomCardButton({
    super.key,
    required this.width,
    required this.height,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: const Color(0xFFFFF9E4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: height * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),
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
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
