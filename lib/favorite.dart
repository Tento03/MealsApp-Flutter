import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mealapp/model/favorite.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Box<Favorite> favMovie = Hive.box<Favorite>('favBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite')),
      body: ValueListenableBuilder(
        valueListenable: favMovie.listenable(),
        builder: (context, value, child) {
          if (value.values.isEmpty) {
            return Center(child: Text('Empty'));
          }

          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              var movie = value.getAt(index);
              return ListTile(
                title: Text(movie!.strCategory),
                subtitle: Text(movie.strCategoryDescription),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage('${movie.strCategoryThumb}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
