import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Forçar modo retrato (ou landscape, dependendo da TV)
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  // Forçar fullscreen imersivo
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await dotenv.load();
  debugPrint('URL_POWERBI: ${dotenv.env['URL_POWERBI']}');
  runApp(const KioskApp());
}

class KioskApp extends StatelessWidget {
  const KioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebviewPage(),
    );
  }
}

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  late final String urlPowerBI;
  late final WebViewController _controller;
  late final String url;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // impede tela de apagar

    urlPowerBI = dotenv.env['URL_POWERBI'] ?? '';
    url = urlPowerBI;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            debugPrint("Erro ao carregar página: ${error.description}");
            // Tenta recarregar após 5 segundos
            Future.delayed(const Duration(seconds: 360), () {
              _controller.loadRequest(Uri.parse(url));
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081E5B),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
