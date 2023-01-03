import 'dart:convert';

import 'package:avalonweb/alert_ok.dart';
import 'package:avalonweb/game.dart';
import 'package:avalonweb/lobby.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avalon',
      theme: _buildTheme(Brightness.dark),
      home: const MyHomePage(title: 'Avalon Web v1.0.0'),
    );
  }

  ThemeData _buildTheme(brightness) {
// ThemeData(
//         primarySwatch: Colors.blue,
//       )

    // var baseTheme = ThemeData(brightness: brightness);
    var baseTheme = ThemeData();

    return baseTheme.copyWith(
        // textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme),
        // textTheme: GoogleFonts.medievalSharpTextTheme(baseTheme.textTheme),
        textTheme: GoogleFonts.mysteryQuestTextTheme(baseTheme.textTheme));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ipController = TextEditingController();
  final playerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    ipController.dispose();
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // TextFormField(
                //   textAlign: TextAlign.center,
                //   controller: ipController,
                //   decoration: const InputDecoration(
                //     border: OutlineInputBorder(),
                //     hintText: 'Server IP',
                //   ),
                // ),
                // const SizedBox(height: 20),
                TextFormField(
                  textAlign: TextAlign.center,
                  controller: playerController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Your Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Config.serverIp = ipController.text;
            addPlayer(playerController.text);
          }
        },
        tooltip: 'Next',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  void addPlayer(String playerName) async {
    Response response;
    var uri = '${Config.getServerIp()}/api/players/add/$playerName';

    try {
      response = await http.post(
        Uri.parse(uri),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return http.Response('Server did not respond at\n$uri', 408);
        },
      );
    } catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (response.statusCode != 200) {
      AlertOk.showAlert(context, response.body);
      return;
    }

    var body = jsonDecode(response.body);

    if (body["isHost"] != null && body["isHost"]) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LobbyView(playerName: playerName)),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameView(playerName: playerName)),
    );
  }
}
