import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:coolmovies_mobile/data/queries.dart';
import 'package:coolmovies_mobile/models/review.dart';
import 'package:coolmovies_mobile/providers/movies_provider.dart';

import 'package:coolmovies_mobile/widgets/review_form.dart';
import 'package:coolmovies_mobile/widgets/reviews_list.dart';

class ReviewItem extends ConsumerWidget {
  const ReviewItem({
    super.key,
    required this.review,
    required this.loggedUser,
    required this.movieIndex,
    required this.reviewIndex,
  });

  final Review review;
  final Map<String, dynamic> loggedUser;
  final int movieIndex;
  final int reviewIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            ...List<Widget>.generate(
                review.rating,
                (idx) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    )),
            ...List<Widget>.generate(
                5 - review.rating,
                (idx) => const Icon(
                      Icons.star_outline,
                      color: Colors.amber,
                    )),
            const SizedBox(
              width: 10,
            ),
            Text(review.title),
            const Spacer(),
            if (loggedUser['name'] == review.reviewer.name &&
                loggedUser['isLogged'])
              SizedBox(
                height: 24,
                child: PopupMenuButton<MenuOptions>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (MenuOptions item) async {
                    if (item == MenuOptions.edit) {
                      showModalBottomSheet(
                        isScrollControlled: false,
                        context: context,
                        builder: (ctx) {
                          return ReviewForm.editReview(
                            ctx: context,
                            movieIndex: movieIndex,
                            reviewIndex: reviewIndex,
                          );
                        },
                      );
                    } else if (item == MenuOptions.delete) {
                      final QueryResult result = await CoolMoviesQueries().mutate(
                          context: context,
                          variables: {'id': review.id},
                          exceptionTratative: () =>
                              throw 'An error occurred. Please try again later.',
                          query: CoolMoviesQueries().deleteMovieReviewById());
                      if (result.data != null) {
                        ref.read(moviesProvider.notifier).deleteReview(
                            movieIndex: movieIndex, reviewIndex: reviewIndex);
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<MenuOptions>>[
                    const PopupMenuItem<MenuOptions>(
                      value: MenuOptions.edit,
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<MenuOptions>(
                      value: MenuOptions.delete,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Text(review.body),
        const SizedBox(
          height: 8,
        ),
        Text(
          'Reviewed by: ${review.reviewer.name}',
          textAlign: TextAlign.left,
          style: const TextStyle(color: Color.fromARGB(255, 87, 87, 87)),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
