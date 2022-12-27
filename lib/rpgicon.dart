import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RpgIconUtil {
  static IconData toIcon(String name) {
    if (name.isEmpty) return FontAwesomeIcons.question;
    if (name == "ra-crystal-ball") return RpgAwesome.crystal_ball;
    if (name == "ra-daggers") return RpgAwesome.daggers;
    if (name == "ra-eye-shield") return RpgAwesome.eye_shield;
    if (name == "ra-raven") return RpgAwesome.raven;
    if (name == "ra-knight-helmet") return RpgAwesome.knight_helmet;
    if (name == "ra-helmet") return RpgAwesome.helmet;
    if (name == "ra-horns") return RpgAwesome.horns;
    if (name == "ra-flaming-claw") return RpgAwesome.flaming_claw;

    return FontAwesomeIcons.question;
  }
}
