import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

import 'product_details_screen.dart';

class ProductSearchDelegate
    extends SearchDelegate {
  @override
  String get searchFieldLabel =>
      'Search products...';

  @override
  List<Widget>? buildActions(
    BuildContext context,
  ) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(
    BuildContext context,
  ) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new,
        size: 20,
      ),

      onPressed: () =>
          close(context, null),
    );
  }

  @override
  Widget buildResults(
    BuildContext context,
  ) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(
    BuildContext context,
  ) {
    if (query.isEmpty) {
      return const Center(
        child: Text(
          "Search lifestyle items",
        ),
      );
    }

    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<
        List<QuerySnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance
            .collection('products_mens')
            .get(),

        FirebaseFirestore.instance
            .collection('products_womens')
            .get(),

        FirebaseFirestore.instance
            .collection('products_kids')
            .get(),

        FirebaseFirestore.instance
            .collection('products_teens')
            .get(),

        FirebaseFirestore.instance
            .collection('shoes')
            .get(),
      ]),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child:
                CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }

        List<DocumentSnapshot>
            allDocuments = [];

        for (var querySnapshot
            in snapshot.data!) {
          allDocuments.addAll(
            querySnapshot.docs,
          );
        }

        final results =
            allDocuments.where((doc) {
          final name =
              (doc.data()
                          as Map<
                              String,
                              dynamic>)['name']
                      ?.toString()
                      .toLowerCase() ??
                  '';

          return name.contains(
            query.toLowerCase(),
          );
        }).toList();

        if (results.isEmpty) {
          return const Center(
            child: Text(
              "No items match your search",
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,

          itemBuilder: (context, index) {
            var data =
                results[index].data()
                    as Map<String, dynamic>;

            Product product =
                Product.fromFirestore(
              data,
              results[index].id,
            );

            return ListTile(
              leading: ClipRRect(
                borderRadius:
                    BorderRadius.circular(8),

                child: product.image
                        .startsWith('http')
                    ? Image.network(
                        product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              ),

              title: Text(
                product.name,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              subtitle: Text(
                product.price,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailsScreen(
                      product: product,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}