import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BalanceSkeleton extends StatelessWidget {
  const BalanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).primaryColor,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 16, height: 16, color: Colors.white),
                const SizedBox(width: 8),
                Container(width: 100, height: 12, color: Colors.white),
                const Spacer(),
                Container(width: 100, height: 12, color: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            Container(width: 150, height: 30, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
