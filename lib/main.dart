import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Demander les permissions avant de lancer l'app
  if (!kIsWeb) {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.location.request();
  }

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
    _requestPermissions();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await Permission.camera.request();
      await Permission.microphone.request();
    }
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

class _HomeScreenState extends State<HomeScreen> {
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _checkProtocol();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await Permission.camera.request();
      await Permission.microphone.request();
    } else {
      print("Running on web - permissions handled by browser");
    }
  }

  void _checkProtocol() {
    if (kIsWeb) {
      print("Web app running - check browser console for HTTPS requirements");
    }
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
            // Permissions générales
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            allowFileAccess: true,
            allowContentAccess: true,

            // Permissions spécifiques pour les médias
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),

          onPermissionRequest: (controller, request) async {
            print("Permission demandée: ${request.resources}");

            // Toujours accorder les permissions pour caméra et micro
            if (request.resources.contains(PermissionResourceType.CAMERA) ||
                request.resources.contains(PermissionResourceType.MICROPHONE)) {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            }

            // Accorder toutes les autres permissions aussi
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },

          onWebViewCreated: (controller) {
            webViewController = controller;
            print("WebView créée");
          },

          onLoadStart: (controller, url) {
            print("Début du chargement: $url");
          },

          onLoadStop: (controller, url) async {
            print("Fin du chargement: $url");

            // Injecter du JavaScript pour gérer les permissions
            await controller.evaluateJavascript(
              source: """
              // Vérifier le protocole
              console.log('Current protocol:', window.location.protocol);
              if (window.location.protocol !== 'https:' && window.location.hostname !== 'localhost') {
                console.warn('Camera access requires HTTPS or localhost');
              }
              
              // Polyfill pour getUserMedia
              navigator.getUserMedia = navigator.getUserMedia || 
                                     navigator.webkitGetUserMedia || 
                                     navigator.mozGetUserMedia;

              if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                // Test d'accès à la caméra
                navigator.mediaDevices.getUserMedia({video: true, audio: false})
                  .then(function(stream) {
                    console.log('Camera access granted');
                    // Arrêter le stream immédiatement
                    stream.getTracks().forEach(track => track.stop());
                  })
                  .catch(function(error) {
                    console.error('Camera access denied:', error);
                    if (error.name === 'NotAllowedError') {
                      console.error('Permission denied by user or policy');
                    } else if (error.name === 'NotSecureError') {
                      console.error('HTTPS required for camera access');
                    }
                  });
              }
              
              // Vérifier les permissions
              if (navigator.permissions && navigator.permissions.query) {
                navigator.permissions.query({name: 'camera'}).then(function(result) {
                  console.log('Camera permission state:', result.state);
                });
                navigator.permissions.query({name: 'microphone'}).then(function(result) {
                  console.log('Microphone permission state:', result.state);
                });
              }
            """,
            );
          },

          onLoadError: (controller, url, code, message) {
            print("Erreur de chargement: $message (Code: $code)");
          },

          onConsoleMessage: (controller, consoleMessage) {
            print("Console JS: ${consoleMessage.message}");
          },
        ),
      ),
    );
  }
}
