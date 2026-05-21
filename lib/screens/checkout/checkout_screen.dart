import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/cart_model.dart';
import 'card_details_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String firstName = "";
  String lastName = "";
  String phoneNumber = "";
  String addressLine1 = "";
  String addressLine2 = "";
  String postalCode = "";
  bool isSaveAddress = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('shipping_addresses')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            firstName = data['firstName'] ?? "";
            lastName = data['lastName'] ?? "";
            phoneNumber = data['phone'] ?? "";
            addressLine1 = data['address1'] ?? "";
            addressLine2 = data['address2'] ?? "";
            postalCode = data['postalCode'] ?? "";
          });
        }
      } catch (e) {
        debugPrint("Error loading address: $e");
      }
    }
  }

  void _showEditAddressPopup() {
    final TextEditingController fNameController =
        TextEditingController(text: firstName);
    final TextEditingController lNameController =
        TextEditingController(text: lastName);
    final TextEditingController phoneController =
        TextEditingController(text: phoneNumber);
    final TextEditingController addr1Controller =
        TextEditingController(text: addressLine1);
    final TextEditingController addr2Controller =
        TextEditingController(text: addressLine2);
    final TextEditingController postalController =
        TextEditingController(text: postalCode);

    bool localSaveAddress = isSaveAddress;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Shipping Address",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildTextField(fNameController, "First Name")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(lNameController, "Last Name")),
                  ],
                ),
                _buildTextField(phoneController, "Phone Number",
                    keyboardType: TextInputType.phone),
                _buildTextField(addr1Controller, "Address Line 01"),
                _buildTextField(addr2Controller, "Address Line 02"),
                _buildTextField(postalController, "Postal Code",
                    keyboardType: TextInputType.number),
                CheckboxListTile(
                  title: const Text("Save shipping address",
                      style: TextStyle(fontSize: 14)),
                  value: localSaveAddress,
                  activeColor: Colors.black,
                  onChanged: (val) =>
                      setModalState(() => localSaveAddress = val!),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;

                      setState(() {
                        firstName = fNameController.text.trim();
                        lastName = lNameController.text.trim();
                        phoneNumber = phoneController.text.trim();
                        addressLine1 = addr1Controller.text.trim();
                        addressLine2 = addr2Controller.text.trim();
                        postalCode = postalController.text.trim();
                        isSaveAddress = localSaveAddress;
                      });

                      if (localSaveAddress && user != null) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('shipping_addresses')
                              .doc(user.uid)
                              .set({
                            'firstName': firstName,
                            'lastName': lastName,
                            'phone': phoneNumber,
                            'address1': addressLine1,
                            'address2': addressLine2,
                            'postalCode': postalCode,
                            'email': user.email,
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Address saved successfully")),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }

                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text(
                      "SAVE ADDRESS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "CHECKOUT",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Delivery Address",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            TextButton(
                              onPressed: _showEditAddressPopup,
                              child: const Text(
                                "Edit",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildInfoCard(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 18, color: Colors.black),
                                SizedBox(width: 8),
                                Text("Home",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$firstName $lastName".trim().isEmpty
                                  ? "No name provided"
                                  : "$firstName $lastName",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                            ),
                            Text(
                              phoneNumber.isEmpty
                                  ? "No phone number"
                                  : phoneNumber,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addressLine1.isEmpty && addressLine2.isEmpty
                                  ? "Please add a shipping address"
                                  : "$addressLine1, $addressLine2, $postalCode",
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          "Payment Method",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ),
                      _buildInfoCard(
                        onTap: () =>
                            Navigator.pushNamed(context, '/addCard'),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_card_outlined),
                            ),
                            const SizedBox(width: 15),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Add new card",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text("Visa, Mastercard, etc.",
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right,
                                color: Colors.black26),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildSummarySection(context, cart),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(20),
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
        child: child,
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartModel cart) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
                "Subtotal", "Rs. ${cart.subtotal.toStringAsFixed(2)}"),
            _buildSummaryRow(
                "Shipping", "Rs. ${cart.shippingFee.toStringAsFixed(2)}"),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(thickness: 1),
            ),
            _buildSummaryRow("Total Payment",
                "Rs. ${cart.totalAmount.toStringAsFixed(2)}",
                isTotal: true),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  if (firstName.isEmpty || addressLine1.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Please provide a shipping address first"),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardDetailsScreen(
                        shippingData: {
                          'name': "$firstName $lastName",
                          'phone': phoneNumber,
                          'address':
                              "$addressLine1, $addressLine2",
                          'postalCode': postalCode,
                        },
                      ),
                    ),
                  );
                },
                child: const Text(
                  "PAY NOW",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black : Colors.grey[600],
              fontWeight:
                  isTotal ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              color: Colors.black,
              fontWeight:
                  isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}