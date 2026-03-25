import 'package:valarpay/core/network/api_client.dart';

void main() async {
  final client = ApiClient();
  final res = await client.get('/api/v1/bill/remita/vending/providers');
  print(res);
}
