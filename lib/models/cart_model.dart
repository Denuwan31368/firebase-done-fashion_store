import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_model.dart'; 

class CartItem {
  final Product product;
  int quantity;
  String selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize = "M",
  });
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;
  
  final double _fixedShippingFee = 350.0;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CartModel() {
    loadCart();
    
    _auth.authStateChanges().listen((User? user) {
      loadCart();
    });
  }

  CollectionReference get _userCart => _db
      .collection('carts')
      .doc(_auth.currentUser?.uid ?? "guest_user")
      .collection('items');

  Future<void> loadCart() async {
    try {

      if (_auth.currentUser == null) {
        _cartItems.clear();
        notifyListeners();
        return;
      }

      final snapshot = await _userCart.get();
      _cartItems.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _cartItems.add(CartItem(
          product: Product(
            id: data['productId'] ?? '',
            name: data['name'] ?? '',
            price: data['price'] ?? '',
            image: data['image'] ?? '',
            category: data['category'] ?? '', 
            sizes: List<String>.from(data['sizes'] ?? []),
            code: data['code'] ?? 'N/A',
          ),
          quantity: data['quantity'] ?? 1,
          selectedSize: data['selectedSize'] ?? "M",
        ));
      }
      notifyListeners();
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  void addToCart(Product product, {String size = "M"}) async {
    int existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size,
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product, selectedSize: size));
    }
    
    notifyListeners();
    
    await _userCart.doc("${product.id}_$size").set({
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image,
      'sizes': product.sizes,
      'code': product.code,
      'category': product.category, 
      'quantity': existingIndex != -1 ? _cartItems[existingIndex].quantity : 1,
      'selectedSize': size,
    });
  }

  void incrementQuantity(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      final item = _cartItems[index];
      item.quantity++;
      notifyListeners();
      
      await _userCart.doc("${item.product.id}_${item.selectedSize}").update({
        'quantity': item.quantity,
      });
    }
  }

  void decrementQuantity(int index) async {
    if (index >= 0 && index < _cartItems.length) {
      final item = _cartItems[index];
      if (item.quantity > 1) {
        item.quantity--;
        notifyListeners();
        await _userCart.doc("${item.product.id}_${item.selectedSize}").update({
          'quantity': item.quantity,
        });
      } else {
        removeItem(item);
      }
    }
  }

  void removeItem(CartItem item) async {
    String docId = "${item.product.id}_${item.selectedSize}";
    _cartItems.remove(item);
    notifyListeners();
    
    await _userCart.doc(docId).delete();
  }

  void clearCart() async {
    _cartItems.clear();
    notifyListeners();
    
    final snapshots = await _userCart.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  double get subtotal {
    double total = 0.0;
    for (var item in _cartItems) {
      String cleanPrice = item.product.price
          .replaceAll('Rs.', '')
          .replaceAll('Rs', '')
          .replaceAll(',', '')
          .trim();
      double price = double.tryParse(cleanPrice) ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  double get shippingFee => _cartItems.isEmpty ? 0.0 : _fixedShippingFee;
  double get totalAmount => subtotal + shippingFee;
}