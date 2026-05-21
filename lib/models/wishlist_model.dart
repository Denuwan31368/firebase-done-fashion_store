import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'product_model.dart';

class WishlistModel extends ChangeNotifier {
  final List<Product> _wishlistItems = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  List<Product> get items => _wishlistItems;

  String get _userId => _auth.currentUser?.uid ?? "guest_user";

  WishlistModel() {
    loadWishlistFromFirebase();

    _auth.authStateChanges().listen((User? user) {
      loadWishlistFromFirebase();
    });
  }

  Future<void> loadWishlistFromFirebase() async {
    try {

      if (_auth.currentUser == null) {
        _wishlistItems.clear();
        notifyListeners();
        return;
      }

      var snapshot = await _firestore
          .collection('wishlists')
          .doc(_userId) 
          .collection('items')
          .get();

      _wishlistItems.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data();
        _wishlistItems.add(Product.fromFirestore(data, doc.id));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading wishlist from Firestore: $e");
    }
  }

  Future<void> toggleWishlist(Product product) async {
    final docRef = _firestore
        .collection('wishlists')
        .doc(_userId)
        .collection('items')
        .doc(product.id);

    if (isFavorite(product)) {
      _wishlistItems.removeWhere((item) => item.id == product.id);
      notifyListeners(); 
      await docRef.delete();
    } else {
      _wishlistItems.add(product);
      notifyListeners(); 
      await docRef.set({
        'name': product.name,
        'price': product.price,
        'image': product.image, 
        'code': product.code,
        'category': product.category,
        'size': product.sizes, 
      });
    }
  }

  bool isFavorite(Product product) {
    return _wishlistItems.any((item) => item.id == product.id);
  }

  Future<void> removeItem(Product product) async {
    _wishlistItems.removeWhere((item) => item.id == product.id);
    notifyListeners(); 
    
    await _firestore
        .collection('wishlists')
        .doc(_userId)
        .collection('items')
        .doc(product.id)
        .delete();
  }
}