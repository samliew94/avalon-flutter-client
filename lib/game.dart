import 'dart:convert';

import 'package:avalonweb/rpgicon.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'extensions.dart';

class GameView extends StatefulWidget {
  final String playerName;

  const GameView({super.key, required this.playerName});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  String gameId = "";
  String playerName = "";
  int loyalty = -1;
  String roleTitle = "";
  String roleTitleColor = "";
  String roleDescription = "";
  String otherPlayersTitle = "";
  List otherPlayersName = [];
  String otherPlayersNameColor = "";
  String roleIcon = "";

  bool isFlipped = false; // defaults to "Tap to See"

  Widget _cover() {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      elevation: 5,
      child: InkWell(
        onTap: () => seeRole(),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [
                HexColor.fromHex("#b80000"),
                HexColor.fromHex("#00495c"),
              ])),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Tap to See',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .apply(color: Colors.white),
                  ),
                  const Icon(
                    FontAwesomeIcons.userSecret,
                    color: Colors.white,
                    size: 128,
                  ),
                  Text(
                    'Secret Role',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .apply(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      elevation: 5,
      child: InkWell(
        onTap: () => setState(() {
          isFlipped = false;
        }),
        child: Stack(
          children: [
            Center(
              child: Icon(RpgIconUtil.toIcon(roleIcon),
                  size: 400.0,
                  color: HexColor.fromHex(roleTitleColor).withOpacity(0.15)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Game ID : $gameId",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .apply(color: Colors.grey)),
                    const SizedBox(height: 20),
                    Text(playerName.capitalize(),
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .apply(color: Colors.black)),
                    Text(roleTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .apply(color: HexColor.fromHex(roleTitleColor))),
                    Text(roleDescription,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .apply(color: Colors.black)),
                    const SizedBox(height: 20),
                    Text(otherPlayersTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .apply(color: Colors.black)),
                    otherPlayerNamesWidget(),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Avalon Web (Game)'),
          // backgroundColor: Colors.green,
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        body: !isFlipped ? _cover() : _content());
  }

  Widget otherPlayerNamesWidget() {
    if (otherPlayersName.isEmpty) {
      return Column();
    }
    Color color = HexColor.fromHex(otherPlayersNameColor);

    var children = <Widget>[];
    for (var e in otherPlayersName) {
      children.add(Text(e.toString().capitalize(),
          style: Theme.of(context).textTheme.headline5!.apply(color: color)));
    }

    return Column(children: children);
  }

  Future seeRole() async {
    Response res;

    try {
      res = await http.get(Uri.parse(
          '${Config.getServerIp()}/api/players/seerole/${widget.playerName}'));
    } on Exception catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (res.statusCode != 200) {
      AlertOk.showAlert(context, res.body);
      return;
    }

    var body = jsonDecode(res.body);

    setState(() {
      gameId = body["gameId"];
      playerName = body["playerName"].toString().capitalize();
      loyalty = body["loyalty"];
      roleTitle = body["roleTitle"];
      roleTitleColor = body["roleTitleColor"];
      roleDescription = body["roleDescription"]
          .toString()
          .replaceAll(".", "\n")
          .replaceAll("-", "'");
      otherPlayersTitle = body["otherPlayersTitle"] ?? "";
      otherPlayersName = body["otherPlayersName"];
      otherPlayersNameColor = body["otherPlayersNameColor"] ?? "";
      roleIcon = body["roleIcon"] ?? "";

      isFlipped = true;
    });
  }

  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Colors.red, Colors.blue],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 300, 70.0));
}
