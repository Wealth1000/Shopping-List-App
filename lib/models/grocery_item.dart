import 'category.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.quantity,
    required this.name,
    required this.category,
  });
  final String id;
  final int quantity;
  final String name;
  final Category category;
}
