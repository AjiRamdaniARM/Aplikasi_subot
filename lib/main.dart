import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InAppWebViewController? _controller;
  final CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    _loadCookies(); // Load cookies when app starts
  }

  Future<void> _loadCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cookies = prefs.getString('cookies');
    if (cookies != null && _controller != null) {
      // Load the cookies into the web view
      List<String> cookieList = cookies.split('; ');
      for (var cookie in cookieList) {
        await _cookieManager.setCookie(
          url: Uri.parse('https://app.sukarobot.com/LoginTrainer'),
          name: cookie.split('=')[0],
          value: cookie.split('=')[1],
        );
      }
    }
  }

  Future<void> _saveCookies() async {
    List<Cookie> cookies = await _cookieManager.getCookies(
        url: Uri.parse('https://app.sukarobot.com/LoginTrainer'));
    String cookieString =
        cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cookies', cookieString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse('https://app.sukarobot.com/home'),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            clearCache: true,
            disableHorizontalScroll: false,
            disableVerticalScroll: false,
            mediaPlaybackRequiresUserGesture: false,
            preferredContentMode: UserPreferredContentMode.RECOMMENDED,
          ),
        ),
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        onLoadStop: (controller, url) async {
          await _saveCookies(); // Save cookies when page finishes loading
          print("Finished loading: $url");
        },
        onLoadError: (controller, url, code, message) {
          // Event saat terjadi error
          print("Error loading: $url, Error: $message");
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url.toString();
          if (url.startsWith('https://www.youtube.com/')) {
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 70.0), // === Memindahkan tombol ke atas
        child: FloatingActionButton(
          onPressed: _refreshPage,
          tooltip: 'Refresh',
          backgroundColor: const Color.fromARGB(
              255, 0, 102, 255), // Mengubah warna background
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  void _refreshPage() {
    _controller?.reload();
  }
}
