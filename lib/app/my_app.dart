import 'package:aes/core/theme/theme.dart';
import 'package:aes/data/get/get_storage_helper.dart';
import 'package:aes/routes/home/home.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final localStorage = GetLocalStorage();
  @override
  void initState() {
    if(localStorage.getUUID() == null){
      localStorage.saveUUID();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'AES',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
