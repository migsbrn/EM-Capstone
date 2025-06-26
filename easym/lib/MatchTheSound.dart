import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MatchSoundPage extends StatefulWidget {
  const MatchSoundPage({super.key});

  @override
  State<MatchSoundPage> createState() => _MatchSoundPageState();
}

class _MatchSoundPageState extends State<MatchSoundPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _mainPlayer = AudioPlayer();
  final List<AudioPlayer> _optionPlayers = List.generate(
    4,
    (_) => AudioPlayer(),
  );
  final FlutterTts _flutterTts = FlutterTts();

  final String mainSound = 'sound/dog_bark.mp3';
  final List<String> optionSounds = [
    'sound/bark1.mp3',
    'sound/bark2.mp3',
    'sound/dog_bark.mp3', // correct match
    'sound/bark3.mp3',
  ];
  final List<String> dogImages = [
    'assets/dogg.jpg',
    'assets/dogg.jpg',
    'assets/dogg.jpg',
    'assets/dogg.jpg',
  ];

  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  int? _selectedOption;
  int _score = 0;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _mainPlayer.dispose();
    for (var player in _optionPlayers) {
      player.dispose();
    }
    _flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }

  void _playMainSound() async {
    await _mainPlayer.stop();
    await _mainPlayer.play(AssetSource(mainSound));
    _animationController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2));
    _animationController.stop();
    _animationController.reset();
  }

  void _playOptionSound(int index) async {
    for (int i = 0; i < _optionPlayers.length; i++) {
      if (i != index) {
        await _optionPlayers[i].stop();
      }
    }
    await _flutterTts.stop();
    await _optionPlayers[index].play(AssetSource(optionSounds[index]));
    setState(() {
      _selectedOption = index;
    });
  }

  void _confirmSelection() async {
    if (_isDialogOpen || _selectedOption == null) {
      if (_selectedOption == null)
        await _flutterTts.speak("Please select an option first!");
      return;
    }

    _isDialogOpen = true;
    if (optionSounds[_selectedOption!] == mainSound) {
      setState(() {
        _score++;
      });
      await _flutterTts.speak("Correct!");
      _showFeedbackDialog("Great job! You matched the sound correctly!");
    } else {
      await _flutterTts.speak("Try again!");
      _showFeedbackDialog("Oops! That wasn't the right match. Try again.");
    }
  }

  void _showFeedbackDialog(String feedbackMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFFBEED9),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: 400,
                height: 350, // Reduced width to 250 (adjustable as needed)
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.volume_up,
                      size: 50,
                      color: Color(0xFF4A6C82),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Your Score",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22223B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$_score",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Text(
                        feedbackMessage,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _isDialogOpen = false;
                                _selectedOption = null;
                              });
                              _playMainSound(); // Replay the main sound
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5DB2FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.replay, size: 24),
                                SizedBox(width: 8),
                                Text("Retry"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              setState(() {
                                _isDialogOpen = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF648BA2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text("Back to Games"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    ).then((_) {
      setState(() {
        _isDialogOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIpad = MediaQuery.of(context).size.shortestSide >= 600;
    final double boxSize = isIpad ? 320 : 200;
    final double imageSize = isIpad ? 280 : 160;

    return Scaffold(
      backgroundColor: const Color(0xFFF0EBD8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 20),
              const Text(
                'Match The Sound',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A6C82),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Removed the score display from here
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 80 * _waveAnimation.value,
                        height: 80 * _waveAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withOpacity(0.2),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 60 * _waveAnimation.value,
                        height: 60 * _waveAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    iconSize: isIpad ? 70 : 60,
                    icon: const Icon(Icons.play_circle_filled_rounded),
                    color: const Color(0xFF4A6C82),
                    onPressed: _playMainSound,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => _buildImageButton(index, boxSize, imageSize),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) =>
                          _buildImageButton(index + 2, boxSize, imageSize),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6C82),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm Selection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton(int index, double boxSize, double imageSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () => _playOptionSound(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: boxSize,
          width: boxSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                _selectedOption == index
                    ? Colors.blue.shade50
                    : Colors.grey.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _selectedOption == index
                      ? Colors.blue.shade300
                      : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    dogImages[index],
                    height: imageSize,
                    width: imageSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.volume_up_rounded,
                  size: 36,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
