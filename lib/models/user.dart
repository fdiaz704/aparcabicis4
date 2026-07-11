/// Perfil del usuario tal y como lo sirve `GET /bootstrap` (specs/04-API.md).
///
/// `email` es el único campo obligatorio; el resto llega del backend y puede
/// venir vacío mientras se trabaja contra fakes.
class User {
  final String? id;
  final String email;
  final String? name;
  final String? phone;

  /// Preferencia del conmutador de notificaciones (RF-6.2).
  final bool notificationsEnabled;

  /// `es` / `ca` / null (null = idioma del sistema).
  final String? locale;

  const User({
    required this.email,
    this.id,
    this.name,
    this.phone,
    this.notificationsEnabled = true,
    this.locale,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    bool? notificationsEnabled,
    String? locale,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'notificationsEnabled': notificationsEnabled,
      'locale': locale,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? true,
      locale: json['locale'] as String?,
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
  String toString() => 'User(email: $email)';
}
