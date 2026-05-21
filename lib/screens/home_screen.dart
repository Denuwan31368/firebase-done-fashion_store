import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/wishlist_model.dart';
import 'product_details_screen.dart';
import 'wishlist_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'category_screen.dart';
import 'product_search_delegate.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor =
        Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,

        leading: Builder(
          builder: (context) =>
              IconButton(
            icon: const Icon(
              Icons.notes_rounded,
              color: Colors.black,
              size: 28,
            ),

            onPressed: () =>
                Scaffold.of(context)
                    .openDrawer(),
          ),
        ),

        title: const Text(
          "URBANVIBE",

          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            fontSize: 20,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.black,
            ),

            onPressed: () {
              showSearch(
                context: context,
                delegate:
                    ProductSearchDelegate(),
              );
            },
          ),
        ],
      ),

      drawer: _buildMenuDrawer(
        context,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _buildImageBanner(),

            const Padding(
              padding:
                  EdgeInsets.fromLTRB(
                20,
                25,
                20,
                15,
              ),

              child: Center(
                child: Text(
                  "Shop by Category",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            _buildCategoryList(context),
            const Padding(
              padding:
                  EdgeInsets.fromLTRB(
                20,
                35,
                20,
                15,
              ),
              child: Center(
                child: Text(
                  "New Arrivals",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child:
                  StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore
                    .instance
                    .collection('products')
                    .snapshots(),
                builder:
                    (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Error loading products",
                      ),
                    );
                  }
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }
                  final docs =
                      snapshot.data!.docs;

                  return GridView.builder(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount: docs.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                    ),

                    itemBuilder:
                        (context, index) {
                      var data =
                          docs[index].data()
                              as Map<
                                  String,
                                  dynamic>;

                      Product product =
                          Product
                              .fromFirestore(
                        data,
                        docs[index].id,
                      );

                      return _buildProductCard(
                        context,
                        product,
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "View More Items →",

                  style: TextStyle(
                    color: Colors.black,
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        type:
            BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,
        selectedItemColor:
            Colors.black,
        unselectedItemColor:
            Colors.black54,
        currentIndex: 0,
        showUnselectedLabels: true,

        onTap: (index) {
          if (index == 0) return;
          Widget target;

          if (index == 1) {
            target =
                const WishlistScreen();
          } else if (index == 2) {
            target =
                const ProfileScreen();
          } else {
            target = const CartScreen();
          }

          Navigator.pushAndRemoveUntil(
            context,

            PageRouteBuilder(
              pageBuilder:
                  (
                    context,
                    anim1,
                    anim2,
                  ) => target,

              transitionDuration:
                  Duration.zero,

              reverseTransitionDuration:
                  Duration.zero,
            ),

            (route) => false,
          );
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border,
            ),
            label: "Wishlist",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            label: "Profile",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart_outlined,
            ),
            label: "Cart",
          ),
        ],
      ),
    );
  }

  Widget _buildImageBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      margin:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(25),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/banner.jpg',

              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding:
                  const EdgeInsets.all(
                25,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [
                  const Text(
                    "Style that defines you",

                    style: TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 13,
                      fontStyle:
                          FontStyle.italic,
                    ),
                  ),

                  const Text(
                    "UrbanVibe",

                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  ElevatedButton(
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.red,

                      foregroundColor:
                          Colors.white,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),
                    ),

                    onPressed: () {},

                    child: const Text(
                      "Welcome deal 10% off",

                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
  ) {
    final List<Map<String, dynamic>>
        catData = [
      {
        'name': 'Womens',
        'img':
            'assets/images/category_images/wc.png',
        'collection':
            'products_womens',
      },
      {
        'name': 'Mens',
        'img':
            'assets/images/category_images/mc.png',
        'collection':
            'products_mens',
      },
      {
        'name': 'Kids',
        'img':
            'assets/images/category_images/kc.png',
        'collection':
            'products_kids',
      },
      {
        'name': 'Teens',
        'img':
            'assets/images/category_images/bc.png',
        'collection':
            'products_teens',
      },
      {
        'name': 'Shoes',
        'img':
            'assets/images/category_images/sc.png',
        'collection': 'shoes',
      },
    ];

    return Center(
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: catData.map((
            category,
          ) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryScreen(
                      categoryTitle:
                          category['name']!
                              .toUpperCase(),

                      collectionName:
                          category[
                              'collection']!,
                    ),
                  ),
                );
              },

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                ),

                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          Colors.white,

                      backgroundImage:
                          AssetImage(
                        category['img']!,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      category['name']!,

                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
  ) {
    return Consumer<WishlistModel>(
      builder:
          (
            context,
            wishlist,
            child,
          ) {
        bool isFav =
            wishlist.isFavorite(
          product,
        );

        return GestureDetector(
          onTap: () =>
              Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailsScreen(
                product: product,
              ),
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width:
                          double.infinity,

                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),

                        color:
                            Colors.grey[200],

                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                              0.05,
                            ),

                            blurRadius: 10,

                            offset:
                                const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),

                        child: product.image
                                .startsWith(
                          'http',
                        )
                            ? Image.network(
                                product.image,
                                fit: BoxFit.cover,

                                loadingBuilder:
                                    (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                  if (loadingProgress ==
                                      null) {
                                    return child;
                                  }

                                  return const Center(
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  );
                                },

                                errorBuilder:
                                    (
                                      context,
                                      error,
                                      stackTrace,
                                    ) => const Center(
                                      child: Icon(
                                        Icons
                                            .broken_image,
                                        color: Colors
                                            .grey,
                                      ),
                                    ),
                              )
                            : Image.asset(
                                product.image,
                                fit:
                                    BoxFit.cover,
                              ),
                      ),
                    ),

                    Positioned(
                      top: 10,
                      right: 10,

                      child:
                          GestureDetector(
                        onTap: () =>
                            wishlist
                                .toggleWishlist(
                          product,
                        ),

                        child: Container(
                          padding:
                              const EdgeInsets.all(
                            6,
                          ),

                          decoration:
                              const BoxDecoration(
                            color:
                                Colors.white,
                            shape:
                                BoxShape.circle,
                          ),

                          child: Icon(
                            isFav
                                ? Icons
                                    .favorite
                                : Icons
                                    .favorite_border,

                            color: isFav
                                ? Colors.red
                                : Colors.black,

                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                product.name,

                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 14,
                ),

                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                product.price,

                style: TextStyle(
                  color:
                      Colors.grey[600],
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuDrawer(
    BuildContext context,
  ) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration:
                const BoxDecoration(
              color: Colors.white,
            ),

            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: const [
                  Text(
                    "URBANVIBE",

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: 5,
                    ),
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  Text(
                    "PREMIUM FASHION HUB",

                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          ListTile(
            leading: const Icon(
              Icons.home_outlined,
            ),

            title: const Text(
              "Home",
            ),

            onTap: () =>
                Navigator.pop(context),
          ),

          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
            ),

            title: const Text(
              "Logout",

              style: TextStyle(
                color: Colors.redAccent,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            onTap: () =>
                Navigator
                    .pushReplacementNamed(
              context,
              '/login',
            ),
          ),

          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}