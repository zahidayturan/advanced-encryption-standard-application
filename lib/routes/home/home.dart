import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/home/components/home_files.dart';
import 'package:aes/routes/home/components/home_key_and_encryption.dart';
import 'package:aes/routes/home/components/home_top_bar.dart';
import 'package:aes/ui/components/shimmer_box.dart';
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
        body: const SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 18,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: HomeTopBar(),
                ),
                SizedBox(height: 28,),
                HomeKeyAndEncryption(),
                SizedBox(height: 28,),
                HomeFiles()
              ],
            )
          ),
        ),
      ),
    );
  }
}