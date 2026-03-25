import 'package:valarpay/core/network/api_client.dart';
void main() async {
  final client = ApiClient();
  final res = await client.get('/api/v1/bill/remita/education/get-plan', useAuth: false);
  print(res.statusCode);
  print(res.data);
}
