import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    this.totalPages = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 67,
      height: 30,
      child: Stack(
        children: [
          // Paw prints background indicators
          ...List.generate(totalPages, (index) {
            return Positioned(
              left: index * 20.0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: index <= currentPage 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.pets,
                  size: 12,
                  color: index <= currentPage 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }),
          
          
        ],
      ),
    );
  }
}

