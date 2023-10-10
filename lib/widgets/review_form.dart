import 'package:flutter/material.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:coolmovies_mobile/data/queries.dart';
import 'package:coolmovies_mobile/models/movie.dart';
import 'package:coolmovies_mobile/models/review.dart';
import 'package:coolmovies_mobile/providers/movies_provider.dart';
import 'package:coolmovies_mobile/providers/user_auth_provider.dart';

enum FormType { newReview, editReview }

class ReviewForm extends ConsumerStatefulWidget {
  final BuildContext ctx;
  final int movieIndex;
  final int reviewIndex;
  final FormType formType;

  const ReviewForm.newReview({
    super.key,
    required this.ctx,
    required this.movieIndex,
  })  : reviewIndex = -1,
        formType = FormType.newReview;

  const ReviewForm.editReview(
      {super.key,
      required this.ctx,
      required this.movieIndex,
      required this.reviewIndex})
      : formType = FormType.editReview;

  @override
  ConsumerState<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<ReviewForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  double _rating = 5;
  String _title = '';
  String _body = '';
  Movie? movie;
  Review? review;
  Map<String, dynamic>? loggedUser;

  void _createMovieReview(Movie movie, Map<String, dynamic> inputData) async {
    final QueryResult result = await CoolMoviesQueries().mutate(
        context: context,
        query: CoolMoviesQueries().createMovieReview(),
        variables: {
          ...inputData,
          'movieId': movie.id,
          'userReviewerId': loggedUser!['id'],
        },
        exceptionTratative: () {
          throw 'An error occurred. Please try again later.';
        });

    if (result.data != null) {
      final newReview = result.data!['createMovieReview']['movieReview'];
      ref.read(moviesProvider.notifier).setNewReview(
          movieIndex: widget.movieIndex,
          review: Review.fromJson(
              {...newReview, 'userByUserReviewerId': loggedUser!}));
    }
  }

  void _updateMovieReview(Movie movie, Map<String, dynamic> inputData) async {
    final QueryResult result = await CoolMoviesQueries().mutate(
        context: context,
        query: CoolMoviesQueries().updateMovieReviewById(),
        variables: {
          ...inputData,
          'id': movie.reviews.list[widget.reviewIndex].id,
          'movieId': movie.id,
          'userReviewerId': movie.reviews.list[widget.reviewIndex].reviewer.id,
        },
        exceptionTratative: () {
          throw 'An error occurred. Please try again later.';
        });

    if (result.data != null) {
      final updatedReview =
          result.data!['updateMovieReviewById']['movieReview'];
      ref.read(moviesProvider.notifier).updateReview(
          movieIndex: widget.movieIndex,
          reviewIndex: widget.reviewIndex,
          review: Review.fromJson({
            ...updatedReview,
            'userByUserReviewerId':
                movie.reviews.list[widget.reviewIndex].reviewer.toMap
          }));
    }
  }

  void _submitForm() {
    if (!_isSending && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      try {
        if (widget.formType == FormType.newReview) {
          _createMovieReview(movie!, {
            'rating': _rating,
            'title': _title,
            'body': _body,
          });
        }

        if (widget.formType == FormType.editReview) {
          _updateMovieReview(movie!, {
            'rating': _rating,
            'title': _title,
            'body': _body,
          });
        }
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
        _isSending = false;
      });

      Navigator.pop(widget.ctx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNewReviewForm = widget.formType == FormType.newReview;
    final bool isEditReviewForm = widget.formType == FormType.editReview;

    movie = ref.read(moviesProvider)[widget.movieIndex];
    loggedUser = ref.read(userAuthProvider);
    review = isEditReviewForm ? movie!.reviews.list[widget.reviewIndex] : null;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const Text(
            'Rate this movie',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          const Text('Your rating (1-5 stars)'),
          const SizedBox(height: 4.0),
          RatingBar.builder(
            initialRating: isNewReviewForm
                ? _rating.toDouble()
                : review!.rating.toDouble(),
            minRating: 1,
            maxRating: 5,
            direction: Axis.horizontal,
            itemCount: 5,
            itemSize: 40.0,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            initialValue: isNewReviewForm ? "" : review!.title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.trim().length <= 1) {
                return 'Please, insert a title.';
              }
              return null;
            },
            onSaved: (value) {
              _title = value!;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            initialValue: isNewReviewForm ? "" : review!.body,
            decoration: const InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty || value.trim().length <= 1) {
                return 'Please, insert a comment.';
              }
              return null;
            },
            onSaved: (value) {
              _body = value!;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            onPressed: _submitForm,
            icon: const Icon(Icons.send),
            label: Builder(
              builder: (context) {
                if (_isSending) {
                  return isNewReviewForm
                      ? const Text('Sending...')
                      : const Text('Updating...');
                }

                return isNewReviewForm
                    ? const Text('Send Review')
                    : const Text('Update Review');
              },
            ),
          ),
        ],
      ),
    );
  }
}
