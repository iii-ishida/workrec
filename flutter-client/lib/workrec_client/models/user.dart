class User {
  final String id;
  final String email;
  final String name;

  const User({required this.id, required this.email, required this.name});

  factory User.create({
    required String id,
    required String email,
    String? name,
  }) =>
      User(id: id, email: email, name: name ?? email);

  User edit({required String name}) => User(id: id, email: email, name: name);
}
