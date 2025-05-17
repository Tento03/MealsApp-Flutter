import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mealapp/detail.dart';
import 'package:mealapp/model/meal.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Meals> meals = [];
  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController textEditingController = TextEditingController();
  Timer? debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var uri = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/search.php?s=${textEditingController.text}',
    );
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      setState(() {
        final List jsonFinal = jsonMap['meals'];
        meals = jsonFinal.map((e) => Meals.fromJson(e)).toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            isSearching
                ? TextField(
                  controller: textEditingController,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Search...',
                  ),
                  onChanged: (value) {
                    if (debounce?.isActive ?? false) debounce!.cancel();
                    debounce = Timer(const Duration(milliseconds: 500), () {
                      fetchData();
                    });
                  },
                )
                : Text('Search Page'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  textEditingController.clear();
                }
              });
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                                        strInstructions:
                                            '${meals[index].strInstructions}',
                                        strMealThumb:
                                            '${meals[index].strMealThumb}',
                                      ),
                                ),
                              ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              '${meals[index].strMealThumb}',
                            ),
                          ),
                          title: Text('${meals[index].strMeal}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  @override
  void dispose() {
    debounce?.cancel();
    textEditingController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
}
