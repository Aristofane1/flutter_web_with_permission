import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.location.request();
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter InAppWebView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    permi();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [const CircularProgressIndicator()],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

permi() async {
  await Permission.camera.request();
}

class _HomeScreenState extends State<HomeScreen> {
  InAppWebViewController? webViewController;

  @override
  void initState() {
    permi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://fr.webcamtests.com/"),
          ),
          initialSettings: InAppWebViewSettings(
            allowFileAccess: true,
            allowContentAccess: true,
            // crossPlatform: InAppWebViewOptions(
            //   javaScriptEnabled: true,
            //   useShouldOverrideUrlLoading: true,
            //   mediaPlaybackRequiresUserGesture: false,
            //   allowFileAccessFromFileURLs: true,
            //   allowUniversalAccessFromFileURLs: true,
            // ),
            // android: AndroidInAppWebViewOptions(
            //   useHybridComposition: true,
            //   allowFileAccess: true,
            //   allowContentAccess: true,
            // ),
          ),
          onPermissionRequest: (controller, request) async {
            if (request.resources.contains(PermissionResourceType.CAMERA)) {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            } else if (request.resources.contains(
              PermissionResourceType.MICROPHONE,
            )) {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            }
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadError: (controller, url, code, message) {
            print("Erreur de chargement: $message");
          },
          // androidOnShowFileChooser: (controller, fileChooserParams) async {
          //   return await _androidFilePicker();
          // },
        ),
      ),
    );
  }
}
