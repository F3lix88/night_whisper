import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(NightWhisperApp());
}

class NightWhisperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  String _displayText = "";
  String _fullText = "NIGHT WHISPER";
  int _textIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isFirstLogin = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasLoggedIn = prefs.getBool('hasLoggedIn') ?? false;
    if (hasLoggedIn) {
      setState(() => _isFirstLogin = false);
    }
    _startTyping();
  }

  void _startTyping() {
    _fadeController.forward();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() => _displayText += _fullText[_textIndex]);
        _textIndex++;
      } else {
        timer.cancel();
      }
    });
  }

  void _startSession() {
    if (_isFirstLogin) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('hasLoggedIn', true);
      });
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConnectingScreen()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Colors.deepPurple[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _displayText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 48,
                    shadows: [
                      Shadow(color: Colors.white, blurRadius: 5),
                      Shadow(color: Colors.grey, blurRadius: 10),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: ElevatedButton(
                  onPressed: _startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.deepPurpleAccent),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    "Whisper to Me",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectingScreen extends StatefulWidget {
  @override
  _ConnectingScreenState createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends State<ConnectingScreen> with SingleTickerProviderStateMixin {
  String _displayText = "";
  String _fullText = "Connecting to the void operator";
  int _textIndex = 0;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_blinkController);
    _startTyping();
  }

  void _startTyping() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() => _displayText += _fullText[_textIndex]);
        _textIndex++;
      } else {
        timer.cancel();
        Timer.periodic(Duration(milliseconds: 500), (dotTimer) {
          setState(() {
            _displayText = _fullText + "." * (dotTimer.tick % 4);
          });
          if (dotTimer.tick == 6) {
            dotTimer.cancel();
            setState(() => _displayText = "Link established...");
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => QuestionsScreen()),
              );
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Colors.deepPurple[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _displayText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      shadows: [
                        Shadow(color: Colors.white, blurRadius: 5),
                        Shadow(color: Colors.grey, blurRadius: 10),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                FadeTransition(
                  opacity: _blinkAnimation,
                  child: Text(
                    "|",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionsScreen extends StatefulWidget {
  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> with SingleTickerProviderStateMixin {
  int _questionIndex = 0;
  List<String> _answers = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  final List<List<String>> _questions = [
    ["What’s keeping you up tonight?", "Fear", "Wonder", "Something Else"],
    ["Pick a night sound—what’s in your head?", "Whispers", "Wind", "Silence"],
    ["Are you chasing answers or running from them?", "Chasing", "Running"],
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _blinkController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_blinkController);
    _fadeController.forward();
  }

  void _submitAnswer(String answer) {
    _answers.add(answer);
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _fadeController.forward();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponseScreen(answers: _answers),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Colors.deepPurple[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _questions[_questionIndex][0],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 24,
                            shadows: [
                              Shadow(color: Colors.white, blurRadius: 5),
                              Shadow(color: Colors.grey, blurRadius: 10),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                      FadeTransition(
                        opacity: _blinkAnimation,
                        child: Text(
                          "|",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  ..._questions[_questionIndex].sublist(1).map((answer) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _submitAnswer(answer),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: BorderSide(color: Colors.deepPurpleAccent),
                            ),
                            child: Text(
                              answer,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResponseScreen extends StatefulWidget {
  final List<String> answers;
  ResponseScreen({required this.answers});

  @override
  _ResponseScreenState createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> with SingleTickerProviderStateMixin {
  String _displayText = "";
  String _fullText = "";
  int _textIndex = 0;
  int _exchangeCount = 0;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;
  String _userFollowUp = "";
  bool _showInput = false;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_blinkController);
    _generateResponse();
    _playResponse();
    _startTyping();
  }

  void _generateResponse() {
    // Use answers to craft a response
    String mood = widget.answers[0].toLowerCase(); // e.g., "Fear"
    String sound = widget.answers[1].toLowerCase(); // e.g., "Whispers"
    String intent = widget.answers[2].toLowerCase(); // e.g., "Running"

    // Simulate Grok API response for now
    // In a real app, this would call Grok API and then Sesame CSM
    if (mood == "fear" && sound == "whispers" && intent == "running") {
      _fullText = "Fear courses through you, doesn’t it? The whispers in the dark are relentless, chasing you as you run from their truths. They speak of things you’d rather forget—memories that cling like damp shadows. What are you so afraid of facing?";
    } else if (mood == "wonder" && sound == "wind" && intent == "chasing") {
      _fullText = "Wonder fills your mind, a restless wind blowing through your thoughts. You’re chasing something intangible, aren’t you? A dream, a question, a fleeting spark in the night. The wind carries answers, but they slip through your fingers—what are you hoping to catch?";
    } else if (mood == "something else" && sound == "silence" && intent == "running") {
      _fullText = "Something else gnaws at you, in the heavy silence of the night. You’re running, but silence is a cruel companion—it amplifies the thoughts you’re trying to escape. What’s hiding in that quiet, waiting for you to stop?";
    } else {
      _fullText = "The night holds you in its grip—${mood} stirs within, with the sound of ${sound} echoing in your mind. You’re ${intent}, but the night has its own plans. What drives you through this darkness?";
    }
  }

  Future<void> _playResponse() async {
    try {
      // Simulate calling Grok API
      // String grokResponse = await _callGrokApi(widget.answers);
      // For now, use _fullText as the response

      // Simulate calling Sesame CSM (to be hosted on Render)
      // String audioUrl = await _callSesameCSM(_fullText);
      String audioUrl = "https://example.com/fake-audio.mp3"; // Placeholder

      // Play the audio
      await _player.setUrl(audioUrl);
      _player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<String> _callGrokApi(List<String> answers) async {
    // Placeholder for Grok API call
    // Replace with actual API call once you have the key
    final response = await http.post(
      Uri.parse('https://api.xai.com/v1/grok'),
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': 'Generate a long, philosophical response based on these answers: mood=${answers[0]}, sound=${answers[1]}, intent=${answers[2]}. Keep it on-topic and end with a guiding question.',
        'max_tokens': 200,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['text'];
    } else {
      return "The void is silent... something went wrong.";
    }
  }

  Future<String> _callSesameCSM(String text) async {
    // Placeholder for Sesame CSM call (to be hosted on Render)
    final response = await http.post(
      Uri.parse('https://your-render-app.onrender.com/generate-audio'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['audioUrl'];
    } else {
      throw Exception('Failed to generate audio');
    }
  }

  void _startTyping() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() => _displayText += _fullText[_textIndex]);
        _textIndex++;
      } else {
        timer.cancel();
        _blinkController.stop();
        if (_exchangeCount < 2) { // Limit to 3 exchanges (0, 1, 2)
          setState(() => _showInput = true);
        } else {
          // End the session
          Timer(Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }
      }
    });
  }

  void _submitFollowUp(String text) {
    setState(() {
      _userFollowUp = text;
      _displayText = "";
      _textIndex = 0;
      _showInput = false;
      _exchangeCount++;
    });

    // Generate a follow-up response
    if (_exchangeCount == 1) {
      _fullText = "You say: '$_userFollowUp'. The night listens, its shadows curling closer. Your words echo in the void, stirring something deeper. What does that make you feel now?";
    } else {
      _fullText = "You feel: '$_userFollowUp'. The night has heard enough—it wraps you in its embrace, leaving you with this: some questions have no answers, only echoes. Farewell.";
    }

    _playResponse();
    _startTyping();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _player.pause();
      } else {
        _player.play();
      }
    });
  }

  void _stopAndReset() {
    _player.stop();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _displayText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 24,
                            shadows: [
                              Shadow(color: Colors.white, blurRadius: 5),
                              Shadow(color: Colors.grey, blurRadius: 10),
                            ],
                          ),
                          softWrap: true,
                        ),
                      ),
                      if (_textIndex < _fullText.length)
                        FadeTransition(
                          opacity: _blinkAnimation,
                          child: Text(
                            "|",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_showInput) ...[
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Your thoughts...",
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurpleAccent),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurpleAccent),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurpleAccent),
                              ),
                            ),
                            onSubmitted: _submitFollowUp,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.deepPurpleAccent),
                          onPressed: () => _submitFollowUp(_userFollowUp),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: AnimatedOpacity(
              opacity: 0.7,
              duration: Duration(seconds: 2),
              child: IconButton(
                icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                iconSize: 20,
                onPressed: _toggleMute,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: AnimatedOpacity(
              opacity: 0.7,
              duration: Duration(seconds: 2),
              child: IconButton(
                icon: Icon(Icons.stop, color: Colors.white),
                iconSize: 20,
                onPressed: _stopAndReset,
              ),
            ),
          ),
        ],
      ),
    );
  }
}