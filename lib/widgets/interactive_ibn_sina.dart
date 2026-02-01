import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/rewards_controller.dart';
import 'dart:math';

class InteractiveIbnSina extends StatefulWidget {
  final Offset mousePosition;

  const InteractiveIbnSina({
    super.key,
    required this.mousePosition,
  });

  @override
  State<InteractiveIbnSina> createState() => _InteractiveIbnSinaState();
}

class _InteractiveIbnSinaState extends State<InteractiveIbnSina> with SingleTickerProviderStateMixin {
  // Eye positions for the new half-body image (approximate percentages)
  // Image is centered, let's assume standard width
  final Offset leftEyeBase = const Offset(0.44, 0.235); 
  final Offset rightEyeBase = const Offset(0.56, 0.235);
  
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  Offset _calculatePupilOffset(Offset eyeBasePct, Size imageSize) {
    if (imageSize.width == 0) return Offset.zero;

    // Center of the screen (assuming widget is centered)
    final screenCenter = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2
    );

    // Vector from center of screen to mouse
    final dx = widget.mousePosition.dx - screenCenter.dx;
    final dy = widget.mousePosition.dy - screenCenter.dy;

    final angle = atan2(dy, dx);
    // Dampen movement based on distance from center
    final distance = min(sqrt(dx*dx + dy*dy) / 30, 4.0); 

    return Offset(cos(angle) * distance, sin(angle) * distance);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate parallax effect
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Increased parallax intensity slightly
    final parallaxX = (widget.mousePosition.dx - screenWidth / 2) * -0.02;
    final parallaxY = (widget.mousePosition.dy - screenHeight / 2) * -0.02;

    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Transform.translate(
            offset: Offset(parallaxX, parallaxY), 
            child: SizedBox(
               width: double.infinity,
               height: double.infinity, 
                child: Consumer<RewardsController>(
                  builder: (context, rewards, child) {
                    return Image.asset(
                      rewards.selectedSkin.assetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    );
                  },
                ),
            ),
          ),
        );
      },
    );
  }
}
