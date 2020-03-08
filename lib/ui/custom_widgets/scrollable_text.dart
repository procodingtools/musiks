import 'package:flutter/material.dart';

class ScrollableText extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration, backDuration, pauseDuration;

  ScrollableText({
    @required this.child,
    this.direction: Axis.horizontal,
    this.animationDuration: const Duration(milliseconds: 3000),
    this.backDuration: const Duration(milliseconds: 800),
    this.pauseDuration: const Duration(milliseconds: 800),
  });

  @override
  _ScrollableTextState createState() => _ScrollableTextState();
}

class _ScrollableTextState extends State<ScrollableText> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scroll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget.child,
      scrollDirection: widget.direction,
      controller: scrollController,
    );
  }

  void scroll() async {
    try {
      while (true) {
        await Future.delayed(widget.pauseDuration);
        await scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: widget.animationDuration,
            curve: Curves.easeInOut);
        await Future.delayed(widget.pauseDuration);
        await scrollController.animateTo(0.0,
            duration: widget.backDuration, curve: Curves.easeInOut);
      }
    }catch(e){}
  }
}