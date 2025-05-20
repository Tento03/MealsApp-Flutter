import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final String strMeal;
  final String strInstructions;
  final String strMealThumb;

  const DetailPage({
    super.key,
    required this.strMeal,
    required this.strInstructions,
    required this.strMealThumb,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.strMeal)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.strMealThumb),
                      radius: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.strMeal,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.strInstructions,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
