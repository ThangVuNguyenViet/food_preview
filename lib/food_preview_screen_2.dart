import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_preview/food.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FoodPreviewScreen2 extends StatelessWidget {
  const FoodPreviewScreen2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const pho = Food.pho;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SlidablePage2(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(pho.name, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              Text(
                pho.description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text('What\'s included:',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
            ],
          ),
        ),
        gridItems: [
          for (final ingredient in pho.ingredients)
            Column(
              children: [
                Image.asset(ingredient.image, height: 80),
                const SizedBox(height: 8),
                Text(ingredient.name),
              ],
            ),
        ],
        imageUrl: pho.image,
        mainAxisSpacing: 0,
      ),
    );
  }
}

class SlidablePage2 extends StatefulWidget {
  const SlidablePage2({
    super.key,
    required this.imageUrl,
    required this.content,
    required this.gridItems,
    this.mainAxisSpacing = 0,
  });

  final String imageUrl;
  final Widget content;
  final List<Widget> gridItems;
  final double mainAxisSpacing;

  @override
  State<SlidablePage2> createState() => _SlidablePage2State();
}

class _SlidablePage2State extends State<SlidablePage2> {
  final animationDuration = const Duration(milliseconds: 500);
  late final _scrollController = ScrollController();

  // Inspected values from figma
  final imageSize = 200.0;
  final shrinkedImageSize = 90.0;
  // From phone top (status bar included) to the top of the image
  final imageTopPadding = 80.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Refresh the state after _scrollController has been attached
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scrollPosition =
        _scrollController.hasClients ? _scrollController.position : null;

    // Arc peak should be at the center of the image
    // final arcHeight = (scrollPosition?.extentTotal ?? 0) -
    final arcHeight =
        (scrollPosition?.extentTotal ?? 0) - imageTopPadding - imageSize / 2;
    // base should be at the 3/4 of the image
    final base = arcHeight - imageSize / 4;

    final expandedHeight =
        imageSize + imageTopPadding - MediaQuery.paddingOf(context).top;
    final collapsedHeight = shrinkedImageSize;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      controller: _scrollController,
      slivers: [
        MultiSliver(
          pushPinnedChildren: true,
          children: [
            SliverLayoutBuilder(builder: (context, constraints) {
              final double scrollFilledPercentage = min(
                  constraints.scrollOffset / (expandedHeight - collapsedHeight),
                  1);

              const transformPoint = .8;
              final opacity = switch (scrollFilledPercentage) {
                < transformPoint => 0.0,
                _ => Curves.easeInOutSine.transform(
                    (scrollFilledPercentage - transformPoint) /
                        (1 - transformPoint),
                  ),
              };

              return SliverAppBar(
                backgroundColor: Colors.white.withOpacity(opacity),
                surfaceTintColor: Colors.white,

                // Matched heiht with [MobileAppBar]
                toolbarHeight: 60,
                elevation: 0,
                bottom: const PreferredSize(
                    preferredSize: Size.zero, child: SizedBox()),
                leading: CloseButton(
                  onPressed: () => Navigator.of(context).pop(),
                  color:
                      scrollFilledPercentage == 1 ? Colors.black : Colors.white,
                ),

                shape: const RoundedRectangleBorder(),
                pinned: true,
                flexibleSpace: Container(
                  padding:
                      EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                  alignment: Alignment.bottomCenter,
                  child:
                      // Negative arcHeight means the view isn't ready yet
                      arcHeight.isNegative
                          ? null
                          : Image.asset(
                              widget.imageUrl,
                              fit: BoxFit.contain,
                              width: imageSize,
                            )
                              .animate(
                                onInit: (controller) => controller.forward(),
                              )
                              .moveY(
                                begin: arcHeight,
                                duration: animationDuration,
                                curve: Curves.easeIn,
                              ),
                ),
                expandedHeight: expandedHeight,
                collapsedHeight: collapsedHeight,
              );
            }),
            SliverStack(
              insetOnOverlap: true,
              children: [
                SliverPositioned.fill(
                  child: arcHeight.isNegative
                      ? const SizedBox()
                      : AnimatedCurveWidget2(
                          arcHeight: arcHeight,
                          base: base,
                          animationDuration: Duration.zero,
                        )
                          .animate(
                            onInit: (controller) => controller.forward(),
                          )
                          .moveY(
                            begin: arcHeight,
                            duration: animationDuration,
                            curve: Curves.easeIn,
                          ),
                ),
                MultiSliver(
                  children: [
                    SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final hasOverLap = constraints.overlap > 0;

                        return SliverPinnedHeader(
                          child: ColoredBox(
                            color:
                                hasOverLap ? Colors.white : Colors.transparent,
                            child: widget.content
                                .animate(delay: animationDuration)
                                .fadeIn(),
                          ),
                        );
                      },
                    ),
                    _buildSliverGrid(),
                  ],
                ),
                // Add this box as a minimum height in case the
                // content is not long enough
                SliverLayoutBuilder(builder: (context, constraints) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: constraints.viewportMainAxisExtent -
                          (shrinkedImageSize +
                              MediaQuery.paddingOf(context).top),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliverGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid.count(
        crossAxisCount: 3,
        childAspectRatio: 100 / 135,
        crossAxisSpacing: 14,
        mainAxisSpacing: widget.mainAxisSpacing,
        children: widget.gridItems.animate(delay: animationDuration).fadeIn(),
      ),
    );
  }
}

class AnimatedCurveWidget2 extends StatefulWidget {
  const AnimatedCurveWidget2({
    super.key,
    required this.base,
    required this.arcHeight,
    this.color = Colors.white,
    this.animationDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeIn,
    this.initialBase = 0,
    this.initialArcHeight = 0,
  });

  final double base;
  final double arcHeight;
  final Color color;
  final Duration animationDuration;
  final Curve curve;
  final double initialBase;
  final double initialArcHeight;

  @override
  State<AnimatedCurveWidget2> createState() => _AnimatedCurveWidget2State();
}

class _AnimatedCurveWidget2State extends State<AnimatedCurveWidget2>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _arcHeightAnimation;
  late Animation<double> _baseAnimation;

  late double _currentArcHeight = widget.initialArcHeight;
  late double _currentBase = widget.initialBase;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _currentArcHeight = widget.arcHeight;
          _currentBase = widget.base;
        }
      });

    playAnimation();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimatedCurveWidget2 oldWidget) {
    if (widget.base != oldWidget.base ||
        widget.arcHeight != oldWidget.arcHeight) {
      playAnimation();
    }
    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void playAnimation() {
    if (!mounted) {
      return;
    }

    _baseAnimation = Tween(
      begin: _currentBase,
      end: widget.base,
    ).chain(CurveTween(curve: widget.curve)).animate(_animationController);

    _arcHeightAnimation = Tween(
      begin: _currentArcHeight,
      end: widget.arcHeight,
    ).chain(CurveTween(curve: widget.curve)).animate(_animationController);

    _animationController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => CustomPaint(
          painter: CurvePainter2(
            arcHeight: _arcHeightAnimation.value,
            base: _baseAnimation.value,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class CurvePainter2 extends CustomPainter {
  CurvePainter2({
    required this.arcHeight,
    required this.base,
    required this.color,
  });
  late Path path;

  /// The length from top of the arc to bottom of the screen
  final double arcHeight;

  /// The length from the intersection point of the arc to bottom of the screen
  final double base;

  /// The filled color of the arc
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    path = Path();
    if (arcHeight.isNegative || base.isNegative) {
      return;
    }
    if (arcHeight > base) {
      // Given the ellipse equation as (x/a)^2 + (y/b)^2 = 1
      // Where b = arcHeight
      // The intersection points of the ellipse with the screen edge at
      // x = - size.width / 2 and y = size.height - base
      //
      // a, which is half of the ellipse width, is calculated as follows:
      // a = sqrt(x^2 / (1 - y^2 / b^2))

      final b = arcHeight;
      final x = size.width / 2;
      final y = base;
      final a = sqrt(x * x / (1 - y * y / (b * b)));

      path.addArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height),
          width: a * 2,
          height: b * 2,
        ),
        -pi,
        pi,
      );
    } else {
      // Cannot make an arc. Make a rectangle instead
      path.addRect(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height),
          width: size.width,
          height: base * 2,
        ),
      );
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool? hitTest(Offset position) {
    return path.contains(position);
  }
}
