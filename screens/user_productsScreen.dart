import 'package:flutter/material.dart';
import 'addEditProduct.dart';
import '../widgets/userProduct_items.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = "/userProductScreen";

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products_Provider>(context, listen: false)
        .fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products_Provider>(context);    //cause a rebuild issue
    print("rebuilding....");

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Products"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(AddEditUserProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products_Provider>(
                      builder: (context, productsData, child) => Padding(
                        padding: EdgeInsets.all(10),
                        child: ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              UserProductItem(
                                  productsData.items[index].id!,
                                  productsData.items[index].title,
                                  productsData.items[index].imageUrl),
                              Divider()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
