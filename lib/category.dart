import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mealapp/detail.dart';
import 'package:mealapp/model/meal.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  List<Meals> meals = [];
  bool isLoading = true;
  bool isSearching = false;
  late TabController tabController;

  List<String> categories = [
    'Beef',
    'Chicken',
    'Dessert',
    'Lamb',
    'Miscellaneous',
    'Pasta',
    'Pork',
    'Seafood',
    'Side',
    'Starter',
    'Vegan',
    'Vegetarian', // typo "Vegatarian" diperbaiki jadi "Vegetarian"
    'Breakfast',
    'Goat',
  ];

  int selectedIndex = 0;
  final TextEditingController textEditingController = TextEditingController();
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: categories.length, vsync: this);

    // Hanya panggil fetchData jika tab sudah selesai berpindah
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        selectedIndex = tabController.index;
        setState(() {
          isLoading = true;
        });
        fetchData(categories[selectedIndex]);
      }
    });

    // Fetch pertama kali
    fetchData(categories[selectedIndex]);
  }

  Future<void> fetchData(String category) async {
    final uri = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      final List jsonMeals = jsonMap['meals'];
      setState(() {
        meals = jsonMeals.map((e) => Meals.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        meals = [];
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    textEditingController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.startOffset,
          tabs: categories.map((e) => Tab(text: e)).toList(),
        ),
        title:
            isSearching
                ? TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Category',
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    if (debounce?.isActive ?? false) debounce?.cancel();
                    debounce = Timer(const Duration(milliseconds: 500), () {
                      setState(() {
                        isLoading = true;
                      });
                      fetchData(categories[selectedIndex]);
                    });
                  },
                )
                : const Text('Category Page'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  textEditingController.clear();
                  fetchData(categories[selectedIndex]);
                }
              });
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetailPage(
                                  strMeal: '${meals[index].strMeal}',
                                  strInstructions: 'No Description',
                                  strMealThumb: '${meals[index].strMealThumb}',
                                ),
                          ),
                        ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        meals[index].strMealThumb ?? '',
                      ),
                    ),
                    title: Text(meals[index].strMeal ?? ''),
                  );
                },
              ),
    );
  }
}
