import 'package:api_crud_project/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main(){
    runApp(ApiCrudApp());
}

class ApiCrudApp extends StatelessWidget {
  const ApiCrudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApiCrudApp',
      theme: ThemeData(
        //useMaterial3: false, (i have a qus on this topic)
        colorSchemeSeed: Colors.purple,
      ),
      home: HomeScreen(),
    );
  }
}
