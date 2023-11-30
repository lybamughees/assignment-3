import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'food.dart';

// DatabaseHelper class to handle interactions with the SQLite database.
class DatabaseHelper {
  // Singleton instance of the database.
  static Database? _database;

  // Getter for the database instance.
  Future<Database> get database async {
    // If the database instance already exists, return it.
    if (_database != null) return _database!;

    // If the database instance doesn't exist, initialize and return it.
    _database = await initDatabase();
    return _database!;
  }

  // Function to initialize the database.
  Future<Database> initDatabase() async {
    // Define the path for the database file.
    String path = join(await getDatabasesPath(), 'food_database.db');

    // Open the database, creating it if it doesn't exist.
    Database db = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        // Create the 'foods' table if it doesn't exist.
        await db.execute(
          'CREATE TABLE foods(id INTEGER PRIMARY KEY, name TEXT, calories INTEGER, date TEXT)',
        );
        // Insert initial food items into the 'foods' table.
        await _insertInitialFoodItems(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Handle database upgrades if needed.
      },
    );

    return db;
  }

  // Function to insert initial food items into the database.
  Future<void> _insertInitialFoodItems(Database db) async {
    final foodItems = [
      {'name': 'Apple', 'calories': 95},
      {'name': 'Banana', 'calories': 105},
      {'name': 'Orange', 'calories': 62},
      {'name': 'Grapes', 'calories': 69},
      {'name': 'Carrot', 'calories': 41},
      {'name': 'Broccoli', 'calories': 55},
      {'name': 'Chicken Breast (cooked)', 'calories': 165},
      {'name': 'Salmon (cooked)', 'calories': 206},
      {'name': 'Rice (cooked)', 'calories': 205},
      {'name': 'Quinoa (cooked)', 'calories': 222},
      {'name': 'Pasta (cooked)', 'calories': 200},
      {'name': 'Egg', 'calories': 68},
      {'name': 'Greek Yogurt', 'calories': 59},
      {'name': 'Almonds', 'calories': 7},
      {'name': 'Avocado', 'calories': 322},
      {'name': 'Spinach (raw)', 'calories': 7},
      {'name': 'Sweet Potato (baked)', 'calories': 180},
      {'name': 'Cheese (cheddar)', 'calories': 113},
      {'name': 'Milk (whole)', 'calories': 150},
      {'name': 'Dark Chocolate', 'calories': 170},
      {'name': 'Oatmeal', 'calories': 150},
      {'name': 'Peanut Butter', 'calories': 90},
      {'name': 'Ground Beef (cooked)', 'calories': 250},
      {'name': 'Tomato', 'calories': 22},
      {'name': 'Lettuce', 'calories': 5},
      {'name': 'Cucumber', 'calories': 16},
      {'name': 'Bell Pepper', 'calories': 25},
      {'name': 'Olive Oil', 'calories': 119},
      {'name': 'Whole Wheat Bread', 'calories': 69},
    ];

    for (final foodItem in foodItems) {
      // Insert each food item into the 'foods' table.
      await db.insert(
        'foods',
        foodItem,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Function to insert a new food item into the 'foods' table.
  Future<void> insertFood(String name, int calories, String date) async {
    Database db = await database;
    await db
        .insert('foods', {'name': name, 'calories': calories, 'date': date});
  }

  // Function to retrieve all food items from the 'foods' table.
  Future<List<Map<String, dynamic>>> getFoods() async {
    Database db = await database;
    return await db.query('foods');
  }

  // Function to retrieve the meal plan for a specific date.
  Future<List<Food>> getMealPlanForDate(String date) async {
    Database db = await database;
    List<Map<String, dynamic>> result =
        await db.query('foods', where: 'date = ?', whereArgs: [date]);
    return result.map((map) => Food.fromMap(map)).toList();
  }

  // Function to update a food item in the 'foods' table.
  Future<void> updateFood(
      int id, String name, int calories, String date) async {
    Database db = await database;
    await db.update(
      'foods',
      {'name': name, 'calories': calories, 'date': date},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Function to delete a food item from the 'foods' table.
  Future<void> deleteFood(int id) async {
    Database db = await database;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }
}
