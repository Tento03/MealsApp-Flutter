import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mealapp/category.dart';
import 'package:mealapp/favorite.dart';
import 'package:mealapp/search.dart';
import 'package:mealapp/model/category.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DrawerPage());
  }
}

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Recipe')),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(child: Text('Meal')),
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Search'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Category'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DefaultTabController(
                            length: 14,
                            child: CategoryPage(),
                          ),
                    ),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favorite'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritePage()),
                  ),
            ),
          ],
        ),
      ),
      body: CategoriesPage(),
    );
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Categories> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var uri = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/categories.php',
    );
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      setState(() {
        final List jsonFinal = jsonMap['categories'];
        categories = jsonFinal.map((e) => Categories.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        categories = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        '${categories[index].strCategoryThumb}',
                      ),
                    ),
                    title: Text('${categories[index].strCategory}'),
                    subtitle: Text(
                      "${categories[index].strCategoryDescription}",
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }
}
