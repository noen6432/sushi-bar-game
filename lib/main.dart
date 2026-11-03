import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SushiBarApp());
}

class SushiBarApp extends StatelessWidget {
  const SushiBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokyo Sushi Bar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1E1E24),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const SushiGameScreen(),
    );
  }
}

class Recipe {
  final String name;
  final String icon;
  final List<String> ingredients;
  final int points;

  const Recipe({
    required this.name,
    required this.icon,
    required this.ingredients,
    required this.points,
  });
}

class Customer {
  final String name;
  final String avatar;
  final Recipe desiredSushi;

  Customer({
    required this.name,
    required this.avatar,
    required this.desiredSushi,
  });
}

class SushiGameScreen extends StatefulWidget {
  const SushiGameScreen({super.key});

  @override
  State<SushiGameScreen> createState() => _SushiGameScreenState();
}

class _SushiGameScreenState extends State<SushiGameScreen> {
  static const List<Recipe> recipes = [
    Recipe(
      name: 'Salmon Nigiri',
      icon: '🍣',
      ingredients: ['Rice', 'Salmon'],
      points: 20,
    ),
    Recipe(
      name: 'Tuna Roll',
      icon: '🍙',
      ingredients: ['Nori', 'Rice', 'Tuna'],
      points: 30,
    ),
    Recipe(
      name: 'Avocado Maki',
      icon: '🍱',
      ingredients: ['Nori', 'Rice', 'Avocado'],
      points: 25,
    ),
  ];

  static const List<String> customerNames = ['Kenji', 'Sakura', 'Hiroshi', 'Yuki'];
  static const List<String> customerAvatars = ['👨‍💼', '👩‍🦰', '🧑‍🎓', '🧓'];

  final List<String> availableIngredients = ['Rice', 'Nori', 'Salmon', 'Tuna', 'Avocado'];
  final List<String> currentPrepPlate = [];

  int score = 0;
  int timeLeft = 60;
  Timer? gameTimer;
  Customer? currentCustomer;
  String feedbackMessage = 'Welcome to Tokyo Sushi Bar!';

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    score = 0;
    timeLeft = 60;
    currentPrepPlate.clear();
    spawnCustomer();

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        timer.cancel();
        showGameOverDialog();
      }
    });
  }

  void spawnCustomer() {
    final rand = Random();
    final randomRecipe = recipes[rand.nextInt(recipes.length)];
    final randomName = customerNames[rand.nextInt(customerNames.length)];
    final randomAvatar = customerAvatars[rand.nextInt(customerAvatars.length)];

    setState(() {
      currentCustomer = Customer(
        name: randomName,
        avatar: randomAvatar,
        desiredSushi: randomRecipe,
      );
    });
  }

  void addIngredient(String item) {
    if (timeLeft <= 0) return;
    setState(() {
      currentPrepPlate.add(item);
    });
  }

  void clearPlate() {
    setState(() {
      currentPrepPlate.clear();
      feedbackMessage = 'Plate cleared!';
    });
  }

  void serveOrder() {
    if (currentCustomer == null || timeLeft <= 0) return;

    final targetRecipe = currentCustomer!.desiredSushi;
    final targetList = List<String>.from(targetRecipe.ingredients)..sort();
    final currentList = List<String>.from(currentPrepPlate)..sort();

    bool isMatch = targetList.length == currentList.length;
    if (isMatch) {
      for (int i = 0; i < targetList.length; i++) {
        if (targetList[i] != currentList[i]) {
          isMatch = false;
          break;
        }
      }
    }

    setState(() {
      if (isMatch) {
        score += targetRecipe.points;
        feedbackMessage = 'Correct Order! +${targetRecipe.points} pts for ${targetRecipe.name}!';
        currentPrepPlate.clear();
        spawnCustomer();
      } else {
        score = max(0, score - 10);
        feedbackMessage = 'Wrong recipe! -10 pts. Customer is disappointed.';
        currentPrepPlate.clear();
      }
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2B36),
        title: const Text('Shift Ended!', style: TextStyle(color: Colors.white)),
        content: Text(
          'Final Score: $score\nGreat job serving sushi lovers today!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: const Text('Play Again', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥢 Tokyo Sushi Bar Express', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000),
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar: Score & Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: $score pts', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                  Text('Time: ${timeLeft}s', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),

            // Customer Order Section
            if (currentCustomer != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepOrange.shade300, width: 2),
                ),
                child: Row(
                  children: [
                    Text(currentCustomer!.avatar, style: const TextStyle(fontSize: 48)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${currentCustomer!.name} wants:', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          Text(
                            '${currentCustomer!.desiredSushi.icon} ${currentCustomer!.desiredSushi.name}',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Recipe: ${currentCustomer!.desiredSushi.ingredients.join(" + ")}',
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Feedback Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                feedbackMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),

            const Spacer(),

            // Chef's Cutting Board / Prep Plate
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3F2B20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown.shade300, width: 2),
              ),
              child: Column(
                children: [
                  const Text('🥢 Chef Prep Board (Selected Ingredients)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: currentPrepPlate.isEmpty
                        ? const Text('Tap ingredients below to prepare sushi', style: TextStyle(color: Colors.white38))
                        : Wrap(
                            spacing: 8,
                            children: currentPrepPlate.map((e) => Chip(
                              label: Text(e, style: const TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.white,
                            )).toList(),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Serve & Trash Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: clearPlate,
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text('Trash', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: serveOrder,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('Serve Order', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
              ],
            ),

            const Spacer(),

            // Ingredients Pantry
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF141419),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Text('Pantry Ingredients', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: availableIngredients.map((ingredient) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E2E38),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () => addIngredient(ingredient),
                        child: Text(ingredient),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
