import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class NgnAccountChecker {
  static void checkAndExecute(BuildContext context, WidgetRef ref, VoidCallback action) {
    final user = ref.read(userProvider);
    final hasNgnWallet = user?.wallets.any((w) => w.currency.toUpperCase() == 'NGN') ?? false;

    if (!hasNgnWallet) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Action Required'),
          content: const Text(
              'You need to have an NGN account in order to use savings and investment features.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF76301),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.push('/bvn-verification');
              },
              child: const Text('Get NGN Account', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    action();
  }
}
