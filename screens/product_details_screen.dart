import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-details";
  late String? title;
  late String? id;
  @override
  Widget build(BuildContext context) {
    final routeArguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, String?>?;

    title = routeArguments?["title"];
    id = routeArguments?["id"];

    final productsData = Provider.of<Products_Provider>(context, listen: true);
    // listen: true using this means the change in ProductProvider must be reflected.It can be made false if you dont / only need one time update
    final loadedProduct = productsData.findById(
        id!); //method is hiiden in ProductProvider file  from acessing using productData we rhen call findById

    return Scaffold(
        // appBar: AppBar(title: Text(loadedProduct.title)),
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.grey[300],
          expandedHeight: 450,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(loadedProduct.title),
            background: Hero(
              tag: id!,
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40)),
                  child: Image.network(
                    loadedProduct.imageUrl,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          SizedBox(height: 5),
          Text(
            "₹ ${loadedProduct.price} ",
            style: GoogleFonts.abel(color: Colors.grey[600], fontSize: 40),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.title,
                style: TextStyle(
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              )),
          SizedBox(height: 5),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.description,
                softWrap: true,
                style: GoogleFonts.andika(fontSize: 25, color: Colors.black54),
                textAlign: TextAlign.center,
              )),
        ]))
      ],
    ));
  }
}
