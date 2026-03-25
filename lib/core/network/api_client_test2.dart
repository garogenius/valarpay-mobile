import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final res = await dio.post(
      'https://valar-pay-api.up.railway.app/api/v1/auth/login',
      data: {'username': 'testuser', 'password': 'password123'},
      options: Options(headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-api-key': '5821039487621507',
      }),
    );
    print(res.data);
  } catch (e) {
    print(e);
  }
}
