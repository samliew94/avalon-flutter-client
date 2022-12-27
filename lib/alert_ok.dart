import 'package:flutter/material.dart';

class AlertOk {
  static void showAlert(context, msg, {VoidCallback? callback}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(msg,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                  if (callback != null) callback.call();
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        });
  }
}
