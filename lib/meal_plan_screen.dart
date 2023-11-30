import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'food.dart';

class MealPlanScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Function(int) onDeleteFood;

  MealPlanScreen({required this.selectedDate, required this.onDeleteFood});

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final dbHelper = DatabaseHelper();
  List<Food> mealPlan = [];
  TextEditingController foodCaloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  // Function to load the meal plan for the selected date.
  void _loadMealPlan() async {
    final loadedMealPlan =
        await dbHelper.getMealPlanForDate(_formatDate(widget.selectedDate));
    setState(() {
      mealPlan = loadedMealPlan;
    });
  }

  // Function to format a date to a string.
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Function to update a food item.
  void _updateFood(int id, String currentName, int currentCalories) {
    Food selectedFoodItem = mealPlan.firstWhere((food) => food.id == id);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Food'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: currentName,
                onChanged: (value) {
                  selectedFoodItem.name = value;
                },
                decoration: InputDecoration(labelText: 'New Food Name'),
              ),
              SizedBox(height: 10),
              Text('Current Calories: ${selectedFoodItem.calories}'),
              SizedBox(height: 10),
              TextFormField(
                controller: foodCaloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'New Calories'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (foodCaloriesController.text.isNotEmpty) {
                  // Update food item in the database.
                  selectedFoodItem.calories =
                      int.parse(foodCaloriesController.text);
                  await dbHelper.updateFood(
                    selectedFoodItem.id,
                    selectedFoodItem.name,
                    selectedFoodItem.calories,
                    _formatDate(widget.selectedDate),
                  );

                  // Reload the meal plan.
                  _loadMealPlan();

                  // Close the dialog.
                  Navigator.pop(context);
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a food item.
  void _deleteFood(int id, int calories) async {
    await dbHelper.deleteFood(id);

    // Reload the meal plan.
    _loadMealPlan();

    // Call the callback function to update the total consumed calories in the main screen.
    widget.onDeleteFood(calories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plan for ${_formatDate(widget.selectedDate)}'),
      ),
      body: ListView.builder(
        itemCount: mealPlan.length,
        itemBuilder: (context, index) {
          final food = mealPlan[index];
          return ListTile(
            title: Text(food.name),
            subtitle: Text('${food.calories} calories'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Button to edit a food item.
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () =>
                      _updateFood(food.id, food.name, food.calories),
                ),
                // Button to delete a food item.
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteFood(food.id, food.calories),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
