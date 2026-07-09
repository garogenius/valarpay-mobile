import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple UI StateProviders for the airtime screen selections
final airtimeUseCashbackProvider = StateProvider<bool>((ref) => false);
final airtimeSelectedNetworkProvider = StateProvider<String>((ref) => '');
final airtimeSelectedOperatorIdProvider = StateProvider<int>((ref) => 0);
final airtimeSelectedBillerIdProvider = StateProvider<String?>((ref) => null);
final airtimeSelectedBillItemIdProvider = StateProvider<String?>((ref) => null);
