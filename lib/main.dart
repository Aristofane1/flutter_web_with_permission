import 'dart:ui_web';
import 'package:universal_html/html.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  if (kIsWeb) {
    platformViewRegistry.registerViewFactory('externalSite', (int viewId) {
      final iframe =
          IFrameElement()
            ..src = 'https://fr.webcamtests.com/'
            ..style.border = 'none'
            ..allow =
                'camera; microphone; fullscreen' // autoriser l'accès
            ..allowFullscreen = true;

      return iframe;
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IframePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IframePage extends StatelessWidget {
  const IframePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Scaffold(
        body: Center(child: Text('Disponible uniquement sur Flutter Web')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Site externe avec caméra")),
      body: const Center(
        child: SizedBox(
          width: 800,
          height: 600,
          child: HtmlElementView(viewType: 'externalSite'),
        ),
      ),
    );
  }
}
