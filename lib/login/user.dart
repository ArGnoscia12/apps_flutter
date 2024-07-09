class User {
  final String username;
  final String fullname;

  User({required this.username, required this.fullname});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      fullname: json['fullname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullname': fullname,
    };
  }
}
