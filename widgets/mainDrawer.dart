import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/custom_route_animations.dart';
import '../providers/authentication.dart';
import '../screens/user_productsScreen.dart';
import '../screens/orderScreen.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        AppBar(
          backgroundColor: Color.fromARGB(255, 255, 0, 72),
          centerTitle: true,
          title: Text("wassup Nigg!!"),
          //to make sure that it will not produce a back button in AppBar
          automaticallyImplyLeading: false,
        ),
        Divider(),
        ListTile(
          leading: Icon(FontAwesomeIcons.shoppingBasket),
          title: Text("Shopping menu"),
          // "/" means Home Default
          onTap: () => Navigator.of(context).pushReplacementNamed("/"),
        ),
        Divider(),
        ListTile(
            leading: Icon(FontAwesomeIcons.googlePay),
            title: Text("Orders"),

            // "/" means Home Default
            onTap: () =>
                // Navigator.of(context).pushReplacementNamed(OrderScreen.routName),
                Navigator.of(context).pushReplacement(CustomRouteAnimations(
                  builder: (context) => OrderScreen(),
                ))),
        Divider(),
        ListTile(
          leading: Icon(FontAwesomeIcons.user),
          title: Text("User Products"),

          // "/" means Home Default
          onTap: () =>
              Navigator.of(context).pushNamed(UserProductScreen.routeName),
        ),
        Divider(),
        ListTile(
          leading: Icon(FontAwesomeIcons.signOut),
          title: Text("Logout"),
          onTap: () =>
              Provider.of<Authentication>(context, listen: false).logout(),
        ),
      ]),
    );
  }
}
