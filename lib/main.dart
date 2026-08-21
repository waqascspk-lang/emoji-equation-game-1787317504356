import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';

class Category {
  final int id;
  final String name;
  final String icon;

  Category({
    this.id = 0,
    this.name = '',
    this.icon = '',
  });

  Category copyWith({
    int? id,
    String? name,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class Level {
  final int id;
  final String emoji1;
  final String emoji2;
  final String answer;
  final int categoryId;

  Level({
    this.id = 0,
    this.emoji1 = '',
    this.emoji2 = '',
    this.answer = '',
    this.categoryId = 0,
  });

  Level copyWith({
    int? id,
    String? emoji1,
    String? emoji2,
    String? answer,
    int? categoryId,
  }) {
    return Level(
      id: id ?? this.id,
      emoji1: emoji1 ?? this.emoji1,
      emoji2: emoji2 ?? this.emoji2,
      answer: answer ?? this.answer,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] ?? 0,
      emoji1: json['emoji1'] ?? '',
      emoji2: json['emoji2'] ?? '',
      answer: json['answer'] ?? '',
      categoryId: json['categoryId'] ?? 0,
    );
  }
}

class GameProvider extends ChangeNotifier {
  Category? _selectedCategory;
  Level? _currentLevel;
  int _currentLevelIndex = 0;
  int _score = 0;
  List<int> _completedLevels = [];

  Category? get selectedCategory => _selectedCategory;
  Level? get currentLevel => _currentLevel;
  int get currentLevelIndex => _currentLevelIndex;
  int get score => _score;
  List<int> get completedLevels => _completedLevels;

  final List<Category> categories = [
    Category(id: 1, name: 'Movies', icon: '🎬'),
    Category(id: 2, name: 'Food', icon: '🍕'),
    Category(id: 3, name: 'Animals', icon: '🐶'),
  ];

  final List<Level> allLevels = [
    Level(id: 1, categoryId: 1, emoji1: '🦇', emoji2: '👨', answer: 'Batman'),
    Level(id: 2, categoryId: 1, emoji1: '🕷️', emoji2: '👨', answer: 'Spiderman'),
    Level(id: 3, categoryId: 1, emoji1: '🦁', emoji2: '👑', answer: 'LionKing'),
    Level(id: 4, categoryId: 2, emoji1: '🧀', emoji2: '🍔', answer: 'Cheeseburger'),
    Level(id: 5, categoryId: 2, emoji1: '🍎', emoji2: '🥧', answer: 'ApplePie'),
    Level(id: 6, categoryId: 2, emoji1: '🌭', emoji2: '🌭', answer: 'Hotdog'),
    Level(id: 7, categoryId: 3, emoji1: '🐱', emoji2: '🐟', answer: 'Catfish'),
    Level(id: 8, categoryId: 3, emoji1: '🐘', emoji2: '🥜', answer: 'Elephant'),
    Level(id: 9, categoryId: 3, emoji1: '🐵', emoji2: '🍌', answer: 'Monkey'),
    Level(id: 10, categoryId: 3, emoji1: '🐼', emoji2: '🎋', answer: 'Panda'),
  ];

  List<Level> get levelsForSelectedCategory {
    if (_selectedCategory == null) return [];
    return allLevels.where((l) => l.categoryId == _selectedCategory!.id).toList();
  }

  void setCategory(Category category) {
    _selectedCategory = category;
    _currentLevelIndex = 0;
    final filtered = levelsForSelectedCategory;
    if (filtered.isNotEmpty) {
      _currentLevel = filtered[0];
    }
    notifyListeners();
  }

  void loadLevel(Level level) {
    _currentLevel = level;
    final filtered = levelsForSelectedCategory;
    _currentLevelIndex = filtered.indexWhere((l) => l.id == level.id);
    notifyListeners();
  }

  bool checkAnswer(String input) {
    if (_currentLevel == null) return false;
    
    String normalizedInput = input.replaceAll(' ', '').toLowerCase();
    String normalizedAnswer = _currentLevel!.answer.replaceAll(' ', '').toLowerCase();

    if (normalizedInput == normalizedAnswer) {
      _score += 10;
      if (!_completedLevels.contains(_currentLevel!.id)) {
        _completedLevels.add(_currentLevel!.id);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void skipLevel() {
    final filtered = levelsForSelectedCategory;
    if (filtered.isEmpty) return;

    if (_currentLevelIndex < filtered.length - 1) {
      _currentLevelIndex++;
      _currentLevel = filtered[_currentLevelIndex];
    } else {
      _currentLevelIndex = 0;
      _currentLevel = filtered[0];
    }
    notifyListeners();
  }
}

class CategorySelection extends StatelessWidget {
  const CategorySelection({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emoji Equation',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Select a Category',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 3,
                  mainAxisSpacing: 20,
                ),
                itemCount: gameProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = gameProvider.categories[index];
                  return GestureDetector(
                    onTap: () {
                      context.read<GameProvider>().setCategory(category);
                      Navigator.pushNamed(context, '/levelSelection');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.icon,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
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
      ),
    );
  }
}

class LevelSelection extends StatelessWidget {
  const LevelSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Level',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, child) {
          final levels = provider.levelsForSelectedCategory;
          final selectedCategory = provider.selectedCategory;

          if (selectedCategory == null) {
            return Center(
              child: Text(
                'Please select a category first',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: provider.categories.map((category) {
                    final isSelected = selectedCategory.id == category.id;
                    return ChoiceChip(
                      label: Text(
                        '${category.icon} ${category.name}',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) {
                          context.read<GameProvider>().setCategory(category);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: levels.isEmpty
                    ? Center(
                        child: Text(
                          'No levels available in this category',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(20.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15.0,
                          mainAxisSpacing: 15.0,
                        ),
                        itemCount: levels.length,
                        itemBuilder: (context, index) {
                          final level = levels[index];
                          final isCompleted = provider.completedLevels.contains(level.id);

                          return GestureDetector(
                            onTap: () {
                              context.read<GameProvider>().loadLevel(level);
                              Navigator.pushNamed(context, '/gamePlay');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCompleted ? Colors.green.shade100 : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  color: isCompleted ? Colors.green : Colors.blue,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: isCompleted ? Colors.green.shade900 : Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                                  if (isCompleted)
                                    Positioned(
                                      right: 5,
                                      top: 5,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GamePlay extends StatefulWidget {
  @override
  _GamePlayState createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  List<String> _letterGrid = [];
  List<String> _currentGuess = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateGrid();
    });
  }

  void _generateGrid() {
    final provider = context.read<GameProvider>();
    final level = provider.currentLevel;
    if (level == null) return;

    String answerClean = level.answer.replaceAll(' ', '').toUpperCase();
    List<String> letters = answerClean.split('');

    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    while (letters.length < 12) {
      letters.add(alphabet[random.nextInt(alphabet.length)]);
    }
    letters.shuffle();

    setState(() {
      _letterGrid = letters;
      _currentGuess = [];
    });
  }

  void _onLetterTap(String letter) {
    final provider = context.read<GameProvider>();
    if (provider.currentLevel == null) return;

    int maxLength = provider.currentLevel!.answer.replaceAll(' ', '').length;
    if (_currentGuess.length < maxLength) {
      setState(() {
        _currentGuess.add(letter);
      });
    }
  }

  void _onBackspace() {
    setState(() {
      if (_currentGuess.isNotEmpty) {
        _currentGuess.removeLast();
      }
    });
  }

  void _onSolve() {
    final provider = context.read<GameProvider>();
    String guess = _currentGuess.join('');
    bool success = provider.checkAnswer(guess);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correct! +10 Points', style: TextStyle(fontWeight: FontWeight.w400)),
          backgroundColor: Colors.green,
        ),
      );

      final categoryLevels = provider.levelsForSelectedCategory;
      if (provider.currentLevelIndex >= categoryLevels.length - 1) {
        Navigator.pushReplacementNamed(context, '/victory');
      } else {
        provider.skipLevel();
        _generateGrid();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wrong answer, try again!', style: TextStyle(fontWeight: FontWeight.w400)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSkip() {
    context.read<GameProvider>().skipLevel();
    _generateGrid();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final level = provider.currentLevel;
        if (level == null) {
          return Scaffold(body: Center(child: Text('No level loaded')));
        }

        int answerLength = level.answer.replaceAll(' ', '').length;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Level ${provider.currentLevelIndex + 1}',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Center(
                  child: Text(
                    'Score: ${provider.score}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${level.emoji1} + ${level.emoji2} = ?',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  answerLength,
                  (index) => Container(
                    width: 40,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      index < _currentGuess.length ? _currentGuess[index] : '',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _letterGrid.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onLetterTap(_letterGrid[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _letterGrid[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _onBackspace,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: Text('⌫', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: _onSolve,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('SOLVE', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _onSkip,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text('SKIP', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class Victory extends StatelessWidget {
  const Victory({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.amber.shade400,
              Colors.orange.shade700,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 150,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'VICTORY!',
              style: TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You have conquered the equations!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'FINAL SCORE',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${gameProvider.score}',
                    style: const TextStyle(
                      fontSize: 64,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Equation Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CategorySelection(),
        '/levelSelection': (context) => const LevelSelection(),
        '/gamePlay': (context) => GamePlay(),
        '/victory': (context) => const Victory(),
      },
      onGenerateRoute: (settings) {
        if (settings == null) return null;
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/':
                return const CategorySelection();
              case '/levelSelection':
                return const LevelSelection();
              case '/gamePlay':
                return GamePlay();
              case '/victory':
                return const Victory();
              default:
                return const CategorySelection();
            }
          },
        );
      },
    );
  }
}
