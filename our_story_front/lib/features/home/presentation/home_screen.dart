import 'package:flutter/material.dart';
import 'package:our_story_front/core/theme/app_theme.dart';
import 'package:our_story_front/features/home/presentation/widgets/home_header.dart';
import 'package:our_story_front/features/home/presentation/widgets/home_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: AppTheme.gradientBackground,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                HomeHeader(),
                HomeBody(),
              ],
            )
          ),
        ),
      ),
    );
  }
}
