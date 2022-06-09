import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:remote_over/controller.dart';
import 'package:remote_over/paired.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const RemoteOver());

class RemoteOver extends StatefulWidget {
  const RemoteOver({Key? key}) : super(key: key);

  @override
  State<RemoteOver> createState() => _RemoteOverState();
}

class _RemoteOverState extends State<RemoteOver> {
  // ignore: prefer_final_fields
  TextEditingController _pin = TextEditingController();
  var pinSet;
  @override
  void initState() {
    super.initState();
    checkPin();
  }

  Future<String> checkPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? res = prefs.getString('pinSet');
    print(res);
    return res.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Remote Over'),
        ),
        body: FutureBuilder<String>(
          future: checkPin(), // async work
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  print(snapshot.data);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                toast('Not Available');
                              },
                              child: const Icon(
                                Icons.fingerprint,
                                color: Colors.blue,
                                size: 100.0,
                              ),
                            ),
                            const Text('Fingerprint')
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            controller: _pin,
                            decoration: InputDecoration(
                              // ignore: prefer_const_constructors
                              border: OutlineInputBorder(),
                              // ignore: unrelated_type_equality_checks
                              hintText: snapshot.data == 'true'
                                  ? 'Enter Your PIN'
                                  : 'Set 4 Digit PIN',
                            ),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              if (await FlutterBluetoothSerial
                                      .instance.isEnabled ==
                                  true) {
                                if (_pin.text == '' || _pin.text.length != 4) {
                                  toast('Invalid PIN');
                                } else {
                                  if (snapshot.data == 'true') {
                                    if (await getPref('pin') == _pin.text) {
                                      toast('SUCCESS');

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PairedList(),
                                        ),
                                      );

                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         const PairedList(),
                                      //   ),
                                      // );
                                    } else {
                                      toast('Wrong PIN');
                                    }
                                  } else {
                                    await setPref('pinSet', 'true');
                                    await setPref('pin', _pin.text);
                                    toast('SET');

                                    setState(() {
                                      pinSet = 'true';
                                    });
                                  }
                                  setState(() {
                                    _pin.text = '';
                                  });
                                }
                              } else {
                                toast('Please Turn ON Bluetooth First!');
                              }
                            },
                            child: Text(
                              snapshot.data == 'true' ? 'Open' : 'Set PIN',
                            ))
                      ],
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }
}
