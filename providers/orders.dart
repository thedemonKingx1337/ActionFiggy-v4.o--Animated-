import 'dart:convert';
import 'package:flutter/material.dart';
import 'cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orderItems = [];
  List<OrderItem> get orderItems => [..._orderItems];
  final String authToken;
  final String userId;

  Orders(this.authToken, this._orderItems, this.userId);

  Future<void> fetchOrderData() async {
    final String firebaseUrl =
        "https://actionfigshoppyv1-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    Uri url = Uri.parse(firebaseUrl);
    final response = await http.get(url);
    print(json.decode(response.body));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((key_orderId, value_orderData) {
      loadedOrders.add(
        OrderItem(
          id: key_orderId,
          amount: value_orderData["amount"],
          products: (value_orderData["products"] as List<dynamic>)
              .map(
                (item) => CartItem(
                    id: item["id"],
                    title: item["title"],
                    quantity: item["quantity"],
                    price: item["price"]),
              )
              .toList(),
          dateTime: DateTime.parse(value_orderData["dateTime"]),
        ),
      );
    });
    _orderItems = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOders(List<CartItem> cartProducts, double totalAmount) async {
    final String firebaseUrl =
        "https://actionfigshoppyv1-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    Uri url = Uri.parse(firebaseUrl);
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        "amount": totalAmount,
        "dateTime": timeStamp
            .toIso8601String(), // .toIso8601String() uniform String representation of Datetime
        "products": cartProducts
            .map((eachCartProduct) => {
                  //need a map therefor {}
                  "id": eachCartProduct.id,
                  "title": eachCartProduct.title,
                  "quantity": eachCartProduct.quantity,
                  "price": eachCartProduct.price
                })
            .toList()
      }),
    );

    _orderItems.insert(
        0,
        OrderItem(
          id: json.decode(response.body)["name"],
          amount: totalAmount,
          products: cartProducts,
          dateTime: timeStamp,
        ));
    notifyListeners();
  }
}
