class User {
  final String email;

  User({
    required this.email,
  });

  User copyWith({
    String? email,
  }) {
    return User(
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;

  @override
  String toString() {
    return 'User(email: $email)';
  }
}
