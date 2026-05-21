import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fashion_store/models/product_model.dart';
import 'package:fashion_store/models/cart_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  String selectedSize = "";

  @override
  void initState() {
    super.initState();

    if (widget.product.sizes.isNotEmpty) {
      selectedSize =
          widget.product.sizes[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width;

    double imageAreaHeight =
        screenWidth * 1.4;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: Padding(
          padding: const EdgeInsets.all(8.0),

          child: CircleAvatar(
            backgroundColor:
                Colors.white.withOpacity(0.8),

            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 18,
              ),

              onPressed: () =>
                  Navigator.pop(context),
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),

            child: CircleAvatar(
              backgroundColor:
                  Colors.white.withOpacity(0.8),

              child: const Icon(
                Icons.favorite_border,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imageAreaHeight,

            child: Hero(
              tag: widget.product.id,

              child: Container(
                color:
                    const Color(0xFFF5F5F5),

                child: widget.product.image
                        .startsWith('http')
                    ? Image.network(
                        widget.product.image,
                        fit: BoxFit.contain,
                        alignment:
                            Alignment.topCenter,

                        loadingBuilder:
                            (
                              context,
                              child,
                              progress,
                            ) {
                          if (progress ==
                              null) {
                            return child;
                          }

                          return const Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  Colors.black,
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
                                size: 50,
                              ),
                            ),
                      )
                    : Image.asset(
                        widget.product.image,
                        fit: BoxFit.contain,
                        alignment:
                            Alignment.topCenter,
                      ),
              ),
            ),
          ),

          SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),

            child: Column(
              children: [
                SizedBox(
                  height:
                      imageAreaHeight - 40,
                ),

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 30,
                  ),

                  decoration:
                      const BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.only(
                      topLeft:
                          Radius.circular(35),
                      topRight:
                          Radius.circular(35),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.grey[300],

                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  widget
                                      .product.name,

                                  style:
                                      const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  "Product Code: ${widget.product.code}",

                                  style:
                                      TextStyle(
                                    color: Colors
                                        .grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            widget
                                .product.price,

                            style:
                                const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  Colors.redAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.red[50],

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8,
                              ),
                            ),

                            child: const Text(
                              "Sale 10% off",

                              style: TextStyle(
                                color:
                                    Colors.red,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 15,
                          ),

                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 18,
                          ),

                          const Text(
                            " 4.8 ",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const Text(
                            "(120 Reviews)",

                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      const Text(
                        "Description",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        "A modern essential crafted for everyday comfort with a clean, structured fit. Designed for durability and styled for versatility.",

                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      const Text(
                        "Select Size",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Row(
                        children: widget
                            .product.sizes
                            .map((size) {
                          bool isSelected =
                              selectedSize ==
                                  size;

                          return GestureDetector(
                            onTap: () =>
                                setState(
                              () =>
                                  selectedSize =
                                      size,
                            ),

                            child:
                                AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds:
                                    200,
                              ),

                              margin:
                                  const EdgeInsets.only(
                                right: 12,
                              ),

                              width: 50,
                              height: 50,

                              decoration:
                                  BoxDecoration(
                                color: isSelected
                                    ? Colors.black
                                    : Colors
                                        .grey[100],

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),

                                border:
                                    Border.all(
                                  color: isSelected
                                      ? Colors
                                          .black
                                      : Colors
                                          .transparent,
                                ),
                              ),

                              child: Center(
                                child: Text(
                                  size,

                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color: isSelected
                                        ? Colors
                                            .white
                                        : Colors
                                            .black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(
                        height: 40,
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 60,

                        child: ElevatedButton(
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.black,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),
                            ),

                            elevation: 0,
                          ),

                          onPressed: () {
                            Provider.of<CartModel>(
                              context,
                              listen: false,
                            ).addToCart(
                              widget.product,
                              size: selectedSize,
                            );

                            Navigator.pushNamed(
                              context,
                              '/cart',
                            );
                          },

                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              Icon(
                                Icons
                                    .shopping_bag_outlined,
                                color:
                                    Colors.white,
                              ),

                              SizedBox(
                                width: 10,
                              ),

                              Text(
                                "Add to cart",

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}