import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/item.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Item>> futureItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureItems = apiService.fetchItems();
  }

  void _refreshItems(String query) {
    setState(() {
      futureItems = query.trim().isEmpty
          ? apiService.fetchItems()
          : apiService.searchItems(query);
    });
  }

  void _openItemDialog({Item? item}) {
    final nameCtrl = TextEditingController(text: item?.itemname ?? '');
    final descCtrl = TextEditingController(text: item?.itemdescription ?? '');
    final valueCtrl = TextEditingController(text: item?.itemvalue.toString() ?? '');
    final imageCtrl = TextEditingController(text: item?.itemimage ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF212121),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            item == null ? 'Add Item' : 'Update Item',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameCtrl, 'Item Name'),
                const SizedBox(height: 12),
                _buildTextField(descCtrl, 'Description'),
                const SizedBox(height: 12),
                _buildTextField(valueCtrl, 'Value', isNumber: true),
                const SizedBox(height: 12),
                _buildTextField(imageCtrl, 'Image URL'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newItem = Item(
                  itemId: item?.itemId ?? 0,
                  itemname: nameCtrl.text,
                  itemdescription: descCtrl.text,
                  itemvalue: double.tryParse(valueCtrl.text) ?? 0.0,
                  itemimage: imageCtrl.text,
                );

                if (item == null) {
                  await apiService.createItem(newItem);
                } else {
                  await apiService.updateItem(newItem);
                }

                if (context.mounted) Navigator.pop(context);
                _refreshItems(searchController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(item == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      maxLines: 1,
      textInputAction: TextInputAction.done,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'My Collection',
          style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50), size: 28),
            onPressed: () => _openItemDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search your items...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) => _refreshItems(value),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Item>>(
              future: futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading items', style: TextStyle(color: Colors.redAccent)));
                }

                final itemList = snapshot.data ?? [];
                if (itemList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 72, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No items found', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.builder(
                    itemCount: itemList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85, // Adjusted aspect ratio
                    ),
                    itemBuilder: (context, index) {
                      final item = itemList[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Image section with price overlay
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: item.itemimage.isNotEmpty
                                        ? Image.network(
                                      item.itemimage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFF2C2C2C),
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.white38,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                        : Container(
                                      color: const Color(0xFF2C2C2C),
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white38,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  // Price tag
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '\$${item.itemvalue.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Color(0xFF4CAF50),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Item info section
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Item name
                                  Expanded(
                                    child: Text(
                                      item.itemname,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Action buttons
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => _openItemDialog(item: item),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.white70,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () async {
                                          await apiService.deleteItem(item.itemId);
                                          _refreshItems(searchController.text);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}