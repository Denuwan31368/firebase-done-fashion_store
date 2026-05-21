import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _products = FirebaseFirestore.instance.collection('products');

  // Fetch all products for Home Screen
  Stream<QuerySnapshot> getAllProducts() {
    return _products.snapshots();
  }

  // Fetch products by category
  Stream<QuerySnapshot> getProductsByCategory(String category) {
    return _products.where('category', isEqualTo: category).snapshots();
  }
}