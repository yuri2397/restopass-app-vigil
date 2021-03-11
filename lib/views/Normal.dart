import 'package:flutter/material.dart';
import 'package:vigil/constants.dart';

class Normal extends StatefulWidget {
  final int price1, price2, price3;
  const Normal({Key key, this.price1, this.price2, this.price3})
      : super(key: key);

  @override
  _NormalState createState() => _NormalState();
}

class _NormalState extends State<Normal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu_open_rounded),
              onPressed: () {},
            );
          },
        ),
        iconTheme: IconThemeData(
          color: kPrimaryColor,
        ),
        title: Text("RestoPass",
            style: TextStyle(
                color: kPrimaryColor,
                fontSize: 25,
                fontFamily: "Poppins Light",
                fontWeight: FontWeight.bold)),
      ),
      body: _bodyContainer(context),
    );
  }

  Widget _bodyContainer(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: size.width * .4,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: _cardItem(
                    context,
                    "Petit Déjeuner",
                    widget.price1.toString(),
                    Icon(
                      Icons.fastfood,
                      color: kPrimaryColor,
                    )),
              ),
              Container(
                width: size.width * .4,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: _cardItem(
                    context,
                    "Déjeuner",
                    widget.price2.toString(),
                    Icon(
                      Icons.fastfood,
                      color: kPrimaryColor,
                    )),
              ),
            ],
          ),
          Container(
            width: size.width * .4,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            child: _cardItem(
                context,
                "Déjeuner",
                widget.price2.toString(),
                Icon(
                  Icons.fastfood,
                  color: kPrimaryColor,
                )),
          ),
        ],
      ),
    );
  }

  Widget _cardItem(
      BuildContext context, String title, String content, Icon image) {
    return Material(
      elevation: 2.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 50.0,
            width: 50.0,
            child: image,
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            title,
            style: TextStyle(
                fontFamily: "Poppin Light",
                fontWeight: FontWeight.w700,
                fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            content,
            style: TextStyle(
              fontFamily: "Poppin Light",
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
