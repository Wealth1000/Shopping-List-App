import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:learnflutter/data/categories.dart';
import 'package:learnflutter/models/category.dart';
import 'package:learnflutter/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate() == true) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
        'shopping-list-app-8adb6-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      final response = await http.post(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode({
          'quantity': _enteredQuantity,
          'name': _enteredName,
          'category': _selectedCategory.title,
        }),
      );
      final resData = json.decode(response.body);
      if (!mounted) return;
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          quantity: _enteredQuantity,
          name: _enteredName,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add a new item")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text("Name")),
                validator: (value) {
                  final trimmedValue = value?.trim() ?? '';
                  if (trimmedValue.isEmpty ||
                      trimmedValue.length <= 1 ||
                      trimmedValue.length > 50) {
                    return "Must be between 1 and 50 characters";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ), //instead of TextField()
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be a valid, positive number";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSending
                            ? null
                            : () {
                              _formKey.currentState!.reset();
                            },
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child:
                        _isSending
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                            : const Text("Add Item"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
