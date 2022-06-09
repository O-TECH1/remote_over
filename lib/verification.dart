// ignore_for_file: camel_case_types, use_key_in_widget_constructors
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:remote_over/controller.dart';
import 'package:remote_over/switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BL_VERIFY extends StatefulWidget {
  final BluetoothConnection server;
  const BL_VERIFY({required this.server});

  @override
  State<BL_VERIFY> createState() => _BL_VERIFYState();
}

class _BL_VERIFYState extends State<BL_VERIFY> {
  final TextEditingController _pin = TextEditingController();
  Future<String> _getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String res = prefs.getString('deviceName').toString();
    print(res);
    return res;
  }

  bool sending = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          // centerTitle: true,
          title: Center(
              child: Row(
            children: [
              const Text('Bluetooth Verification'),
              const SizedBox(
                width: 220,
              ),
              InkWell(
                onTap: () {
                  showMaterialModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        // <-- SEE HERE
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25.0),
                        ),
                      ),
                      context: context,
                      builder: (context) => Container(
                          height: 500,
                          padding:
                              EdgeInsets.only(top: 20, left: 30, right: 30),
                          child: Column(
                            children: [
                              const Text(
                                'SET DEVICE PIN',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 80,
                              ),
                              TextField(
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                controller: _pin,
                                decoration: const InputDecoration(
                                  // ignore: prefer_const_constructors
                                  border: OutlineInputBorder(),
                                  // ignore: unrelated_type_equality_checks
                                  hintText: 'Set 4 Digit PIN',
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () {}, child: Text('SET'))
                            ],
                          )));
                },
                child: const Text('SET'),
              )
            ],
          )),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 60, right: 30, left: 30),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Center(
                  child: FutureBuilder<String>(
                future: _getName(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<String> snapshot,
                ) {
                  print(snapshot.connectionState);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return const Text('Device seem to be disconnected!');
                    } else if (snapshot.hasData) {
                      return Text(
                        "Device: ${snapshot.data!}",
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      );
                    } else {
                      return const Text('Device seem to be disconnected!');
                    }
                  } else {
                    return Text('State: ${snapshot.connectionState}');
                  }
                },
              )),
              const SizedBox(
                height: 50,
              ),
              TextField(
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                controller: _pin,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Device PIN',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              sending
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          sending = true;
                        });
                        if (_pin.text.length == 4) {
                          widget.server.output
                              .add(ascii.encode('getPin' + "\r\n"));
                          await widget.server.output.allSent;
                          print('Sent');
                          widget.server.input?.listen((Uint8List data) {
                            var res = ascii.decode(data);
                            print(res);
                            if (res == _pin.text) {
                              setState(() {
                                sending = false;
                              });
                              print('SUCCESS');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SwitchMenu(
                                    server: widget.server,
                                    key: null,
                                  ),
                                ),
                              );
                            } else {
                              setState(() {
                                sending = false;
                              });
                              toast('Incorrect PIN');
                            }
                          });
                        } else {
                          setState(() {
                            sending = false;
                          });
                          toast('Invalid PIN');
                        }
                      },
                      child: const Text('GO'))
            ],
          ),
        ),
      ),
    );
  }
}
