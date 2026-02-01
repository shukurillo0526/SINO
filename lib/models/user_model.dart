class User {
  final String name;
  final String role;
  final String? photoUrl;
  final bool isGuest;

  User({
    required this.name,
    required this.role,
    this.photoUrl,
    this.isGuest = false,
  });

  factory User.guest() {
    return User(name: 'Guest', role: 'Visitor', isGuest: true);
  }
  
  Map<String, dynamic> toMap() {
      return {
          'name': name,
          'role': role,
          'photoUrl': photoUrl,
          'isGuest': isGuest,
      };
  }
}
