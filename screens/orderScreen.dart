import 'package:flutter/material.dart';
import '../widgets/orderItems.dart' as OrderScreenWidget;
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/mainDrawer.dart';

class OrderScreen extends StatefulWidget {
  static const routName = "/order_page";

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // for optimisation... future work seperatly / will not fetch new orders just becouse something changed in build
  late Future fetch_ordersFuture;

  Future obtainOrders() {
    return Provider.of<Orders>(context, listen: false).fetchOrderData();
  }

  @override
  void initState() {
    fetch_ordersFuture = obtainOrders();
    super.initState();
  }

  // @override
  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context, listen: false);   // this cause an infinate loop...so use a consumer.
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(title: Text("Orders")),
        body: FutureBuilder(
          future: fetch_ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.error != null) {
                return Center(child: Text("Error"));
              } else {
                return Consumer<Orders>(
                  builder: (context, orderData, child) {
                    return ListView.builder(
                        itemCount: orderData.orderItems.length,
                        itemBuilder: (context, index) =>
                            OrderScreenWidget.OrderItems(
                                orderData.orderItems[index]));
                  },
                );
              }
            }
          },
        ));
  }
}
