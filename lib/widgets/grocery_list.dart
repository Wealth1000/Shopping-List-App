import 'package:flutter/material.dart';
import 'package:learnflutter/models/grocery_item.dart';
import 'package:learnflutter/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (context) => const NewItem()),
    );
    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }
  void _deleteItem(GroceryItem value){
    setState(() {
      _groceryItems.remove(value);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item Deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(_groceryItems[index].id),
            onDismissed: (direction) {
              _deleteItem(_groceryItems[index]);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.delete, color: Colors.white,),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white,),
            ),
            child: ListTile(
              leading: Container(
                width: 20,
                height: 20,
                color: _groceryItems[index].category.color,
              ),
              title: Text(_groceryItems[index].name),
              trailing: Text("${_groceryItems[index].quantity}"),
            ),
          );
        },
      );
      if(_groceryItems.isEmpty){
        content = const Center(
            child: Text("You have no items yet. Add some!", style: TextStyle(
              fontSize: 20,
            ),),
        );
      }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
