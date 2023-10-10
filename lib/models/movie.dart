import 'package:intl/intl.dart';

import 'package:coolmovies_mobile/models/director.dart';
import 'package:coolmovies_mobile/models/review.dart';
import 'package:coolmovies_mobile/models/user.dart';

final formatter = DateFormat.y();

class Movie {

  final String title;
  final String movieDirectorId;
  final String imgUrl;
  final User userCreator;
  final DateTime releaseDate;
  final Director director;
  final ReviewList reviews;
  final String id;

  Movie.fromJson(Map<String, dynamic> data)
      : title = data['title'],
        movieDirectorId = data['movieDirectorId'],
        imgUrl = data['imgUrl'],
        userCreator = User.fromJson(data['userByUserCreatorId']),
        releaseDate = DateTime.parse(data['releaseDate']),
        director = Director.fromJson(data['movieDirectorByMovieDirectorId']),
        reviews = ReviewList.allReviewsFromJson(data['movieReviewsByMovieId']),
        id = data['id'];

  String get formattedReleaseDate {
    return formatter.format(releaseDate);
  }
}

class MovieList {
  List<Movie> movies;

  MovieList.allMoviesFromJson(Map<String, dynamic> json)
      : movies = (json['allMovies']['nodes'] as List)
            .map((e) => Movie.fromJson(e))
            .toList();
}
