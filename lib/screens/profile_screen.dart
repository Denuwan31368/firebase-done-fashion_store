import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'checkout/order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final User? user =
      FirebaseAuth.instance.currentUser;

  final TextEditingController _editController =
      TextEditingController();

  @override
  void dispose() {
    _editController.dispose();

    super.dispose();
  }

  Future<void> _updateUserData(
    String field,
    String newValue,
  ) async {
    try {
      String dbField = "";

      if (field == "First Name") {
        dbField = "firstName";
      } else if (field == "Last Name") {
        dbField = "lastName";
      } else if (field == "Phone Number") {
        dbField = "phone";
      } else if (field == "Shipping Addresses") {
        dbField = "address";
      } else if (field == "Email Preferences") {
        dbField = "email_pref";
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set(
        {
          dbField: newValue,
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "$field updated successfully!",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FA),

      appBar: AppBar(
        title: const Text(
          "PROFILE",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),

        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),

          onPressed: () =>
              Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(),
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),

            onPressed: () async {
              await FirebaseAuth.instance
                  .signOut();
            },
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          var userData =
              snapshot.data?.data()
                  as Map<String, dynamic>?;

          String fName =
              userData?['firstName'] ??
                  "UrbanVibe";

          String lName =
              userData?['lastName'] ??
                  "Member";

          String phone =
              userData?['phone'] ??
                  "Not set";

          String email =
              user?.email ??
                  "member@urbanvibe.com";

          return SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),

                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor:
                            Color(0xFFEEEEEE),

                        child: Icon(
                          Icons.person,
                          size: 40,
                          color:
                              Colors.black26,
                        ),
                      ),

                      const SizedBox(
                        width: 20,
                      ),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            "$fName $lName",
                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            email,
                            style:
                                const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    10,
                  ),

                  child: Text(
                    "Purchase History",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),

                _buildSectionCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          const Text(
                            "My Orders",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          GestureDetector(
                            onTap: () =>
                                Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const OrderHistoryScreen(),
                              ),
                            ),

                            child: const Text(
                              "View All >",
                              style: TextStyle(
                                color: Colors
                                    .redAccent,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,

                        children: [
                          GestureDetector(
                            onTap: () =>
                                Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const OrderHistoryScreen(),
                              ),
                            ),

                            child:
                                _buildOrderCategory(
                              Icons
                                  .receipt_long_outlined,
                              "Orders",
                            ),
                          ),

                          _buildOrderCategory(
                            Icons
                                .wallet_outlined,
                            "Payment",
                          ),

                          _buildOrderCategory(
                            Icons
                                .star_outline_rounded,
                            "Reviews",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    25,
                    20,
                    10,
                  ),

                  child: Text(
                    "Account Settings",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),

                _buildSectionCard(
                  child: Column(
                    children: [
                      _buildInfoTile(
                        context,
                        "First Name",
                        "Edit",
                        fName,
                      ),

                      const Divider(
                        height: 30,
                        thickness: 0.8,
                      ),

                      _buildInfoTile(
                        context,
                        "Last Name",
                        "Edit",
                        lName,
                      ),

                      const Divider(
                        height: 30,
                        thickness: 0.8,
                      ),

                      _buildInfoTile(
                        context,
                        "Phone Number",
                        "Edit",
                        phone,
                      ),

                      const Divider(
                        height: 30,
                        thickness: 0.8,
                      ),

                      _buildInfoTile(
                        context,
                        "Shipping Addresses",
                        "Edit",
                        userData?['address'] ??
                            "Not set",
                      ),

                      const Divider(
                        height: 30,
                        thickness: 0.8,
                      ),

                      _buildInfoTile(
                        context,
                        "Email Preferences",
                        "Edit",
                        userData?['email_pref'] ??
                            "Enabled",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 2,
        type:
            BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,

        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(),
              ),
            );
          }

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const WishlistScreen(),
              ),
            );
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const CartScreen(),
              ),
            );
          }
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
            icon: Icon(Icons.person),
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

  Widget _buildSectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.03,
            ),
            blurRadius: 15,
          ),
        ],
      ),

      child: child,
    );
  }

  Widget _buildOrderCategory(
    IconData icon,
    String label,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color:
                const Color(0xFFF8F9FA),

            borderRadius:
                BorderRadius.circular(15),
          ),

          child: Icon(
            icon,
            color: Colors.black87,
            size: 26,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String actionText,
    String currentValue,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            Text(
              currentValue,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        GestureDetector(
          onTap: () => _showEditSheet(
            context,
            title,
            currentValue,
          ),

          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: Colors.grey[100],

              borderRadius:
                  BorderRadius.circular(8),
            ),

            child: Text(
              actionText,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditSheet(
    BuildContext context,
    String fieldName,
    String currentVal,
  ) {
    _editController.text =
        currentVal == "Not set"
            ? ""
            : currentVal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),

      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context)
                  .viewInsets
                  .bottom,
          left: 25,
          right: 25,
          top: 25,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Text(
              "Edit $fieldName",
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _editController,
              autofocus: true,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.black,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                onPressed: () {
                  _updateUserData(
                    fieldName,
                    _editController.text,
                  );

                  Navigator.pop(context);
                },

                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}