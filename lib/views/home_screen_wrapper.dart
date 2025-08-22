import 'package:flutter/material.dart';

class HomeScreenWrapper extends StatelessWidget {
  final Widget child;
  final bool isAnyLoading;
  const HomeScreenWrapper({super.key, required this.child,required this.isAnyLoading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isAnyLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(102),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
