import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_preview/food.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FoodPreviewScreen extends StatefulWidget {
  const FoodPreviewScreen({super.key});

  @override
  State<FoodPreviewScreen> createState() => _FoodPreviewScreenState();
}

class _FoodPreviewScreenState extends State<FoodPreviewScreen> {
  late final _scrollController = ScrollController();

  // Inspected values from figma
  final imageSize = 200.0;
  final shrinkedImageSize = 90.0;
  // From phone top (status bar included) to the top of the image
  final imageTopPadding = 80.0;
  late final arcPeakToBottom = imageSize / 4;

  final animationDuration = 500.ms;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Refresh the Widget after the scroll controller is attached
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const food = Food.pho;

    final topPadding = MediaQuery.paddingOf(context).top;

    final expandedHeight = imageTopPadding + imageSize - topPadding;
    final collapsedHeight = shrinkedImageSize;

    final scrollPosition =
        _scrollController.hasClients ? _scrollController.position : null;
    final curveHeight = scrollPosition == null
        ? null
        : scrollPosition.extentTotal - imageTopPadding - imageSize / 2;
    final curveBase =
        curveHeight == null ? null : curveHeight - arcPeakToBottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: Container(
        height: 100,
        color: Colors.black,
        child: Center(
          child: Text(
            'ADD TO CART',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverLayoutBuilder(builder: (context, constraints) {
            final double scrollFilledPercentage = min(
              constraints.scrollOffset / (expandedHeight - collapsedHeight),
              1,
            );
            const transitionPoint = .8;
            final double opacity = switch (scrollFilledPercentage) {
              < transitionPoint => 0,
              _ => Curves.easeInOutSine.transform(
                  // 0 - > .2
                  (scrollFilledPercentage - transitionPoint) /
                      // divided by .2
                      (1 - transitionPoint),
                ),
            };

            return SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white.withOpacity(opacity),
              surfaceTintColor: Colors.white,
              flexibleSpace: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(top: topPadding),
                child: Image.asset(
                  food.image,
                  width: imageSize,
                  height: imageSize,
                )
                    .animate()
                    .moveY(begin: curveHeight, duration: animationDuration),
              ),
              leading: BackButton(
                color:
                    scrollFilledPercentage == 1 ? Colors.black : Colors.white,
              ),
              expandedHeight: expandedHeight,
              collapsedHeight: collapsedHeight,
            );
          }),
          SliverStack(
            children: [
              if (curveHeight != null && curveBase != null)
                SliverPositioned.fill(
                  child: CurvedWidget(
                    height: curveHeight,
                    base: curveBase,
                    color: Colors.white,
                  )
                      .animate()
                      .moveY(begin: curveHeight, duration: animationDuration),
                ),
              MultiSliver(
                children: [
                  SliverLayoutBuilder(builder: (context, constraints) {
                    final isOverLapping = constraints.overlap > 0;
                    return PinnedHeaderSliver(
                      child: ColoredBox(
                        color:
                            isOverLapping ? Colors.white : Colors.transparent,
                        child: _buildTitle(food, context)
                            .animate()
                            .fadeIn(delay: animationDuration),
                      ),
                    );
                  }),
                  SliverGrid.count(
                    crossAxisCount: 3,
                    children: [
                      for (final ingredient in food.ingredients)
                        Column(
                          children: [
                            Image.asset(ingredient.image, height: 80),
                            const SizedBox(height: 8),
                            Text(ingredient.name),
                          ],
                        ).animate().fadeIn(delay: animationDuration),
                    ],
                  )
                ],
              ),
              SliverLayoutBuilder(builder: (context, constraints) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: constraints.viewportMainAxisExtent -
                        topPadding -
                        collapsedHeight,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(Food food, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(food.name, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
          Text(
            food.description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text('What\'s included:',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class CurvedWidget extends StatelessWidget {
  const CurvedWidget({
    super.key,
    required this.height,
    required this.base,
    required this.color,
  });

  final double height;
  final double base;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: CurvedPainter(
          height: height,
          base: base,
          color: color,
        ),
      ),
    );
  }
}

class CurvedPainter extends CustomPainter {
  final double height;
  final double base;
  final Color color;

  CurvedPainter({
    super.repaint,
    required this.height,
    required this.base,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // With the ellipse equation: (x/a)^2 + (y/b)^2 = 1
    // We have
    final b = height;
    final x = size.width / 2;
    final y = base;

    final a = sqrt(x * x / (1 - y * y / (b * b)));

    final path = Path();
    path.addArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height),
        height: b * 2,
        width: a * 2,
      ),
      -pi,
      pi,
    );

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
