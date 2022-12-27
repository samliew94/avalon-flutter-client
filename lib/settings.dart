import 'dart:convert';

import 'package:avalonweb/extensions.dart';
import 'package:avalonweb/rpgicon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'alert_ok.dart';
import 'config.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  var isActives = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avalon Web (Settings)'),
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
        future: getAllRoles(),
        builder: (context, snapshot) {
          var children = <Widget>[];
          if (snapshot.hasData) {
            List roles = snapshot.data;

            var listView = Expanded(
              child: ListView.builder(
                  itemCount: roles.length,
                  itemBuilder: ((context, index) {
                    var roleId = roles[index]["roleId"];
                    var roleTitle = roles[index]["roleTitle"];
                    var roleTitleColor = roles[index]["roleTitleColor"];
                    var roleIcon = roles[index]["roleIcon"];
                    var isActive = roles[index]["isActive"];
                    var isEditable = roles[index]["isEditable"];

                    return Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            Icon(
                              RpgIconUtil.toIcon(roleIcon),
                              color: HexColor.fromHex(roleTitleColor),
                            ),
                            const SizedBox(width: 20),
                            Text(roleTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .apply(
                                        color:
                                            HexColor.fromHex(roleTitleColor))),
                          ],
                        ),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            checkColor: Colors.white,
                            value: isActive == 1 ? true : false,
                            onChanged: isEditable == 0
                                ? null
                                : (bool? value) => _toggleRole(roleId),
                          )
                        ]),
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
        },
      ),
    );
  }

  Future getAllRoles() async {
    Response res;
    try {
      res = await http.get(Uri.parse('${Config.getServerIp()}/api/roles/all'));
    } on Exception catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (res.statusCode != 200) {
      AlertOk.showAlert(context, res.body);
      return;
    }

    return jsonDecode(res.body);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => GameView(playerName: playerName)),
    // );
  }

  _toggleRole(roleId) async {
    Response res;
    try {
      res = await http.post(
        Uri.parse('${Config.getServerIp()}/api/roles/toggle'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'roleId': roleId,
        }),
      );
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
}
