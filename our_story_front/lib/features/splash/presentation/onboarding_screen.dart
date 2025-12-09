import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/features/splash/presentation/intro_screens/intro_page_1.dart';
import 'package:our_story_front/shared/widgets/custom_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  final PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(
                title: "Our Story",
                subTitle: "Bienvenido a",
                content: "Tu diario compartido \n de amor, risas y recuerdos",
                image: "assets/images/floating_island.png",
              ),
              IntroPage1(
                title: "",
                subTitle: "Captura tus momentos especiales",
                content: "Agrega fotos, notas e hitos \n a nuestra linea de tiempo compartida",
                image: "assets/images/logo_read.png",
              ),
              IntroPage1(
                title: "",
                subTitle: "Conéctate y comparte tu viaje",
                content: "Acércate más, un recuerdo compartido a la vez",
                image: "assets/images/logo_old.png",
              ),
            ],
          ),
      
          // dot indicators
          Positioned(
            left: 52,
            right: 52,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // dot indicator
                SmoothPageIndicator(
                  controller: _controller, 
                  count: 3,
                ),

                const SizedBox(height: 24),

                // next or done
                onLastPage ?
                  CustomButton(
                    text: "¡Comencemos nuestra historia!", 
                    onPressed: ()  {
                      context.go('/login');
                    },
                    isGradient: true,
                  )
                : 
                  CustomButton(
                      text: "Siguiente", 
                      onPressed: ()  {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 500), 
                          curve: Curves.easeIn
                        );
                      },
                      isGradient: true,
                    ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    "skip",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.accentSecondaryLight
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
