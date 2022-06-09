import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SwitchMenu extends StatefulWidget {
  final BluetoothConnection server;
  const SwitchMenu({required Key? key, required this.server}) : super(key: key);

  @override
  State<SwitchMenu> createState() => _SwitchMenuState();
}

bool _activated = false;

class _SwitchMenuState extends State<SwitchMenu> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Center(
        child: Padding(
            padding: const EdgeInsets.only(top: 50, right: 10, left: 10),
            child: Column(
              children: [
                IconButton(
                    iconSize: 100.0,
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: const FaIcon(FontAwesomeIcons.lightbulb),
                    onPressed: () {
                      print("Pressed");
                    }),
                const SizedBox(
                  height: 50,
                ),
                ToggleSwitch(
                  customWidths: const [300.0, 300.0],
                  minHeight: 100.0,
                  initialLabelIndex: 0,
                  cornerRadius: 50.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Color.fromARGB(255, 0, 0, 0),
                  inactiveFgColor: Colors.white,
                  totalSwitches: 2,
                  icons: const [
                    FontAwesomeIcons.lightbulb,
                    FontAwesomeIcons.solidLightbulb,
                  ],
                  iconSize: 50.0,
                  activeBgColors: const [
                    [
                      Color.fromARGB(255, 230, 0, 0),
                      Color.fromARGB(255, 255, 0, 0)
                    ],
                    [Colors.yellow, Color.fromARGB(255, 255, 251, 0)]
                  ],
                  animate:
                      true, // with just animate set to true, default curve = Curves.easeIn
                  curve: Curves
                      .bounceInOut, // animate must be set to true when using custom curve
                  onToggle: (index) async {
                    if (index == 1) {
                      widget.server.output.add(ascii.encode('l1' + "\r\n"));
                      await widget.server.output.allSent;
                    } else {
                      widget.server.output.add(ascii.encode('l0' + "\r\n"));
                      await widget.server.output.allSent;
                    }
                  },
                ),
                const SizedBox(
                  height: 150,
                ),
                IconButton(
                    iconSize: 100.0,
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: const FaIcon(FontAwesomeIcons.fan),
                    onPressed: () {
                      print("Pressed");
                    }),
                const SizedBox(
                  height: 50,
                ),
                ToggleSwitch(
                  customWidths: const [300.0, 300.0],
                  minHeight: 100.0,
                  initialLabelIndex: 0,
                  cornerRadius: 50.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Color.fromARGB(255, 0, 0, 0),
                  inactiveFgColor: Colors.white,
                  totalSwitches: 2,
                  icons: const [
                    FontAwesomeIcons.fan,
                    FontAwesomeIcons.fan,
                  ],
                  iconSize: 50.0,
                  activeBgColors: const [
                    [
                      Color.fromARGB(255, 230, 0, 0),
                      Color.fromARGB(255, 255, 0, 0)
                    ],
                    [Colors.yellow, Color.fromARGB(255, 255, 251, 0)]
                  ],
                  animate:
                      true, // with just animate set to true, default curve = Curves.easeIn
                  curve: Curves
                      .bounceInOut, // animate must be set to true when using custom curve
                  onToggle: (index) async {
                    if (index == 1) {
                      widget.server.output.add(ascii.encode('f1' + "\r\n"));
                      await widget.server.output.allSent;
                    } else {
                      widget.server.output.add(ascii.encode('f0' + "\r\n"));
                      await widget.server.output.allSent;
                    }
                  },
                ),
              ],
            )
            // SizedBox(
            //   width: double.infinity, // <-- match_parent
            //   height: double.infinity,
            //   child: ElevatedButton(
            //       onPressed: (() async {
            //         widget.server.output.add(
            //             ascii.encode((_activated ? 'Close' : 'Open') + "\r\n"));
            //         await widget.server.output.allSent;
            //         setState(() {
            //           _activated ? _activated = false : _activated = true;
            //         });
            //       }),
            //       child: Text(
            //         (_activated ? 'OFF' : 'ON'),
            //         style: const TextStyle(
            //             fontSize: 200, fontWeight: FontWeight.bold),
            //       )),
            // )
            ),
      )),
    );
  }
}

// Icon(
//                                 Icons.fingerprint,
//                                 color: Colors.blue,
//                                 size: 100.0,
//                               )
