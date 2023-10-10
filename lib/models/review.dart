import 'package:coolmovies_mobile/models/user.dart';

class Review {

  final String title;
  final int rating;
  final String body;
  final String movieId;
  final User reviewer;
  final String id;

  Review.fromJson(Map<String, dynamic> data)
      : title = data['title'],
        rating = data['rating'],
        body = data['body'],
        movieId = data['movieId'],
        reviewer = User.fromJson(data['userByUserReviewerId']),
        id = data['id'];
}

class ReviewList {
  final List<Review> list;

  ReviewList.allReviewsFromJson(Map<String, dynamic> json)
      : list =
            (json['nodes'] as List).map((e) => Review.fromJson(e)).toList();

  double get averageRating {
    double totalRating = 0;
    for (var review in list) {
      totalRating += review.rating;
    }
    return totalRating / list.length;
  }
}
