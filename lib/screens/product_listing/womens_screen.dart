import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:fashion_store/models/product_model.dart';
import 'package:fashion_store/models/wishlist_model.dart';

import 'package:fashion_store/screens/product_details_screen.dart';
import 'package:fashion_store/screens/wishlist_screen.dart';
import 'package:fashion_store/screens/cart_screen.dart';
import 'package:fashion_store/screens/profile_screen.dart';
import 'package:fashion_store/screens/home_screen.dart';

class WomensScreen extends StatelessWidget {
  const WomensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: _buildCustomAppBar(context, "WOMENS"),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products_womens')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading products"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final List<DocumentSnapshot> documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(
              child: Text("No products found in Womens section"),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),

                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: documents.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                    ),

                    itemBuilder: (context, index) {
                      var data = documents[index]
                          .data() as Map<String, dynamic>;

                      Product product = Product.fromFirestore(
                        data,
                        documents[index].id,
                      );

                      return _buildProductCard(context, product);
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
  ) {
    return Consumer<WishlistModel>(
      builder: (context, wishlist, child) {
        bool isFav = wishlist.isFavorite(product);

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailsScreen(product: product),
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[100],
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: product.image.startsWith('http')
                            ? Image.network(
                                product.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,

                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                  child: Icon(Icons.broken_image),
                                ),

                                loadingBuilder:
                                    (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  }
                                  return const Center(
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                product.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                      ),
                    ),

                    Positioned(
                      top: 10,
                      right: 10,

                      child: GestureDetector(
                        onTap: () =>
                            wishlist.toggleWishlist(product),

                        child: Container(
                          padding: const EdgeInsets.all(6),

                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            isFav
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                isFav ? Colors.red : Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                product.price,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildCustomAppBar(
    BuildContext context,
    String title,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,

      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 22,
        ),
        onPressed: () => Navigator.pop(context),
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          letterSpacing: 5,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      currentIndex: 0,

      onTap: (index) {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
            (route) => false,
          );
        } else {
          Widget target;

          if (index == 1) {
            target = const WishlistScreen();
          } else if (index == 2) {
            target = const ProfileScreen();
          } else {
            target = const CartScreen();
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => target,
            ),
          );
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: "Wishlist",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: "Cart",
        ),
      ],
    );
  }
}