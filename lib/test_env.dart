import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  print(dotenv.env['URL_POWERBI']);
}