import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService apiService = ApiService();

  // Future to hold fetched users
  late Future<List<User>> futureUsers;

  // Controllers for searching
  final TextEditingController searchNameController = TextEditingController();
  final TextEditingController searchIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially fetch all users
    futureUsers = apiService.fetchUsers();
  }

  // Fetch all users again
  void fetchAllUsers() {
    setState(() {
      futureUsers = apiService.fetchUsers();
    });
  }

  // Search users by name
  void searchByName() {
    final query = searchNameController.text.trim();
    if (query.isEmpty) {
      fetchAllUsers();
    } else {
      setState(() {
        futureUsers = apiService.searchUsers(query);
      });
    }
  }

  // Search user by ID
  void searchById() async {
    final idText = searchIdController.text.trim();
    if (idText.isEmpty) {
      fetchAllUsers();
      return;
    }
    try {
      final id = int.parse(idText);
      final user = await apiService.getUserById(id);
      // If found, show it in a simple dialog
      _showUserDialog(user);
      // Optionally, just fetch all or do nothing
      // fetchAllUsers();
    } catch (_) {
      // If not found or invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not found or invalid ID"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Show user details in a dialog
  void _showUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'User Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow("ID", "${user.id}"),
              _buildInfoRow("Name", user.name),
              _buildInfoRow("Username", user.username),
              _buildInfoRow("Email", user.email),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 2,
        title: Text(
          'Users',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search by Name
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Search by Name",
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => searchByName(),
            ),
          ),
          // Search by ID
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchIdController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Search by ID",
                      labelStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.person_search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (_) => searchById(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: searchById,
                  child: Text("Go"),
                ),
              ],
            ),
          ),
          // List of users
          Expanded(
            child: FutureBuilder<List<User>>(
              future: futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading users",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final userList = snapshot.data!;
                return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    final user = userList[index];
                    return Card(
                      color: Colors.grey[850],
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        onTap: () => _showUserDialog(user),
                        title: Text(
                          user.name,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          user.email,
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          "ID: ${user.id}",
                          style: TextStyle(color: Colors.white70),
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
