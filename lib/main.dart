import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mealapp/category.dart';
import 'package:mealapp/favorite.dart';
import 'package:mealapp/model/favorite.dart';
import 'package:mealapp/search.dart';
import 'package:mealapp/model/category.dart';

void main(List<String> args) async {
  await Hive.initFlutter;
  Hive.registerAdapter(FavoriteAdapter());
  await Hive.openBox<Favorite>('favBox');
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
  Box<Favorite> favBox = Hive.box<Favorite>('favBox');
  List<String> favMeal = [];

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

  void addFavorite(String idCategory, Categories categories) {
    setState(() {
      if (favMeal.contains(idCategory)) {
        favMeal.remove(idCategory);
        final indextoDelete = favBox.values.toList().indexWhere(
          (fav) => fav.idCategory == idCategory,
        );
        if (indextoDelete != 1) {
          favBox.deleteAt(indextoDelete);
        }
      } else {
        favMeal.add(idCategory);
        favBox.add(
          Favorite(
            idCategory: categories.idCategory ?? 'null',
            strCategory: categories.strCategory ?? 'null',
            strCategoryThumb: categories.strCategoryThumb ?? 'null',
            strCategoryDescription: categories.strCategoryDescription ?? 'null',
          ),
        );
      }
    });
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
                  final categoriess = categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        '${categoriess.strCategoryThumb}',
                      ),
                    ),
                    title: Text('${categoriess.strCategory}'),
                    subtitle: Text("${categoriess.strCategoryDescription}"),
                    trailing: IconButton(
                      onPressed:
                          () => addFavorite(
                            categoriess.idCategory ?? 'null',
                            categories[index],
                          ),
                      icon: Icon(
                        favMeal.contains(categoriess.idCategory)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color:
                          favMeal.contains(categoriess.idCategory)
                              ? Colors.red
                              : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }
}
