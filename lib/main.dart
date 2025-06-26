import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SurveyProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survey App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
          secondary: Colors.teal,
          background: Colors.grey[100],
          surface: Colors.white,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 6,
          shadowColor: Colors.deepPurple.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          headlineMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          titleMedium: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black54),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/survey': (context) => const SurveyScreen(),
        '/results': (context) => const ResultsScreen(),
        '/nasaPhotos': (context) => const NasaPhotosScreen(),
      },
    );
  }
}

class SurveyProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  final List<Question> _questions = [
    Question(
      id: 1,
      text: 'What is the capital of France?',
      options: ['Paris', 'London', 'Berlin', 'Madrid'],
      correctAnswer: 0,
    ),
    Question(
      id: 2,
      text: 'What is 2 + 2?',
      options: ['3', '4', '5', '6'],
      correctAnswer: 1,
    ),
    Question(
      id: 3,
      text: 'Which planet is known as the Red Planet?',
      options: ['Jupiter', 'Mars', 'Venus', 'Mercury'],
      correctAnswer: 1,
    ),
    Question(
      id: 4,
      text: 'What is the largest mammal?',
      options: ['Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus'],
      correctAnswer: 1,
    ),
    Question(
      id: 5,
      text: 'Who painted the Mona Lisa?',
      options: ['Vincent van Gogh', 'Leonardo da Vinci', 'Pablo Picasso', 'Claude Monet'],
      correctAnswer: 1,
    ),
    Question(
      id: 6,
      text: 'What is the chemical symbol for water?',
      options: ['H2O', 'CO2', 'O2', 'N2'],
      correctAnswer: 0,
    ),
    Question(
      id: 7,
      text: 'Which country hosted the 2020 Olympics?',
      options: ['Brazil', 'Japan', 'China', 'Australia'],
      correctAnswer: 1,
    ),
    Question(
      id: 8,
      text: 'What is the smallest prime number?',
      options: ['1', '2', '3', '5'],
      correctAnswer: 1,
    ),
    Question(
      id: 9,
      text: 'Which gas is most abundant in Earth\'s atmosphere?',
      options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Argon'],
      correctAnswer: 1,
    ),
    Question(
      id: 10,
      text: 'Who wrote "Romeo and Juliet"?',
      options: ['William Shakespeare', 'Jane Austen', 'Charles Dickens', 'Mark Twain'],
      correctAnswer: 0,
    ),
  ];
  Map<int, int> _userAnswers = {};
  double _score = 0.0;
  List<Photo> _nasaPhotos = [];
  Timer? _sessionTimer;

  bool get isLoggedIn => _isLoggedIn;
  List<Question> get questions => _questions;
  Map<int, int> get userAnswers => _userAnswers;
  double get score => _score;
  List<Photo> get nasaPhotos => _nasaPhotos;

  SurveyProvider() {
    _fetchNasaPhotos();
  }

  bool login(String mobile, String otp) {
    if (otp == '112233') {
      _isLoggedIn = true;
      _startSessionTimer(context: null);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout(BuildContext context) {
    _isLoggedIn = false;
    _userAnswers = {};
    _score = 0.0;
    _sessionTimer?.cancel();
    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _startSessionTimer({required BuildContext? context}) {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: 10), () {
      if (_isLoggedIn && context != null) {
        logout(context);
      }
    });
  }

  void submitAnswer(int questionId, int answerIndex) {
    _userAnswers[questionId] = answerIndex;
    debugPrint('User Answers: $_userAnswers');
    notifyListeners();
  }

  void calculateScore() {
    double totalScore = 0.0;
    for (var entry in _userAnswers.entries) {
      final question = _questions.firstWhere((q) => q.id == entry.key);
      totalScore += (question.correctAnswer == entry.value) ? 1.0 : -0.5;
    }
    _score = totalScore;
    debugPrint('Score: $_score');
    notifyListeners();
  }

  Future<void> _fetchNasaPhotos() async {
    final response = await http.get(
      Uri.parse(
          'https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=3000&api_key=DEMO_KEY'),
    );
    debugPrint('API Response Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _nasaPhotos = (data['photos'] as List)
          .take(10)
          .map((photo) {
            final imgSrc = photo['img_src'].toString().startsWith('http://')
                ? photo['img_src'].toString().replaceFirst('http://', 'https://')
                : photo['img_src'].toString();
            debugPrint('Image URL: $imgSrc');
            return Photo(
              id: photo['id'],
              imgSrc: imgSrc,
              earthDate: photo['earth_date'],
            );
          })
          .toList();
      debugPrint('NASA Photos List: ${_nasaPhotos.map((photo) => photo.imgSrc).toList()}');
      notifyListeners();
    } else {
      debugPrint('API Request Failed: ${response.reasonPhrase}');
    }
  }
}

class Question {
  final int id;
  final String text;
  final List<String> options;
  final int correctAnswer;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
  });
}

class Photo {
  final int id;
  final String imgSrc;
  final String earthDate;

  Photo({required this.id, required this.imgSrc, required this.earthDate});
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  String? error;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.quiz_rounded,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  'Survey App',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.deepPurple,
                      ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await Future.delayed(const Duration(milliseconds: 500));
                          if (provider.login(mobileController.text, otpController.text)) {
                            Navigator.pushNamed(context, '/survey');
                          } else {
                            setState(() {
                              error = 'Invalid OTP';
                            });
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          elevation: 2,
                        ),
                        child: const Text('Login'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);
    provider._startSessionTimer(context: context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Survey', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: provider.questions.length + 1,
          itemBuilder: (context, index) {
            if (index == provider.questions.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: AnimatedOpacity(
                  opacity: provider.userAnswers.length == provider.questions.length ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: provider.userAnswers.length == provider.questions.length
                        ? () {
                            provider.calculateScore();
                            Navigator.pushNamed(context, '/results');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Colors.teal,
                      elevation: 2,
                    ),
                    child: const Text('Submit Answers'),
                  ),
                ),
              );
            }
            final question = provider.questions[index];
            return QuestionCard(
              question: question,
              selectedAnswer: provider.userAnswers[question.id],
              onAnswerSelected: (answerIndex) => provider.submitAnswer(question.id, answerIndex),
              isSubmitted: provider.userAnswers.length == provider.questions.length,
            );
          },
        ),
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;
  final bool isSubmitted;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerSelected,
    required this.isSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return RadioListTile<int>(
                  value: index,
                  groupValue: selectedAnswer,
                  onChanged: isSubmitted ? null : (value) => onAnswerSelected(value!),
                  title: Text(
                    option,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isSubmitted && index == question.correctAnswer
                              ? Colors.green
                              : isSubmitted && selectedAnswer == index && index != question.correctAnswer
                                  ? Colors.red
                                  : Colors.black87,
                        ),
                  ),
                  activeColor: Colors.teal,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);
    final passStatus = provider.score > 8.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Results', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: ${provider.score.toStringAsFixed(1)}/10',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: passStatus ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          passStatus ? 'Pass' : 'Fail',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: passStatus ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.questions.length,
                  itemBuilder: (context, index) {
                    final question = provider.questions[index];
                    return QuestionCard(
                      question: question,
                      selectedAnswer: provider.userAnswers[question.id],
                      onAnswerSelected: (_) {},
                      isSubmitted: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/nasaPhotos'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.teal,
                  elevation: 2,
                ),
                child: const Text('View NASA Photos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NasaPhotosScreen extends StatelessWidget {
  const NasaPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Mars Rover Photos', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: provider.nasaPhotos.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.nasaPhotos.length,
                itemBuilder: (context, index) {
                  final photo = provider.nasaPhotos[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.deepPurple.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Add tap action if needed (e.g., zoom image)
                          debugPrint('Tapped photo ID: ${photo.id}');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Side: Image
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(16),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: photo.imgSrc,
                                height: 120,
                                width: 150,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.teal),
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  debugPrint('Image Load Error: $url, Error: $error');
                                  return Container(
                                    height: 120,
                                    width: 150,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Right Side: Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name: Photo ID ${photo.id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Earth Date: ${photo.earthDate}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.black87,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Status: Available',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.green,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}