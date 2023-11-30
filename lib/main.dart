import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'meal_plan_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The main application widget.
    return MaterialApp(
      title: 'Calories Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Instance of the database helper class.
  final dbHelper = DatabaseHelper();

  // Variables to store target calories, selected date, total consumed calories, and user input.
  int targetCalories = 0;
  DateTime selectedDate = DateTime.now();
  int totalConsumedCalories = 0;
  TextEditingController foodController = TextEditingController();
  int calories = 0;
  bool usePredefinedList = true; // Added boolean variable

  @override
  void initState() {
    super.initState();
    _loadTotalConsumedCalories();
  }

  // Function to show date picker dialog.
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _loadTotalConsumedCalories();
      });
    }
  }

  // Function to load total consumed calories for the selected date.
  void _loadTotalConsumedCalories() async {
    final consumedFoods =
        await dbHelper.getMealPlanForDate(_formatDate(selectedDate));
    setState(() {
      totalConsumedCalories =
          consumedFoods.fold(0, (sum, food) => sum + food.calories);
    });
  }

  // Function to format a date to a string.
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Function to show food selection dialog.
  Future<void> _showFoodSelectionDialog() async {
    List<Map<String, dynamic>> foods = await dbHelper.getFoods();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Food'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Use Predefined List'),
                Column(
                  children: foods.map((food) {
                    return ListTile(
                      title: Text(food['name']),
                      onTap: () {
                        setState(() {
                          foodController.text = food['name'];
                          calories = food['calories'];
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to add food to the database.
  void _addFood() async {
    if (selectedDate == null) {
      // Show a snack bar if the date is not selected.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date.'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Show a snack bar if total consumed calories exceed the target.
    if (totalConsumedCalories + calories > targetCalories) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exceeding Target Calories!'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Show food selection dialog before adding the food.
    await _showFoodSelectionDialog();

    // Insert the selected food into the database.
    await dbHelper.insertFood(
      foodController.text,
      calories,
      _formatDate(selectedDate),
    );

    // Reload the total consumed calories and reset input fields.
    _loadTotalConsumedCalories();

    setState(() {
      foodController.text = '';
      calories = 0;
    });
  }

  // Function to delete food.
  void _deleteFood(int calories) {
    setState(() {
      totalConsumedCalories -= calories;
    });
  }

  // Function to navigate to the meal plan screen.
  void _viewMealPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPlanScreen(
          selectedDate: selectedDate,
          onDeleteFood: _deleteFood, // Pass the callback function
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the main UI scaffold.
    return Scaffold(
      appBar: AppBar(
        title: Text('Calories Calculator'),
      ),
      body: Column(
        children: [
          // Input for target calories.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Target Calories:'),
                SizedBox(width: 10),
                Container(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        targetCalories = int.parse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Display selected date and date picker button.
          Row(
            children: [
              Text('Selected Date: ${_formatDate(selectedDate)}'),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          // Button to add food.
          Row(
            children: [
              ElevatedButton(
                onPressed: _addFood,
                child: Text('Add Food'),
              ),
            ],
          ),
          // Display total consumed calories.
          Text(
            'Total Consumed Calories: $totalConsumedCalories',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Display warning if total consumed calories exceed target calories.
          if (totalConsumedCalories > targetCalories)
            Text(
              'Warning: Exceeding Target Calories!',
              style: TextStyle(color: Colors.red),
            ),
          // Button to view meal plan.
          ElevatedButton(
            onPressed: _viewMealPlan,
            child: Text('View Meal Plan'),
          ),
        ],
      ),
    );
  }
}
