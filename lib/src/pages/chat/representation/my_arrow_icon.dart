import 'package:flutter/material.dart';

class ArrowIconAnimation extends StatefulWidget {
  final bool isExpanded;

  const ArrowIconAnimation({required this.isExpanded, Key? key})
      : super(key: key);

  @override
  _ArrowIconAnimationState createState() => _ArrowIconAnimationState();
}

class _ArrowIconAnimationState extends State<ArrowIconAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns =
        Tween<double>(begin: 0.0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    return Center(
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: _iconTurns,
        color: Colors.black,
      ),
    );
  }
}
