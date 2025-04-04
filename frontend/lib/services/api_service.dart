import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/item.dart';
import '../models/invoice.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080';
  //static const String baseUrl = 'http://localhost:8080';

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
      body: jsonEncode(item.toJson()), // Now correctly converts Item to JSON
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update item');
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/item/$id'));

      if (response.statusCode == 204) {
        return; // Success
      } else if (response.statusCode == 404) {
        throw Exception('Item not found');
      } else if (response.statusCode == 409) {
        throw Exception('Item cannot be deleted (used in orders)');
      } else {
        throw Exception('Failed to delete item (status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  // Create item
  Future<void> createItem(Item item) async {
    String jsonBody = jsonEncode(item.toJson());
    print(" JSON Sent: $jsonBody");  // Debugging line

    final response = await http.post(
      Uri.parse('$baseUrl/item'),
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );

    print(" Response Code: ${response.statusCode}");
    print(" Response Body: ${response.body}");

    // Accept both 200 and 201 as successful creation
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Item Created Successfully!');
    } else {
      print(' Error: ${response.statusCode}');
      print(' Response: ${response.body}');
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
      Uri.parse('$baseUrl/user'), // Sends request to backend endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()), // Convert user to JSON
    );
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');
    //We are handling the response
    if (response.statusCode == 201 || response.statusCode == 200) {  // Allow 200 & 201
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
  // update user
  Future<void> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": user.username,
        "name": user.name,
        "email": user.email
      }),
    );
    if (response.statusCode != 200) {
      print('Failed to update user: ${response.statusCode}');
      print('Response: ${response.body}');
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
    try {
      final response = await http.get(Uri.parse('$baseUrl/invoice/all'));
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('Empty response body');
          return []; // Return empty list instead of throwing an exception
        }
        try {
          List<dynamic> data = jsonDecode(response.body);
          print('Parsed Data: $data');
          return data.map((json) => Invoice.fromJson(json)).toList();
        } catch (e) {
          print('JSON Parsing Error: $e');
          throw Exception('Failed to parse invoices: $e');
        }
      } else {
        print('Failed to load invoices. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load invoices. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Network or other error: $e');
      throw Exception('Failed to load invoices: $e');
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
        headers: {"Content-Type": "application/json"},  //tell the backend we are sending json
        body: jsonEncode(items), //convert item list into json
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(jsonDecode(response.body)); //parsing it into json object
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