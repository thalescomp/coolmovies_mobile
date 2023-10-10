class Director {
  Director({required this.name, required this.age, required this.id});

  final String name;
  final int age;
  final String id;

  Director.fromJson(Map<String, dynamic> data)
      : name = data['name'],
        age = data['age'],
        id = data['id'];
}
