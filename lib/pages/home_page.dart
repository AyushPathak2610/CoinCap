import 'dart:convert';

import 'package:coincap/pages/details_page.dart';
import 'package:coincap/services/http_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return __homePageState();
  }
}

class __homePageState extends State<HomePage> {
  double? _deviceHeight, _deviceWidth;
  HTTPService? _http;
  String? _selectedCoin = 'bitcoin';

  @override
  void initState() {
    _http = GetIt.instance.get<HTTPService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _selectedCoinDropdown(),
            _dataWidget(),
          ],
        ),
      )),
    );
  }

  Widget _selectedCoinDropdown() {
    List<String> _coins = [
      "bitcoin",
      "ethereum",
      "tether",
      "cardano",
      "ripple",
    ];
    List<DropdownMenuItem<String>> _items = _coins
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(
              e,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
        .toList();
    return DropdownButton(
      value: _selectedCoin,
      items: _items,
      onChanged: (dynamic _value) {
        setState(() {
          _selectedCoin = _value;
        });
      },
      dropdownColor: Color.fromARGB(255, 23, 6, 154),
      iconSize: 30,
      icon: const Icon(
        Icons.arrow_drop_down_sharp,
        color: Colors.white,
      ),
      underline: Container(),
    );
  }

  Widget _dataWidget() {
    return FutureBuilder(
        future: _http!.get("/coins/$_selectedCoin"),
        builder: (BuildContext _context, AsyncSnapshot _snapshot) {
          if (_snapshot.hasData) {
            Map _data = jsonDecode(
              _snapshot.data.toString(),
            );
            num _inrPrice = _data["market_data"]["current_price"]["inr"];
            num _change24hr =
                _data["market_data"]["price_change_percentage_24h"];
            Map _exchangeRates = _data["market_data"]["current_price"];
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onDoubleTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext _context) {
                      return DetailsPage(
                        rates: _exchangeRates,
                      );
                    }));
                  },
                  child: _coinImageWidget(_data["image"]["large"]),
                ),
                _currentPriceWidget(_inrPrice),
                _percentChnageWidget(_change24hr),
                _descirptionCardWidget(
                  _data["description"]["en"],
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
        });
  }

  Widget _currentPriceWidget(num _rate) {
    return Text(
      "INR ${_rate.toStringAsFixed(2)}",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _percentChnageWidget(num _change) {
    return Text(
      "change in last 24hrs:   '${_change.toString()}%'",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _coinImageWidget(String _imgURL) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _deviceHeight! * 0.02,
      ),
      height: _deviceHeight! * 0.20,
      width: _deviceWidth! * 0.20,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(_imgURL),
        ),
      ),
    );
  }

  Widget _descirptionCardWidget(String _description) {
    return Container(
      height: _deviceHeight! * 0.45,
      width: _deviceWidth! * 0.85,
      margin: EdgeInsets.symmetric(
        vertical: _deviceHeight! * 0.05,
      ),
      padding: EdgeInsets.symmetric(
        vertical: _deviceHeight! * 0.01,
        horizontal: _deviceWidth! * 0.01,
        // horizontal: _deviceHeight! * 0.01,
      ),
      color: const Color.fromRGBO(83, 88, 206, 0.5),
      child: ListView(
        children: [
          Text(
            _description,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
