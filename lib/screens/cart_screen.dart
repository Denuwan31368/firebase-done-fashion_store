import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_store/models/cart_model.dart';

import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartModel>(context, listen: false).loadCart();
    });
  }

  String formatCurrency(double amount) => "Rs. ${amount.toStringAsFixed(2)}";

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),

          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,

            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, anim1, anim2) => HomeScreen(),
                  transitionDuration: Duration.zero,
                ),
                (route) => false,
              ),
            ),

            title: const Text(
              "MY CART",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),

            actions: [
              if (cart.cartItems.isNotEmpty)
                TextButton(
                  onPressed: () => cart.clearCart(),
                  child: const Text(
                    "Clear",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          body: cart.cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: cart.cartItems.length,
                        itemBuilder: (context, index) {
                          if (index >= cart.cartItems.length) {
                            return const SizedBox.shrink();
                          }

                          final item = cart.cartItems[index];

                          return _buildCartItemCard(
                            context,
                            cart,
                            item,
                            index,
                          );
                        },
                      ),
                    ),

                    _buildTotalsSection(context, cart),
                  ],
                ),

          bottomNavigationBar: _buildBottomNavBar(context),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartModel cart,
    CartItem item,
    int index,
  ) {
    return Container(
      key: ValueKey(item.product.id + item.selectedSize),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: item.product.image.startsWith('http')
                ? Image.network(
                    item.product.image,
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    item.product.image,
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  item.product.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _buildQtyBtn(
                      Icons.remove,
                      () => cart.decrementQuantity(index),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _buildQtyBtn(
                      Icons.add,
                      () => cart.incrementQuantity(index),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 22,
            ),
            onPressed: () {
              cart.removeItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildTotalsSection(BuildContext context, CartModel cart) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildSummaryRow(
              "Subtotal",
              formatCurrency(cart.subtotal),
            ),
            _buildSummaryRow(
              "Shipping Fee",
              formatCurrency(cart.shippingFee),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 1),
            ),
            _buildSummaryRow(
              "Total Amount",
              formatCurrency(cart.totalAmount),
              isTotal: true,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, '/checkout'),
                child: const Text(
                  "PROCEED TO CHECKOUT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight:
                  isTotal ? FontWeight.w900 : FontWeight.w500,
              color:
                  isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight:
                  isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black38,
      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        Widget? target;

        if (index == 0) {
          target = HomeScreen();
        }
        if (index == 1) {
          target = const WishlistScreen();
        }
        if (index == 2) {
          target = const ProfileScreen();
        }

        if (target != null) {
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a, b) => target!,
              transitionDuration: Duration.zero,
            ),
            (route) => false,
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
          icon: Icon(Icons.shopping_cart),
          label: "Cart",
        ),
      ],
    );
  }
}