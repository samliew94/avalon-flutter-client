import 'dart:convert';

import 'package:avalonweb/alert_ok.dart';
import 'package:avalonweb/extensions.dart';
import 'package:avalonweb/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'config.dart';
import 'game.dart';

class LobbyView extends StatefulWidget {
  final String playerName;

  const LobbyView({super.key, required this.playerName});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avalon Web (Lobby)'),
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
                heroTag: "btnRefresh",
                tooltip: "Refresh Players",
                onPressed: () {
                  setState(() {});
                },
                child: const Icon(Icons.refresh)),
            FloatingActionButton(
                heroTag: "btnSettings",
                tooltip: "Settings",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsView()),
                  );
                },
                child: const Icon(Icons.settings)),
            FloatingActionButton(
                heroTag: "btnStart",
                tooltip: "Start Game",
                onPressed: () => _startGame(widget.playerName),
                child: const Icon(Icons.play_arrow))
          ],
        ),
      ),
      body: FutureBuilder(
          future: getAllPlayers(),
          builder: ((context, snapshot) {
            List<Widget> children;

            if (snapshot.hasData) {
              Map data = snapshot.data;
              List players = data["players"];

              var listView = Expanded(
                child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: ((context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                              "${index + 1}. ${players[index].toString().capitalize()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .apply(color: Colors.black)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.playerName.toLowerCase() == players[index]
                                  ? const SizedBox()
                                  : IconButton(
                                      splashRadius: 1,
                                      icon: Icon(RpgAwesome.crown,
                                          color: HexColor.fromHex("FFD700"),
                                          size: 32),
                                      onPressed: () {
                                        _makeHost(players[index]);
                                      },
                                    ),
                              widget.playerName.toLowerCase() == players[index]
                                  ? const SizedBox()
                                  : IconButton(
                                      splashRadius: 1,
                                      icon: const Icon(
                                          FontAwesomeIcons.circleMinus,
                                          color: Colors.red),
                                      onPressed: () {
                                        _removePlayer(players[index]);
                                      },
                                    ),
                            ],
                          ),
                        ),
                      );
                    })),
              );

              children = <Widget>[listView];
            } else {
              children = const <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),
              ];
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            );
          })),
    );
  }

  Future getAllPlayers() async {
    final response = await http.get(Uri.parse(
        '${Config.getServerIp()}/api/players/all/${widget.playerName}'));

    var body = jsonDecode(response.body);

    return body;
  }

  void _removePlayer(targetUsername) async {
    Response res;
    try {
      res = await http.delete(Uri.parse(
          '${Config.getServerIp()}/api/players/del/${widget.playerName}/$targetUsername'));
    } on Exception catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (res.statusCode != 200) {
      AlertOk.showAlert(context, res.body);
      return;
    }

    setState(() {});
  }

  void _makeHost(targetUsername) async {
    Response res;
    try {
      res = await http.post(Uri.parse(
          '${Config.getServerIp()}/api/players/makehost/${widget.playerName}/$targetUsername'));
    } on Exception catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (res.statusCode != 200) {
      AlertOk.showAlert(context, res.body);
      return;
    }

    AlertOk.showAlert(context, res.body,
        callback: () => Navigator.pop(context));
  }

  void _startGame(playerName) async {
    Response res;
    try {
      res = await http.post(
          Uri.parse('${Config.getServerIp()}/api/game/start/$playerName'));
    } on Exception catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (res.statusCode != 200) {
      AlertOk.showAlert(context, res.body);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameView(playerName: playerName)),
    );
  }
}
