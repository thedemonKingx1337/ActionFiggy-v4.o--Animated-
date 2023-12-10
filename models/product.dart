import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _revertOld(bool odlValue) {
    isFavorite = odlValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken, String userID) async {
    final String firebaseUrl =
        "https://actionfigshoppyv1-default-rtdb.firebaseio.com/userFavorites/$userID/$id.json?auth=$authToken";
    Uri url = Uri.parse(firebaseUrl);

    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      print(response.statusCode);

      if (response.statusCode >= 400) {
        _revertOld(oldStatus);
      }
    } catch (error) {
      _revertOld(oldStatus);
    }
  }
}
