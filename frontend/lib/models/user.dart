class User {
  final int? id;
  final String username;
  final String name;
  final String email;

  User({
    this.id,
    required this.username,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Can be null
      username: json['username'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'email': email,
    };
  }
}
