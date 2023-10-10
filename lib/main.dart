import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:coolmovies_mobile/models/user.dart';
import 'package:coolmovies_mobile/providers/user_auth_provider.dart';

import 'package:coolmovies_mobile/screens/auth.dart';
import 'package:coolmovies_mobile/screens/movies_list.dart';
import 'package:coolmovies_mobile/screens/splash.dart';

void main() async {
  // We're using HiveStore for persistence,
  // so we need to initialize Hive.
  await initHiveForFlutter();

  final HttpLink httpLink = HttpLink(
    'http://localhost:5001/graphql',
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
  );

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> clientNotifier = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  runApp(GraphQLProvider(
    client: clientNotifier,
    child: const ProviderScope(child: MyApp()),
  ));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _storage = const FlutterSecureStorage();
  bool isAppLaunchedFirstTime = true;

  Future<Map<String, dynamic>?> _loadUserAuthStorage() async {
    final userLoginStorage = await _storage.readAll();

    // mirroring authStorage with authProvider
    if (isAppLaunchedFirstTime && userLoginStorage.isNotEmpty) {
      final provider = ref.watch(userAuthProvider.notifier);
      if (userLoginStorage['isLoginSkipped'] == 'true') {
        provider.toggleSkipLogin();
      }
      if (userLoginStorage['isLogged'] == 'true') {
        provider.loginUser(User.fromJson(userLoginStorage));
      }
      isAppLaunchedFirstTime = false;
    }

    return userLoginStorage;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final userLogin = ref.watch(userAuthProvider);

    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder(
          stream: Stream.fromFuture(_loadUserAuthStorage()),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (snapshot.hasData &&
                (userLogin['isLoginSkipped'] || userLogin['isLogged'])) {
              return const MoviesListScreen();
            }

            return const AuthScreen();
          },
        ));
  }
}
