import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/httpException.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;

class Products_Provider with ChangeNotifier {
  bool showFavoritesOnly = false;

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Hrll Boy',
    //   description: 'Top-G for sale!',
    //   price: 29000.50,
    //   imageUrl:
    //       'https://i.pinimg.com/564x/af/c7/f7/afc7f7116534c794f63f3f0e3dadec46.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Guy',
    //   description: 'The Might Guy',
    //   price: 10000000,
    //   imageUrl:
    //       'https://i.pinimg.com/564x/dd/9f/be/dd9fbe6b7ffbf4ccc4dc54d8c3eb7264.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'The Tsunade',
    //   description: 'A nice pair of ( . Y  . )  ',
    //   price: 50000.99,
    //   imageUrl:
    //       'https://i.pinimg.com/564x/81/06/0d/81060d34fe85bdebae675c71ee2df6aa.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Itachi',
    //   description: 'The Uchiha Itachi',
    //   price: 8499.99,
    //   imageUrl:
    //       'https://i.pinimg.com/564x/16/21/99/162199ecc7f7df73b5caa4d82562722a.jpg',
    // ),
    // Product(
    //   id: 'p5',
    //   title: 'OWNER',
    //   description: 'Jobless Highly Skilled Young Guy',
    //   price: 666666.66,
    //   imageUrl:
    //       'https://i.pinimg.com/564x/0c/01/d4/0c01d4f1511e34117d55625c67ada8fa.jpg',
    // ),
    // Product(
    //   id: 'p6',
    //   title: 'Madara',
    //   description: 'The Uchiha Madara',
    //   price: 140000.99,
    //   imageUrl:
    //       'https://i.pinimg.com/564x/e8/f6/fe/e8f6fe7410a0e544dc098b6a6942aa31.jpg',
    // ),
    // Product(
    //   id: 'p7',
    //   title: 'Gaara',
    //   description: 'Gaara of the desert',
    //   price: 140000.99,
    //   imageUrl:
    //       'https://i.pinimg.com/564x/b1/c6/37/b1c637f82df125b8bd27dce818c990aa.jpg',
    // ),
  ];

  final String authToken;
  final String userID;

  Products_Provider(this.authToken, this.userID, this._items);

  List<Product> get items {
    // if we use this kind of filtration every screen using provider will have the filter applied products

    // if (showFavoritesOnly) {
    //   return _items.where((element) => element.isFavorite).toList();
    // }

    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items
        .where((product_element) => product_element.isFavorite)
        .toList();
  }

  Product findById(String id) {
    return _items.firstWhere(
        (iterated_productElement) => iterated_productElement.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterUrl_part =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userID" ' : " ";
    final String firebaseUrl =
        'https://actionfigshoppyv1-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterUrl_part';
    Uri url = Uri.parse(firebaseUrl);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final favoriteResponse = await http.get(Uri.parse(
          'https://actionfigshoppyv1-default-rtdb.firebaseio.com/userFavorites/$userID.json?auth=$authToken'));
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> Loaded_products = [];

      extractedData.forEach((IDkey, productData_value) {
        Loaded_products.add(
          Product(
              id: IDkey,
              title: productData_value["title"],
              description: productData_value["description"],
              price: double.parse(productData_value["price"].toString()),
              imageUrl: productData_value["imageUrl"],
              isFavorite:
                  favoriteData == null ? false : favoriteData[IDkey] ?? false),
        );
      });

      //if you want to add the loaded products along with dummy data

      // _items.addAll(Loaded_products.where((newProduct) => !_items.any((existingProduct) => existingProduct.id == newProduct.id)));

      _items = Loaded_products;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

// we dont use this method which effects all the screens

  // void toggleShow_FavoritesOnly() {
  //   showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void toggle_ShowAll() {
  //   showFavoritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> addProduct(Product product) async {
    final String firebaseUrl =
        "https://actionfigshoppyv1-default-rtdb.firebaseio.com/products.json?auth=$authToken";

    Uri url = Uri.parse(firebaseUrl);

    //http() provide a future --> that future is taken by .then() --> then this function gives a future --> this furure is taken and returned as result of addProduct's Futures's return

    // return

    //  bcouse we now use async so don't need to return it manually
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "creatorId": userID
        }),
      );
      print(json.decode(response.body));
      final newProduct = Product(
          id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
      //   .then(
      // (response) {
    } catch (error) {
      print(error);
      throw error;
    }

    // },
    // ).catchError((error) {
    //1st http.post code will work if it's sucess the next then will be executed. If it fails then it will skin the .then and come to the future of .catchEroor and it will executed
    // print(error);
    // now we are throwing the catched error as the result of Future of addProduct if it fails
    // throw error;
    // });
    // return Future.value(); // if we give like this then we will return it too early becouse http is a future object...so return tyhe entire http object

    // _items.insert(0, newProduct);     // alternative method to inserting at the begning
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final String firebaseUrl =
          "https://actionfigshoppyv1-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";

      Uri url = Uri.parse(firebaseUrl);
      await http.patch(
        url,
        body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "imageUrl": newProduct.imageUrl,
          "price": newProduct.price,
          // don't send isFavourite data becouse updating products always reset it
          // "isFavorited": newProduct.isFavorite,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async {
    final String firebaseUrl =
        "https://actionfigshoppyv1-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    Uri url = Uri.parse(firebaseUrl);

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);

    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    print(response.statusCode);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct!);
      notifyListeners();
      throw HttpException("Error! could't delete product!");
    }
    existingProduct = null; //for memmoryClear
  }
}
