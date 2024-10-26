import 'package:aes/core/constants/colors.dart';
import 'package:aes/routes/home/components/home_files.dart';
import 'package:aes/routes/home/components/home_key_and_encryption.dart';
import 'package:aes/routes/home/components/home_top_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  AppColors colors = AppColors();


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: null,
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 18,),
                  HomeTopBar(),
                  SizedBox(height: 28,),
                  HomeKeyAndEncryption(),
                  SizedBox(height: 28,),
                  HomeFiles()
                ],
              )
            ),
          ),
        ),
      ),
    );
  }
}