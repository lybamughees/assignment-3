// Represents a food item with its properties.
class Food {
  // Unique identifier for the food item.
  int id;

  // Name of the food.
  String name;

  // Caloric content of the food.
  int calories;

  // Date when the food item was consumed.
  String date;

  // Constructor for creating a Food instance.
  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
  });

  // Converts the Food instance to a Map for database operations.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'calories': calories, 'date': date};
  }

  // Factory method to create a Food instance from a Map.
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      date: map['date'],
    );
  }
}
