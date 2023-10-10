import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:coolmovies_mobile/data/queries.dart';
import 'package:coolmovies_mobile/models/user.dart';
import 'package:coolmovies_mobile/providers/user_auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredFirstname = '';
  var _isAuthenticating = false;

  Future<User> _fetchUser() async {
    final QueryResult result = await CoolMoviesQueries().query(
        context: context,
        query: CoolMoviesQueries().fetchUserByName(),
        variables: {
          'name': _enteredFirstname,
        },
        exceptionTratative: () {
          throw 'An error occurred. Please try again later.';
        });

    if (result.data == null || result.data!['allUsers']['nodes'].isEmpty) {
      throw 'User not found. Please create an account for this user';
    } else {
      User user = User.fromJson(result.data!['allUsers']['nodes'][0]);
      return user;
    }
  }

  Future<User> _createUser() async {
    QueryResult result = await CoolMoviesQueries().query(
        context: context,
        query: CoolMoviesQueries().fetchUserByName(),
        variables: {
          'name': _enteredFirstname,
        },
        exceptionTratative: () {
          throw 'An error occurred. Please try again later.';
        });

    if (result.data != null && !result.data!['allUsers']['nodes'].isEmpty) {
      User user = User.fromJson(result.data!['allUsers']['nodes'][0]);
      if (user.name.toLowerCase() == _enteredFirstname.toLowerCase()) {
        throw 'User already exists. Please, try a different first name.';
      }
    }

    // ignore: use_build_context_synchronously
    result = await CoolMoviesQueries().mutate(
        context: context,
        query: CoolMoviesQueries().createUser(),
        variables: {
          'name': _enteredFirstname,
        },
        exceptionTratative: () {
          throw 'An error occurred. Please try again later.';
        });

    if (result.data != null) {
      User user = User.fromJson(result.data!['createUser']['user']);
      return user;
    } else {
      throw 'An error occurred. Please try again later.';
    }
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isAuthenticating = true;
    });

    try {
      User user;
      if (_isLogin) {
        user = await _fetchUser();
        print('Loguei!');
      } else {
        user = await _createUser();
        print('Criei usuário e loguei!');
      }
      ref.read(userAuthProvider.notifier).loginUser(user);
    } catch (errorMessage) {
      if (errorMessage is String) {
        final errorSnackbar = SnackBar(
          content: Text(errorMessage),
        );
        ScaffoldMessenger.of(context).showSnackBar(errorSnackbar);
      } else {
        print(errorMessage);
      }
    }

    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'CoolMovies',
                    style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'First Name'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter at least 4 characters.';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredFirstname = newValue!;
                              },
                            ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                            const SizedBox(
                              height: 8,
                            ),
                            if (!_isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create an account'
                                      : 'I already have an account')),
                          ],
                        )),
                  ),
                ),
              ),
              TextButton(
                  style: ButtonStyle(),
                  onPressed: () {
                    ref.read(userAuthProvider.notifier).toggleSkipLogin();
                  },
                  child: const Text(
                    'Continue without login',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
