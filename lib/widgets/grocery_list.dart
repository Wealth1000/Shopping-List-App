import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:learnflutter/data/categories.dart';
import 'package:learnflutter/models/grocery_item.dart';
import 'package:learnflutter/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});
  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    final url = Uri.https(
      'shopping-list-app-8adb6-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    final response = await http.get(url);
    
    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later';
      });
    }
    if(response.body == 'null'){
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category =
          categories.entries
              .firstWhere(
                (element) => element.value.title == item.value['category'],
              )
              .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          quantity: item.value['quantity'],
          name: item.value['name'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (context) => const NewItem()),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    //loadItems();
  }

  void _deleteItem(GroceryItem value) async {
    final index = _groceryItems.indexOf(value);
    final url = Uri.https(
      'shopping-list-app-8adb6-default-rtdb.firebaseio.com',
      'shopping-list/${value.id}.json',
    );
    setState(() {
      _groceryItems.remove(value);
    });
    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(const SnackBar(content: Text("Item Deleted")));
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "We couldn't delete your item. Please try again in a few seconds",
          ),
        ),
      );
      setState(() {
        _groceryItems.insert(index, value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        "You have no items yet. Add some!",
        style: TextStyle(fontSize: 20),
      ),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryItems[index].id), // Changed from Key to ValueKey
            onDismissed: (direction) {
              _deleteItem(_groceryItems[index]);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
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
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
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
