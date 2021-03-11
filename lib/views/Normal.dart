import 'package:flutter/material.dart';
import 'package:vigil/views/Scan.dart';

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
        leading: Icon(Icons.local_restaurant_rounded),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text("RestoPass",
            style: TextStyle(
                color: Colors.black,
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
      padding: EdgeInsets.only(top: 15),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: size.width * .45,
                height: 200,
                margin: EdgeInsets.all(10),
                padding:
                    EdgeInsets.only(top: 7, left: 10, right: 10, bottom: 7),
                child: _cardItem(context, "Petit Déjeuner", widget.price1,
                    "assets/images/breakfast.jpg", 1),
              ),
              Container(
                width: size.width * .45,
                height: 200,
                padding:
                    EdgeInsets.only(top: 7, left: 10, right: 10, bottom: 7),
                child: _cardItem(context, "Repas", widget.price2,
                    "assets/images/dinner.jpg", 2),
              ),
            ],
          ),
          Container(
            width: size.width * .45,
            height: 200,
            margin: EdgeInsets.only(left: 15.0),
            padding: EdgeInsets.only(top: 7, left: 10, right: 10, bottom: 7),
            child: _cardItem(
                context, "Dîner", widget.price3, "assets/images/dinner.png", 3),
          ),
        ],
      ),
    );
  }

  Widget _cardItem(
      BuildContext context, String title, int price, String image, int id) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Scan(price: price, id: id, title: title, image: image)));
      },
      child: Material(
        color: Colors.white,
        elevation: 5.0,
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100.0,
              width: 100.0,
              child: Image.asset(image),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              title,
              style: TextStyle(fontFamily: "Poppin Light", fontSize: 15.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              price.toString() + "FCFA",
              style: TextStyle(
                fontFamily: "Poppin Light",
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
