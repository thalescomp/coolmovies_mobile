import 'package:flutter/material.dart';

import 'package:coolmovies_mobile/models/movie.dart';

class MovieDetail extends StatelessWidget {
  const MovieDetail({
    super.key,
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Hero(
          tag: movie.id,
          child: Image.network(
            movie.imgUrl,
            height: 200,
            width: 150,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(movie.director.name),
              const SizedBox(height: 10),
              Text(movie.formattedReleaseDate),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    movie.reviews.averageRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Uploaded by: ${movie.userCreator.name}'),
              const SizedBox(height: 20),
            ],
          ),
        )
      ]),
    );
  }
}
