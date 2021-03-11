import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:vigil/constants.dart';
import 'package:http/http.dart' as http;
import 'package:vigil/models/ApiResponse.dart';
import 'package:vigil/utils/SharedPref.dart';

class Scan extends StatefulWidget {
  final String title;
  final int price;
  final int id;
  final String image;
  const Scan({Key key, this.title, this.price, this.id, this.image})
      : super(key: key);

  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  bool _isLoad = false, _setState = false;
  IconData _icon = Icons.check_box_rounded;
  Color _color = Colors.green;
  String _message = "Message d'erreur";
  final _default = Image.asset('assets/images/qrcode.png');
  Widget _other = Container();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.keyboard_arrow_left_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(widget.title + " (" + widget.price.toString() + " fcfa)",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: "Poppins Light",
                fontWeight: FontWeight.bold)),
      ),
      body: Container(color: Colors.white, child: _main(context)),
    );
  }

  Widget _onSuccess(BuildContext context, String message, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline_outlined, color: color, size: 100),
        Text(message,
            style: TextStyle(
              color: color,
              fontSize: 15,
            ),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _onError(BuildContext context, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Colors.red,
          size: 100,
        ),
        Text(message,
            style: TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontFamily: "Poppin Light",
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _onInfo(BuildContext context, Color color, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.info_outline_rounded, color: color, size: 100),
        Text(message,
            style: TextStyle(
              color: color,
              fontSize: 15,
            ),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _main(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Positioned(
            width: 200,
            top: 20,
            child: Column(
              children: [
                Image.asset(widget.image, width: 150),
                SizedBox(
                  height: 20,
                ),
                Text("Ticket de   " + widget.price.toString() + " FCFA",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: "Poppins Light",
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 30,
                ),
                _other
              ],
            )),
        Positioned(
            bottom: 100,
            right: 0,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  topLeft: Radius.circular(50)),
              child: Container(
                alignment: Alignment.center,
                color: kPrimaryColor,
                child: MaterialButton(
                  elevation: 5,
                  onPressed: () async {
                    try {
                      String number = await BarcodeScanner.scan();
                      print("USER NUMBER : " + number);
                      if (number.length != 11) {
                        // montant insuffisant
                        setState(() {
                          _isLoad = false;
                          _setState = true;
                          _other = _onInfo(
                              context, Colors.redAccent, "QR code invalide");
                        });
                        return;
                      }
                      setState(() {
                        _isLoad = true;
                        _setState = false;
                        _other = progressBar();
                      });

                      ApiResponse res = await scan(number, widget.id);
                      print("RES SCAN : " + res.message);

                      if (res.error == false) {
                        setState(() {
                          _isLoad = false;
                          _setState = true;
                          _other = _onSuccess(context, "Okay", Colors.green);
                        });
                      } else if (res.error == true) {
                        setState(() {
                          _isLoad = false;
                          _setState = true;
                          _other = _onError(context, res.message);
                        });
                      } else if (res == null) {
                        setState(() {
                          _isLoad = false;
                          _setState = true;
                          _message = "Vérifier votre connexion internet.";
                          _icon = Icons.wifi_off_rounded;
                          _color = kPrimaryColor;
                        });
                      }
                    } catch (e) {
                      print("SCAN CATCH $e");
                    }
                  },
                  color: Colors.white,
                  textColor: kPrimaryColor,
                  child: Icon(
                    Icons.qr_code_rounded,
                    size: 24,
                  ),
                  padding: EdgeInsets.all(16),
                  shape: CircleBorder(),
                ),
              ),
            ))
      ],
    );
  }

  Widget progressBar() {
    return Container(
      alignment: Alignment.center,
      child: SleekCircularSlider(
        initialValue: 10,
        max: 100,
        appearance: CircularSliderAppearance(
            angleRange: 360,
            spinnerMode: true,
            startAngle: 90,
            size: 100,
            customColors: CustomSliderColors(
              hideShadow: true,
              progressBarColor: kPrimaryColor,
            )),
      ),
    );
  }

  // REQUEST METHODE
  Future<ApiResponse> scan(String number, int type) async {
    String url = BASE_URL + '/api/vigilant/scan';

    String accessToken = await new SharedPref().getUserAccessToken();

    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = jsonEncode({
      "number": number,
      "type": type,
    });

    try {
      final response =
          await http.post(url, body: body, headers: requestHeaders);
      print("RESPONSE : " + response.body);
      final String responseString = response.body;
      return apiResponseFromJson(responseString);
    } catch (e) {
      return null;
    }
  }
}
