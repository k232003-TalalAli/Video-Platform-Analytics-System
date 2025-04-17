import 'package:flutter/material.dart';
import 'overview_page.dart'; 

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, //hide the debug banner (it was annoying)
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
                   (
                     backgroundColor: const Color.fromARGB(255, 216, 216, 216),
                     body: over_view_widget()
                    );
  }
}
