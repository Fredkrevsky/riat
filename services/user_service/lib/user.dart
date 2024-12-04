class User {
  final String userId;
  final String username;
  final String password;
  final String role; // "admin" or "employee"

  User({
    required this.userId,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, Object?> toJson() => <String, Object?>{
        'userId': userId,
        'username': username,
        'password': password,
        'role': role,
      };
}

final Map<String, User> usersById = <String, User>{};

