import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coolmovies_mobile/providers/movies_provider.dart';
import 'package:coolmovies_mobile/providers/user_auth_provider.dart';

import 'package:coolmovies_mobile/widgets/review_item.dart';

enum MenuOptions { edit, delete }

class ReviewsList extends ConsumerWidget {
  const ReviewsList({
    super.key,
    required this.movieIndex,
  });

  final int movieIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedUser = ref.watch(userAuthProvider);
    final movie = ref.watch(moviesProvider)[movieIndex];
    final otherReviews = movie.reviews.list
        .where((review) =>
            loggedUser.isEmpty || review.reviewer.id != loggedUser['id'])
        .toList();

    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      itemCount: otherReviews.length,
      itemBuilder: ((context, index) {
        final review = otherReviews[index];
        return ReviewItem(
            review: review,
            loggedUser: loggedUser,
            movieIndex: movieIndex,
            reviewIndex: index);
      }),
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }
}
