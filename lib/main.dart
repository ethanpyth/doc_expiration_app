import 'package:flutter/material.dart';
import './ui/docslist.dart';

void main() => runApp(DocExpiryApp());

class DocExpiryApp extends StatelessWidget {
  const DocExpiryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocExpire',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: DocList(),
    );
  }
}
