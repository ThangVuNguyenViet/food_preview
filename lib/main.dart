import 'package:flutter/material.dart';
import 'package:food_preview/food_preview_screen.dart';
import 'package:food_preview/food_preview_screen_2.dart';

void main() {
  runApp(const MyApp2());
}

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Preview Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(RawDialogRoute(
                  pageBuilder: (context, _, __) => const FoodPreviewScreen(),
                ));
              },
              child: const Text('Open Food Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(RawDialogRoute(
                  pageBuilder: (context, _, __) => const FoodPreviewScreen2(),
                ));
              },
              child: const Text('Open Completed Food Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
