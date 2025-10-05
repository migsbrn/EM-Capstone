import 'package:flutter/material.dart';
import 'PictureStoryReading.dart';
import 'SoftLoudSoundsPage.dart';
import 'texttospeech.dart'; // TTS + STT file

class CommunicationSkillsPage extends StatefulWidget {
  const CommunicationSkillsPage({super.key});

  @override
  _CommunicationSkillsPageState createState() =>
      _CommunicationSkillsPageState();
}

class _CommunicationSkillsPageState extends State<CommunicationSkillsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Go Back Button
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
              const SizedBox(height: 40),
              const Text(
                "Let's Start Learning",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4E69),
                ),
              ),
              const SizedBox(height: 40),

              // List of Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildImageCard(
                      context,
                      'assets/story.png',
                      PictureStoryReading(),
                      "Picture Story Reading",
                    ),
                    _buildImageCard(
                      context,
                      'assets/Sounds.webp',
                      SoftLoudSoundsPage(),
                      "Soft & Loud Sounds",
                    ),
                    _buildImageCard(
                      context,
                      '', // No cover yet
                      const LearningMaterialsPage(),
                      "Text-to-Speech / STT",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(
      BuildContext context, String imagePath, Widget destination, String moduleName) {
    const double cardHeight = 160;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: imagePath.isNotEmpty
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: cardHeight,
                  )
                : Container(
                    height: cardHeight,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.mic, // placeholder icon for TTS/STT
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
