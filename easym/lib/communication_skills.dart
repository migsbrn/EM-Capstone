import 'package:flutter/material.dart';
import 'PictureStoryReading.dart'; // Make sure this file exists
import 'SoftLoudSoundsPage.dart'; // New file to be created

class CommunicationSkillsPage extends StatelessWidget {
  const CommunicationSkillsPage({super.key});

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
                      '',
                    ),
                    _buildImageCard(
                      context,
                      'assets/Sounds.webp', // Ensure this asset exists
                      SoftLoudSoundsPage(),
                      '',
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

  // Updated image card with label text
  Widget _buildImageCard(
    BuildContext context,
    String imagePath,
    Widget destination,
    String labelText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => destination),
                ),
            child: Container(
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
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            labelText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4E69),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
