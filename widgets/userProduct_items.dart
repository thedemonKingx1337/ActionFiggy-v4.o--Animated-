import 'package:flutter/material.dart';
import '../providers/products_provider.dart';
import 'package:provider/provider.dart';
import '../screens/addEditProduct.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String image;

  UserProductItem(this.id, this.title, this.image);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(image)),
      title: Text(title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AddEditUserProductScreen.routeName,
                  arguments: id,
                );
              },
              icon: Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Products_Provider>(context, listen: false)
                      .deleteProduct(id);
                } catch (error) {
                  print(error);
                  print(context);

                  scaffold.showSnackBar(SnackBar(
                      content: Text('$error', textAlign: TextAlign.center)));
                }
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
