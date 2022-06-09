// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:remote_over/controller.dart';
import 'package:remote_over/switch.dart';
import 'package:remote_over/verification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PairedList extends StatefulWidget {
  final bool start;
  const PairedList({this.start = true});

  @override
  State<PairedList> createState() => _PairedListState();
}

class _PairedListState extends State<PairedList> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  var _restartDiscovery;
  bool isConnected = false;
  bool connecting = false;
  var server;
  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0)
          results[existingIndex] = r;
        else
          results.add(r);
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  bool conState = false;
  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: Scaffold(
          appBar: AppBar(
            title: isDiscovering
                ? const Text('Discovering devices')
                : const Text('Discovered devices'),
            actions: <Widget>[
              isDiscovering
                  ? FittedBox(
                      child: Container(
                        margin: const EdgeInsets.all(16.0),
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.replay),
                      onPressed: _restartDiscovery,
                    )
            ],
          ),
          body: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (BuildContext context, index) {
                  BluetoothDiscoveryResult result = results[index];
                  final device = result.device;
                  final address = device.address;
                  return ListTile(
                      onTap: (() async {
                        EasyLoading.show(status: 'Connecting...');
                        if (connecting) {
                          // toast('Connecting Please Wait!');
                          EasyLoading.showToast(
                              'Connecting... \n please wait!');
                          EasyLoading.dismiss();
                        } else {
                          setState(() {
                            connecting = true;
                          });
                          try {
                            BluetoothConnection bluetooth =
                                await BluetoothConnection.toAddress(address);

                            server = bluetooth;
                            print(bluetooth);
                            setPref('isConnected', 'true');
                            setPref('deviceName', result.device.name);
                            setPref('ble', server);
                            setState(() {
                              isConnected = true;
                            });
                            print('Connected');
                            EasyLoading.showSuccess('Connected!');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BL_VERIFY(server: bluetooth),
                              ),
                            );
                          } catch (e) {
                            EasyLoading.dismiss();
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.TOPSLIDE,
                              title: 'Error Connecting',
                              desc:
                                  "There is an error connecting with ${result.device.name} \n Possible Reasons: \n Device already connected \n Device not available \n Device not Supported",
                              btnOkOnPress: () async {
                                EasyLoading.show(status: 'Connecting...');
                                try {
                                  BluetoothConnection bluetooth =
                                      await BluetoothConnection.toAddress(
                                          address);
                                  server = bluetooth;
                                  print('Connected');
                                  setPref('deviceName', result.device.name);
                                  // EasyLoading.dismiss();
                                  EasyLoading.showSuccess('Connected!');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BL_VERIFY(server: bluetooth),
                                    ),
                                  );
                                } catch (e) {
                                  // EasyLoading.dismiss();
                                  EasyLoading.showError(
                                      'Device not available or not suported!');
                                }
                              },
                              btnOkText: 'Try Again',
                            ).show();

                            // toast('Error Connecting to the device');
                            EasyLoading.showError(
                                'Error Connecting to the device!');
                            EasyLoading.showError('Please try again!');
                            // toast('Please try again!');
                            print('Error Occured Connecting to the device');
                          }
                          EasyLoading.dismiss();
                          setState(() {
                            connecting = false;
                          });
                        }
                      }),
                      leading: Icon(Icons.devices),
                      trailing: Text(
                        "${address}",
                        style: TextStyle(color: Colors.green, fontSize: 15),
                      ),
                      title: Text("${device.name}"));
                },
              ),
              SizedBox(
                height: 100,
              ),
            ],
          )),
    );
  }
}
