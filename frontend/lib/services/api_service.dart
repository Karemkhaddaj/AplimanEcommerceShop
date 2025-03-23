import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/item.dart';
import '../models/invoice.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080';
  //static const String baseUrl = 'http://localhost:8080'; // Adjust if needed

  // Fetch all users
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      print('Failed to load items. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load items');
    }
  }
  Future<void> updateItem(Item item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/item/${item.itemId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()), // ✅ Now correctly converts Item to JSON
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item');
    }
  }

  // Delete item
  Future<void> deleteItem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/item/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }
  // Create item
  Future<void> createItem(Item item) async {
    String jsonBody = jsonEncode(item.toJson());
    print("🔍 JSON Sent: $jsonBody");  // Debugging line

    final response = await http.post(
      Uri.parse('$baseUrl/item'),  // ✅ Use the correct endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );

    print("🔍 Response Code: ${response.statusCode}");
    print("🔍 Response Body: ${response.body}");

    // Accept both 200 and 201 as successful creation
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Item Created Successfully!');
    } else {
      print('❌ Error: ${response.statusCode}');
      print('❌ Response: ${response.body}');
      throw Exception('Failed to create item');
    }
  }
  // Search item by name
  Future<List<Item>> searchItems(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/item/search/$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search items');
    }
  }
 // Creating User
  Future<void> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {  // ✅ Allow 200 & 201
      print('User successfully created!');
      return;
    } else {
      throw Exception('Failed to create user');
    }
  }
  // Searching user by name
  Future<List<User>> searchUsers(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/user/search/$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search users');
    }
  }

  // Update user
  Future<void> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/${user.id}'), // Correct endpoint for updating user
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()), // Converts User object to JSON
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }
// Fetch User by ID
  Future<User> getUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('User not found');
    }
  }

  Future<List<Invoice>> fetchInvoices() async {
    final response = await http.get(Uri.parse('$baseUrl/invoice/all')); // ✅ Correct endpoint

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Invoice.fromJson(json)).toList();
    } else {
      print('Failed to load invoices. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load invoices');
    }
  }
  Future<List<Invoice>> searchInvoicesByCustomer(String customerName) async {
    final response = await http.get(Uri.parse('$baseUrl/invoice/search/$customerName'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Invoice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load invoices for $customerName');
    }
  }
  Future<List<Invoice>> searchInvoicesByUserId(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/invoice/searchbyID/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Invoice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load invoices for user ID: $userId');
    }
  }
  // Create Invoice (POST)
  Future<Invoice?> createInvoice(int userId, List<Map<String, dynamic>> items) async {
    final url = Uri.parse("$baseUrl/invoice/purchase/$userId");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(items),
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(jsonDecode(response.body));
      } else {
        print("Failed to create invoice: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error creating invoice: $e");
      return null;
    }
  }
}