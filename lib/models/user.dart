class User {
  User({required this.name, required this.id});

  final String name;
  final String id;

  User.fromJson(Map<String, dynamic> data)
      : name = data['name'],
        id = data['id'];

  Map<String, dynamic> get toMap => {
        'name': name,
        'id': id,
      };
}
