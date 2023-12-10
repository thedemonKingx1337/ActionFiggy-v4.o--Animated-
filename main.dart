import 'package:flutter/material.dart';
import 'helpers/custom_route_animations.dart';
import 'screens/splash_screen.dart';
import 'providers/orders.dart';
import 'screens/addEditProduct.dart';
import 'screens/cartScreen.dart';
import 'screens/orderScreen.dart';
import 'screens/user_productsScreen.dart';
import 'providers/cart.dart';
import 'providers/products_provider.dart';
import 'screens/product_details_screen.dart';
import 'package:provider/provider.dart';
import 'screens/product_overview_screen.dart';
import 'providers/authentication.dart';
import 'screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //in main file don't user ChangeNotifierProvider.value method use builder method to avoid bugs
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Authentication()),
          ChangeNotifierProxyProvider<Authentication?, Products_Provider>(
              create: (context) => Products_Provider('', "", []),
              update: (context, Authentication_value, previous) {
                return Products_Provider(
                  Authentication_value!.token ?? '',
                  Authentication_value.userId ?? '',
                  previous == null ? [] : previous.items,
                );
              }),
          ChangeNotifierProvider(create: (context) => Cart()),
          ChangeNotifierProxyProvider<Authentication?, Orders?>(
            create: (context) => Orders("", [], ""),
            update: (context, Auth_value, previousOrders_value) => Orders(
                Auth_value!.token ?? "",
                previousOrders_value == null
                    ? []
                    : previousOrders_value.orderItems,
                Auth_value.userId ?? ""),
          ),
        ],
        child: Consumer<Authentication>(
          builder: (context, auth_value, child) => MaterialApp(
            title: 'DeliMeals',
            theme: ThemeData(
              fontFamily: "Lato",
              primarySwatch: Colors.deepOrange,
              canvasColor: Colors.blueGrey[100],
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionAnimation(),
                TargetPlatform.iOS: CustomPageTransitionAnimation(),
              }),
            ),
            home: auth_value.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth_value.autoLoginMethod(),
                    builder: (context, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routName: (context) => CartScreen(),
              OrderScreen.routName: (context) => OrderScreen(),
              UserProductScreen.routeName: (context) => UserProductScreen(),
              AddEditUserProductScreen.routeName: (context) =>
                  AddEditUserProductScreen(),
            },
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ProductOverviewScreen();
  }
}
