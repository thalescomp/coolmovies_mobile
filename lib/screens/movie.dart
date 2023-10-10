import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coolmovies_mobile/providers/movies_provider.dart';
import 'package:coolmovies_mobile/providers/user_auth_provider.dart';

import 'package:coolmovies_mobile/widgets/movie_detail.dart';
import 'package:coolmovies_mobile/widgets/reviews_list.dart';
import 'package:coolmovies_mobile/widgets/review_item.dart';
import 'package:coolmovies_mobile/widgets/review_form.dart';

class MovieScreen extends ConsumerWidget {
  const MovieScreen({super.key, required this.movieIndex});

  final int movieIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = ref.watch(moviesProvider)[movieIndex];
    final loggedUser = ref.watch(userAuthProvider);
    final myReviewIndex = movie.reviews.list
        .indexWhere((review) => review.reviewer.id == loggedUser['id']);
    final isReviewMade = myReviewIndex >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            onPressed: () {
              if (loggedUser['isLogged']) {
                ref.read(userAuthProvider.notifier).logoutUser();
              } else {
                ref.read(userAuthProvider.notifier).toggleSkipLogin();
              }
              Navigator.of(context).pop();
            },
            icon: Icon(
              loggedUser['isLogged'] ? Icons.exit_to_app : Icons.login,
            ),
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                MovieDetail(movie: movie),
                if (!isReviewMade && loggedUser['isLogged'])
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16)),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: false,
                            context: context,
                            builder: (ctx) {
                              return ReviewForm.newReview(
                                  ctx: context, movieIndex: movieIndex);
                            },
                          );
                        },
                        icon: const Icon(Icons.star),
                        label: const Text('Rate this movie')),
                  ),
                if (isReviewMade)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Your Review',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        ReviewItem(
                            review: movie.reviews.list[myReviewIndex],
                            loggedUser: loggedUser,
                            movieIndex: movieIndex,
                            reviewIndex: myReviewIndex),
                      ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reviews',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ReviewsList(movieIndex: movieIndex),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
