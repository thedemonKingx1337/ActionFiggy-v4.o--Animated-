import 'package:flutter/material.dart';
// there are 2 class having same name CartItem 1 is in cartItem.dart & other is in cart.dart
//so to avoid the name conflict there are 2 ways

// 1. using of show
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
//here using show we are saying dart that we are only intrested in Cart class so it only impory Cart class from the cart.dart file so that nameconflicts in cartItem -name in class will not be imported
// 2. is using as keyword
import '../widgets/cartItems.dart' as CART;
// now we can use the CART prefix to know from which file you want to use the CartItem
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  static const routName = "/cart_page";
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    final orderData = Provider.of<Orders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      body: Column(children: [
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  SizedBox(width: 10),
                  Chip(
                    label: Text("₹ ${cartData.totalAmount.toStringAsFixed(2)}"),
                    backgroundColor: Colors.cyan,
                  ),
                  OrderButton(cartData: cartData, orderData: orderData)
                ]),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
            child: ListView.builder(
          itemCount: cartData.itemCountInCart,
          itemBuilder: (context, index) {
            // here CartItem is used from cartItems.dart not from cart.dart's provider so CART prefix infront of CartItem is here
            return CART.CartItem(
              cartData.items_in_cart.keys.toList()[index],
              cartData.items_in_cart.values.toList()[index].id,
              cartData.items_in_cart.values.toList()[index].title,
              cartData.items_in_cart.values.toList()[index].quantity,
              cartData.items_in_cart.values.toList()[index].price,
            );
          },
        ))
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    super.key,
    required this.cartData,
    required this.orderData,
  });

  final Cart cartData;
  final Orders orderData;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoadingg = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cartData.totalAmount <= 0 || _isLoadingg)
          ? null
          : () async {
              setState(() {
                _isLoadingg = true;
              });
              await widget.orderData.addOders(
                  widget.cartData.items.values.toList(),
                  widget.cartData.totalAmount);
              setState(() {
                _isLoadingg = false;
              });
              widget.cartData.clearCart();
            },
      child: _isLoadingg
          ? Center(child: CircularProgressIndicator())
          : Text("ORDER NOW",
              style: TextStyle(
                  color: (widget.cartData.totalAmount <= 0 || _isLoadingg)
                      ? Colors.grey
                      : Colors.cyan)),
    );
  }
}
