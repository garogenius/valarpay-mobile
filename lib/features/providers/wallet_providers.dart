import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/models/wallet.dart';
import 'package:valarpay/features/providers/user_provider.dart';

final activeWalletIndexProvider = StateProvider<int>((ref) => 0);

final activeWalletProvider = Provider<WalletModel?>((ref) {
  final user = ref.watch(userProvider);
  final index = ref.watch(activeWalletIndexProvider);
  
  if (user == null || user.wallets.isEmpty) return null;
  if (index >= user.wallets.length) return user.wallets.first;
  
  return user.wallets[index];
});
