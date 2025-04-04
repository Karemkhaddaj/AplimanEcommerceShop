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

  // Controllers for searching and adding/editing users
  final TextEditingController searchNameController = TextEditingController();
  final TextEditingController searchIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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

  // Show dialog to add new user
  void _showAddUserDialog() {
    // Clear controllers
    nameController.clear();
    usernameController.clear();
    emailController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Add New User',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextFormField(
                controller: nameController,
                labelText: "Name",
                icon: Icons.person,
              ),
              SizedBox(height: 10),
              _buildTextFormField(
                controller: usernameController,
                labelText: "Username",
                icon: Icons.account_circle,
              ),
              SizedBox(height: 10),
              _buildTextFormField(
                controller: emailController,
                labelText: "Email",
                icon: Icons.email,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _addUser,
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // New method to show edit user dialog
  void _showEditUserDialog(User user) {
    // Pre-fill controllers with existing user data
    nameController.text = user.name;
    usernameController.text = user.username;
    emailController.text = user.email;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Edit User',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextFormField(
                controller: nameController,
                labelText: "Name",
                icon: Icons.person,
              ),
              SizedBox(height: 10),
              _buildTextFormField(
                controller: usernameController,
                labelText: "Username",
                icon: Icons.account_circle,
              ),
              SizedBox(height: 10),
              _buildTextFormField(
                controller: emailController,
                labelText: "Email",
                icon: Icons.email,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => _updateUser(user),
              child: Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Build text form field for adding/editing user
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Add user method
  void _addUser() async {
    // Validate inputs
    if (nameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // Create a new User object
      final newUser = User(
        id: 0, // Backend will assign the ID
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
      );

      // Call API to create user
      await apiService.createUser(newUser);

      // Clear text controllers
      nameController.clear();
      usernameController.clear();
      emailController.clear();

      // Close dialog
      Navigator.pop(context);

      // Refresh user list
      fetchAllUsers();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add user: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // New method to update user
  void _updateUser(User existingUser) async {
    // Validate inputs
    if (nameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // Create an updated User object
      final updatedUser = User(
        id: existingUser.id,
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
      );

      // Call API to update user
      await apiService.updateUser(updatedUser);

      // Clear text controllers
      nameController.clear();
      usernameController.clear();
      emailController.clear();

      // Close dialog
      Navigator.pop(context);

      // Refresh user list
      fetchAllUsers();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update user: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
        actions: [
          // Green button to add new user
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.add_circle, color: Colors.green, size: 30),
              onPressed: _showAddUserDialog,
              tooltip: 'Add New User',
            ),
          ),
        ],
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "ID: ${user.id}",
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () => _showEditUserDialog(user),
                              tooltip: 'Edit User',
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