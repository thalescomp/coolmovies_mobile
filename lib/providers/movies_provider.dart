import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coolmovies_mobile/models/movie.dart';
import 'package:coolmovies_mobile/models/review.dart';

class MoviesNotifier extends StateNotifier<List<Movie>> {
  MoviesNotifier() : super([]);

  void setMovies(List<Movie> movies) {
    state = movies;
  }

  void updateReview(
      {required int movieIndex,
      required int reviewIndex,
      required Review review}) {
    state[movieIndex].reviews.list[reviewIndex] = review;
    state = [...state];
  }

  void deleteReview({
    required int movieIndex,
    required int reviewIndex,
  }) {
    state[movieIndex].reviews.list.removeAt(reviewIndex);
    state = [...state];
  }

  void setNewReview({required int movieIndex, required Review review}) {
    state[movieIndex].reviews.list.add(review);
    state = [...state];
  }
}

final moviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>(
    (ref) => MoviesNotifier());
