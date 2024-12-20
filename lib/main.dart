import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const DopeWarsAtlanta());
}

class Location {
  final String name;
  final String description;
  final bool isCobbCounty;

  Location({
    required this.name,
    required this.description,
    this.isCobbCounty = false,
  });
}

class Product {
  String name;
  double basePrice;
  double minPrice;
  double maxPrice;

  Product({
    required this.name,
    required this.basePrice,
    required this.minPrice,
    required this.maxPrice,
  });
}

class DopeWarsAtlanta extends StatelessWidget {
  const DopeWarsAtlanta({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dope Wars Atlanta',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(38, 13, 53, 1), // Accent color
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white), // Set body text to white
          titleLarge: TextStyle(color: Colors.white), // Set title text to white
          titleMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF240C38),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        scaffoldBackgroundColor:
            const Color(0xFF1a1625), // Dark gray background
        cardColor:
            const Color(0xFF2a2438), // Slightly lighter purple card color
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Color.fromARGB(255, 82, 23, 116),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
      ),
      home: GameHomePage(),
    );
  }
}

List<Product> allProducts = [
  Product(name: 'Blunts/Pre Rolls', basePrice: 60, minPrice: 40, maxPrice: 120),
  Product(name: 'Oxy', basePrice: 20, minPrice: 5, maxPrice: 80),
  Product(name: 'Shrooms', basePrice: 150, minPrice: 70, maxPrice: 350),
  Product(name: 'Powda', basePrice: 120, minPrice: 60, maxPrice: 325),
  Product(name: 'Acid', basePrice: 55, minPrice: 10, maxPrice: 130),
];

class GameHomePage extends StatefulWidget {
  final List<Location> locations = [
    Location(
      name: 'Midtown',
      description: 'Fox Theater and that rainbow crosswalk',
    ),
    Location(
      name: 'Buckhead',
      description: 'Old money and highrises',
    ),
    Location(
      name: 'Cobb County',
      description: 'Technically ITP so don"t stay here long',
      isCobbCounty: true,
    ),
    Location(
      name: 'Little Five Points',
      description: 'Hipters everywhere. Only place to buy bigger bookbags',
    ),
    Location(
      name: 'Decatur',
      description: 'It"s the souf side obviously',
    ),
    Location(
      name: 'West End',
      description: 'Thriller without the music and dancing',
    ),
  ];

  GameHomePage({super.key});

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  late List<Location> locations;
  late Map<Location, List<Product>> locationProducts;
  Location? selectedLocation;
  int cash = 4000;
  int debt = 10000;
  int bookbag = 100;
  int day = 1;
  Map<Product, int> inventory = {}; // Initialize inventory map
  bool isRydeAvailable = true;

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic(); 
    locationProducts = {}; // Initialize locationProducts as an empty map
    locations = widget.locations;
    inventory = {}; // Initialize the inventory in initState

    final random = Random();
    for (var location in locations) {
      locationProducts[location] = [];
      for (var i = 0; i < random.nextInt(3) + 2; i++) {
        locationProducts[location]!
            .add(allProducts[random.nextInt(allProducts.length)]);
      }
    }
  }

  // ... (other functions) ...

  void _showAnimationOverlay(String option) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.black54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedIcon(
                icon: option == 'MARTA'
                    ? AnimatedIcons.train
                    : option == 'Ryde'
                        ? AnimatedIcons.taxi
                        : AnimatedIcons.car_travel,
                progress: AlwaysStoppedAnimation(1), // Always show the end state
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Traveling...',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ],
          ),
        ),
      );
    },
  );

  Timer(const Duration(seconds: 2), () {
    Navigator.of(context).pop();
  });
}

  Future<void> _playBackgroundMusic() async {
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource('background_music.mp3'));
    player.setReleaseMode(ReleaseMode.loop);

    // Ensure the player is released when the game is closed
    // (e.g., in the dispose method of your stateful widget)
    // player.dispose();
  }

  void travel(Location location) async {
    if (location.isCobbCounty) {
      _showTravelOptions(location, ['Ryde', 'Drive']);
    } else {
      _showTravelOptions(location, ['MARTA', 'Ryde', 'Drive']);
    }
    setState(() {
      day += 1;
    });
    _checkGameOver();
  }

  void _showTravelOptions(Location location, List<String> options) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text('Travel to ${location.name}', style: const TextStyle(color: Colors.black)), content: Column(mainAxisSize: MainAxisSize.min, children: options.map((option) {int cost = _getTravelCost(option, location.isCobbCounty);return ListTile(title: Text('$option - \$${cost.toString()}', style: const TextStyle(color: Colors.black)), onTap: () {if (cash >= cost) {setState(() {cash -= cost;selectedLocation = location;if (option == 'Ryde') {isRydeAvailable = false;Timer(const Duration(minutes: 1), () {setState(() {isRydeAvailable = true;});});}});Navigator.of(context).pop();_showAnimationOverlay(option);_checkForPolice(option);} else {Navigator.of(context).pop();_showInsufficientFundsMessage();}});}).toList()),);
      },
    );
    _checkGameOver();
  }

  void _checkForPolice(String option) {
    final random = Random();
    int chance = random.nextInt(100);

    switch (option) {
      case 'MARTA':
        if (chance < 3) {
          _handlePoliceEncounter('MARTA');
        }
        break;
      case 'Ryde':
        if (chance < 3) {
          _handlePoliceEncounter('Ryde');
        }
        break;
      case 'Drive':
        if (chance < 6) {
          _handlePoliceEncounter('Drive');
        }
        break;
    }
  }

  void _handlePoliceEncounter(String option) {
    switch (option) {
      case 'MARTA':
        _showPoliceEncounterDialog(
          'MARTA Police',
          'You have been confronted by MARTA police. Do you want to Run or Fight?',
          () => _runFromPolice('MARTA'),
          () => _fightPolice('MARTA'),
        );
        break;
      case 'Ryde':
        _showPoliceEncounterDialog(
          'Undercover Cop',
          'You have encountered an undercover cop. Do you want to try to bribe them?',
          () => _bribePolice(),
          null,
        );
        break;
      case 'Drive':
        _showPoliceEncounterDialog(
          'GSP',
          'You are being chased by the Georgia State Patrol. Do you want to Run or Fight?',
          () => _runFromPolice('Drive'),
          () => _fightPolice('Drive'),
        );
        break;
    }
  }

  void _showPoliceEncounterDialog(
      String title, String content, VoidCallback onRun, VoidCallback? onFight) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.black)),
          content: Text(content, style: const TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              child: const Text('Run', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
                onRun();
              },
            ),
            if (onFight != null)
              TextButton(
                child:
                    const Text('Fight', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                  onFight();
                },
              ),
          ],
        );
      },
    );
  }

  void _runFromPolice(String encounterType) {
    final random = Random();
    int chance = random.nextInt(100);

    if (encounterType == 'MARTA' && chance < 6) {
      _showOutcomeDialog(
          'Caught',
          'You were caught while running. You lose 7% of your inventory and 2% of your cash.',
        );
      setState(() {
        bookbag = (bookbag * 0.93).toInt();
        cash = (cash * 0.98).toInt();
      });
    } else if (encounterType == 'Drive' && chance < 75) {
      _gameOver('You were caught by the GSP. The game is over.');
    } else {
      _showOutcomeDialog('Escaped', 'You successfully escaped.');
    }
    _checkGameOver();
  }

  void _fightPolice(String encounterType) {
    final random = Random();
    int chance = random.nextInt(100);

    if (encounterType == 'MARTA' && chance < 8) {
      _showOutcomeDialog(
          'Caught',
          'You lost the fight. You lose 11% of your inventory and 15% of your cash.',
        );
      setState(() {
        bookbag = (bookbag * 0.89).toInt();
        cash = (cash * 0.85).toInt();
      });
    } else {
      _checkGameOver();
      _showOutcomeDialog('Escaped', 'You successfully fought off the police.');
    }
    _checkGameOver();
  }

  void _bribePolice() {
    final random = Random();
    int chance = random.nextInt(100);

    if (chance < 40) {
      _showOutcomeDialog(
          'Bribed', 'You successfully bribed the undercover cop.');
    } else if (chance < 48) {
      _showOutcomeDialog('Arrested',
          'The undercover cop arrested you anyway. You lose all your inventory and half of your cash.');
      setState(() {
        bookbag = 0;
        cash = (cash * 0.5).toInt();
      });
    } else {
      _checkGameOver();
      _showOutcomeDialog('Escaped', 'You successfully escaped.');
    }
  }

  void _showOutcomeDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.black)),
          content: Text(content, style: const TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  int _getTravelCost(String option, bool isCobbCounty) {
    final now = DateTime.now();
    final hour = now.hour;
    final random = Random();
    int cost = 0;

    switch (option) {
      case 'MARTA':
        cost = 5;
        break;
      case 'Ryde':
        if (isCobbCounty) {
          cost = random.nextInt(41) + 20; // $20 - $60
        } else {
          if (hour >= 8 && hour <= 18) {
            cost = random.nextInt(51) + 10; // $10 - $60
          } else {
            cost = random.nextInt(21) + 10; // $10 - $30
          }
        }
        break;
      case 'Drive':
        cost = isCobbCounty ? 40 : 20;
        break;
    }

    return cost;
  }

  void _showInsufficientFundsMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insufficient Funds',
              style: TextStyle(color: Colors.black)),
          content: const Text('You do not have enough cash to travel.',
              style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Renamed to _buildBody
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dope Wars - ATL'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cash:',
                            style: TextStyle(
                                color: Color(0xFF00FF9D), fontSize: 16)),
                        Text('\$${cash.toString()}',
                            style: const TextStyle(
                                color: Color(0xFF00FF9D), fontSize: 16)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Debt:',
                            style: TextStyle(
                                color: Color(0xFFFF00F7), fontSize: 16)),
                        Text('\$${debt.toString()}',
                            style: const TextStyle(
                                color: Color(0xFFFF00F7), fontSize: 16)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bookbag:',
                              style: TextStyle(
                                  color: Color(0xFF00FF9D), fontSize: 16)),
                          Text('$bookbag',
                              style: const TextStyle(
                                  color: Color(0xFF00FF9D), fontSize: 16)),
                        ]),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Day:',
                        style:
                            TextStyle(color: Color(0xFF00FF9D), fontSize: 16)),
                    Text('$day/30',
                        style: const TextStyle(
                            color: Color(0xFF00FF9D), fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                final products = locationProducts[location]!;
                final isSelected = location == selectedLocation;
                return Card(
                  margin: const EdgeInsets.all(10),
                  color: isSelected ? const Color(0xFF3A2C46) : const Color(0xFF2a2438), // Change color if selected
                  child: ExpansionTile(
                    title: Text(location.name, style: const TextStyle(color: Colors.white)), 
                    subtitle: Text(location.description, style: const TextStyle(color: Colors.white)), 
                    onExpansionChanged: (isExpanded) {
                      if (isExpanded) {
                        setState(() {
                          selectedLocation = location; 
                        });
                      } else {
                        setState(() {
                          selectedLocation = null; 
                        });
                      }
                    },
                    initiallyExpanded: isSelected, 
                    children: isSelected ?
                      [
                        ...products.map((product) => ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${product.name} - \$${product.basePrice.toInt()}', style: const TextStyle(color: Colors.white)),
                                  Text('Inventory: ${(inventory[product.name] ?? 0)}', style: const TextStyle(color: Colors.white)), 
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  _buyProduct(product);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF9D), foregroundColor: Colors.black),
                                child: const Text('Buy'),
                              ),
                            )),
                      ] 
                      : [], 
                  )
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _checkGameOver() {
    if (day > 30) {    
      _gameOver('You have run out of days!');
    } else if (bookbag == 0 && cash < allProducts.map((p) => p.minPrice).reduce(min)) {
      _gameOver('You are out of product and do not have enough cash to buy more!');
    } else if (cash <= 0 && bookbag == 0 && inventory.values.every((quantity) => quantity == 0)) {
      _gameOver('You have no cash, no product, and an empty bookbag!');
    }
  }

  void _gameOver(String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Game Over', style: TextStyle(color: Colors.black)),
        content: Text(message, style: const TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            child: const Text('Restart', style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
          ),
          TextButton(
            child: const Text('Exit', style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally, you can exit the app or navigate to a different screen
            },
          ),
        ],
      );
    },
  );
  }

void _restartGame() {
  setState(() {
    cash = 4000;
    debt = 10000;
    bookbag = 100;
    day = 1;
    selectedLocation = null;
    isRydeAvailable = true;

    // Reset inventory
    inventory = {
      'Blunts/Pre Rolls': 0,
      'Oxy': 0,
      'Shrooms': 0,
      'Powda': 0,
      'Acid': 0,
    };

    // Reassign random products to each location
    final random = Random();
    for (var location in locations) {
      locationProducts[location] = [];
      for (var i = 0; i < random.nextInt(3) + 2; i++) {
        locationProducts[location]!.add(allProducts[random.nextInt(allProducts.length)]);
      }
    }
  });
}

  void _buyProduct(Product product) {
    if (cash >= product.basePrice.toInt()) {
      setState(() {
        if (bookbag > 0) {  // Check if there's space in the bookbag
          cash -= product.basePrice.toInt();
          inventory.update(product.name, (value) => value + 1, ifAbsent: () => 1);
          bookbag--; // Decrease bookbag space by 1
        } else {
          // Handle case where bookbag is full
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(title: const Text('Bookbag Full'), content: const Text('Your bookbag is full. You need a bigger bookbag to carry more items.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]);
            },
          );
        }
      });
    } else {
      // Handle case where player doesn't have enough cash or bookbag space
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Insufficient Funds or Bookbag Space'),
            content: const Text('You do not have enough cash or bookbag space to purchase this item.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          );
        },
      );
    }
  }

  void _showPurchaseOptions() {
    if (selectedLocation?.name == 'Little Five Points') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Purchase Options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPurchaseOption('Bookbag (250 capacity)', 400, 250),
                _buildPurchaseOption('Bookbag (600 capacity)', 1000, 600),
                _buildPurchaseOption('Bookbag (1000 capacity)', 3000, 1000),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildPurchaseOption(String name, int cost, int newCapacity) {
    return ListTile(
      title: Text('$name - \$$cost'),
      onTap: () {
        if (cash >= cost) {
          setState(() {
            cash -= cost;
            bookbag = newCapacity;
          });
          Navigator.of(context).pop(); // Close the dialog
        } else {
          // Handle insufficient funds
          // (e.g., show a message to the user)
        }
      },
    );
  }
}
