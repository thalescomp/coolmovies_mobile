import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:coolmovies_mobile/models/user.dart';

class UserAuthNotifier extends StateNotifier<Map<String, dynamic>> {
  UserAuthNotifier() : super({'isLogged': false, 'isLoginSkipped': false});

  Future<void> uptadeStorage() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'isLogged', value: state['isLogged'].toString());
    await storage.write(key: 'name', value: state['name']);
    await storage.write(key: 'id', value: state['id']);
    await storage.write(
        key: 'isLoginSkipped', value: state['isLoginSkipped'].toString());
  }

  Future<void> deleteStorage() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
  }

  void loginUser(User user) async {
    state = {
      ...state,
      'id': user.id,
      'name': user.name,
      'isLogged': true,
      'isLoginSkipped': false
    };
    await uptadeStorage();
  }

  void logoutUser() async {
    state = {'isLogged': false, 'isLoginSkipped': false};
    await deleteStorage();
  }

  void toggleSkipLogin() async {
    state = {...state, 'isLoginSkipped': !state['isLoginSkipped']};
    await uptadeStorage();
  }
}

final userAuthProvider =
    StateNotifierProvider<UserAuthNotifier, Map<String, dynamic>>(
        (ref) => UserAuthNotifier());
