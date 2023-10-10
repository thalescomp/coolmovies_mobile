import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:coolmovies_mobile/data/queries.dart';
import 'package:coolmovies_mobile/models/movie.dart';
import 'package:coolmovies_mobile/providers/movies_provider.dart';
import 'package:coolmovies_mobile/providers/user_auth_provider.dart';

import 'package:coolmovies_mobile/screens/movie.dart';

class MoviesListScreen extends ConsumerStatefulWidget {
  const MoviesListScreen({super.key});

  @override
  ConsumerState<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends ConsumerState<MoviesListScreen> {
  void _fetchAllMovies() async {
    var client = GraphQLProvider.of(context).value;

    final QueryResult result = await client.query(QueryOptions(
        document: gql(CoolMoviesQueries().fetchAllMovies()),
        fetchPolicy: FetchPolicy.networkOnly));

    if (result.hasException) {
      print(result.exception.toString());
    }

    if (result.data != null) {
      List<Movie> movies = MovieList.allMoviesFromJson(result.data!).movies;
      ref.read(moviesProvider.notifier).setMovies(movies);
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchAllMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = ref.watch(moviesProvider);
    final loggedUser = ref.watch(userAuthProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Cool Movies'),
          actions: [
            IconButton(
              onPressed: () {
                if (loggedUser['isLogged']) {
                  ref.read(userAuthProvider.notifier).logoutUser();
                } else {
                  ref.read(userAuthProvider.notifier).toggleSkipLogin();
                }
              },
              icon: Icon(
                loggedUser['isLogged'] ? Icons.exit_to_app : Icons.login,
              ),
            ),
          ],
        ),
        body: SafeArea(
            child: ListView.separated(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MovieScreen(movieIndex: index)));
              },
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              trailing: Text(movies[index].formattedReleaseDate),
              leading: Hero(
                  tag: movies[index].id,
                  child: Image.network(
                    movies[index].imgUrl,
                    alignment: Alignment.center,
                    height: 200,
                    width: 100,
                    fit: BoxFit.cover,
                  )),
              title: Text(movies[index].title),
            );
          },
          separatorBuilder: (context, index) => const Divider(height: 1),
        )));
  }
}
