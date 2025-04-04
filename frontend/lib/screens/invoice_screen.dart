import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/invoice.dart';

class InvoiceScreen extends StatefulWidget {
  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Invoice>> invoices;

  TextEditingController searchByNameController = TextEditingController();
  TextEditingController searchByIdController = TextEditingController();
  TextEditingController userIdController = TextEditingController();

  List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();
    refreshInvoices();
  }

  void refreshInvoices() {
    setState(() {
      invoices = apiService.fetchInvoices();
    });
  }

  void searchByCustomerName() {
    if (searchByNameController.text.isNotEmpty) {
      setState(() {
        invoices = apiService.searchInvoicesByCustomer(searchByNameController.text);
      });
    } else {
      refreshInvoices();
    }
  }

  void searchByUserId() {
    if (searchByIdController.text.isNotEmpty) {
      setState(() {
        invoices = apiService.searchInvoicesByUserId(int.parse(searchByIdController.text));
      });
    } else {
      refreshInvoices();
    }
  }

  // Format date string to a more readable format
  String formatDate(String dateString) {
    try {
      // Parse the ISO date string
      DateTime date = DateTime.parse(dateString);
      // Format using intl package
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      // Return original if parsing fails
      return dateString;
    }
  }

  void openCreateInvoiceDialog() {
    userIdController.clear();  // Reset user ID field
    selectedItems.clear(); // Clear previously selected items

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Create Invoice"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: userIdController,
                    decoration: InputDecoration(labelText: "User ID"),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedItem = await _selectItemDialog();
                      if (selectedItem != null) {
                        setState(() {
                          selectedItems.add(selectedItem);
                        });
                      }
                    },
                    child: Text("Add Item"),
                  ),
                  SizedBox(height: 10),
                  if (selectedItems.isNotEmpty)
                    Column(
                      children: selectedItems.map((item) {
                        return ListTile(
                          title: Text("Item ID: ${item['item']['itemId']}"),
                          subtitle: Text("Quantity: ${item['quantity']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedItems.remove(item);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    int userId = int.tryParse(userIdController.text) ?? -1;
                    if (userId < 0 || selectedItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please enter User ID and select items."),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    }
                    // Call API to create invoice
                    await apiService.createInvoice(userId, selectedItems);
                    Navigator.pop(context); // Close dialog
                    refreshInvoices();
                  },
                  child: Text("Create Invoice"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _selectItemDialog() async {
    TextEditingController itemIdController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemIdController,
                decoration: InputDecoration(labelText: "Item ID"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                int itemId = int.tryParse(itemIdController.text) ?? -1;
                int quantity = int.tryParse(quantityController.text) ?? -1;

                if (itemId < 0 || quantity < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Invalid Item ID or Quantity"),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                Navigator.pop(
                  context,
                  {
                    "item": {"itemId": itemId},
                    "quantity": quantity,
                  },
                );
              },
              child: Text("Add Item"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Invoices',
          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, size: 30, color: Colors.greenAccent),
            onPressed: openCreateInvoiceDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Inputs
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchByNameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      labelText: "Search by Customer Name",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    style: TextStyle(color: Colors.white),
                    onSubmitted: (value) => searchByCustomerName(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchByIdController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      labelText: "Search by User ID",
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) => searchByUserId(),
                  ),
                ),
              ],
            ),
          ),
          // Invoice List
          Expanded(
            child: FutureBuilder<List<Invoice>>(
              future: invoices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading invoices', style: TextStyle(color: Colors.redAccent, fontSize: 18)));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final invoice = snapshot.data![index];
                    // Format the date for display
                    String formattedDate = formatDate(invoice.purchaseDate);

                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.receipt_long, color: Colors.blueAccent, size: 28),
                                SizedBox(width: 12),
                                Text(
                                    "Invoice #${invoice.id}",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey[700], height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Total:",
                                    style: TextStyle(color: Colors.white70, fontSize: 16)
                                ),
                                Text(
                                    "\$${invoice.totalAmount.toStringAsFixed(2)}",
                                    style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Date:",
                                    style: TextStyle(color: Colors.white70, fontSize: 16)
                                ),
                                Text(
                                    formattedDate,
                                    style: TextStyle(color: Colors.white, fontSize: 16)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}