import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CoolMoviesQueries {
  Future<QueryResult<Object?>> query(
      {required BuildContext context,
      required Map<String, dynamic> variables,
      required void Function() exceptionTratative,
      required String query}) async {
    var client = GraphQLProvider.of(context).value;

    final QueryResult result = await client.query(QueryOptions(
        document: gql(query),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly));

    if (result.hasException) {
      exceptionTratative();
    }

    return result;
  }

  Future<QueryResult<Object?>> mutate(
      {required BuildContext context,
      required Map<String, dynamic> variables,
      required void Function() exceptionTratative,
      required String query}) async {
    var client = GraphQLProvider.of(context).value;

    final QueryResult result = await client.mutate(MutationOptions(
      document: gql(query),
      variables: variables,
    ));

    if (result.hasException) {
      print(result.exception.toString());
      exceptionTratative();
    }

    return result;
  }

  String fetchUserByName() {
    return r"""
          query fetchUserByName ($name: String!){
            allUsers(condition: {name: $name}) {
                nodes {
                  name
                  id
                }
            }
          }
          """;
  }

  String createUser() {
    return r"""
          mutation createUser ($name: String!){
            createUser(
              input: {user: {name: $name}}
            ) {
                user {
                  name
                  id
                }
            }
          }
          """;
  }

  String createMovieReview() {
    return r"""
          mutation createMovieReview ($title: String!, $movieId: UUID!, $userReviewerId: UUID!, $rating: Int!, $body: String!){
            createMovieReview(
              input: {movieReview: {title: $title, movieId: $movieId, userReviewerId: $userReviewerId, rating: $rating, body: $body}}
            ) {
                movieReview {
                  body
                  id
                  movieId
                  rating
                  title
                  userReviewerId
                }
            }
          }
          """;
  }

  String updateMovieReviewById() {
    return r"""
          mutation updateMovieReviewById($id: UUID!, $title: String!, $movieId: UUID!, $userReviewerId: UUID!, $rating: Int!, $body: String!){
            updateMovieReviewById(
              input: {movieReviewPatch: {id: $id, body: $body, movieId: $movieId, rating: $rating, title: $title, userReviewerId: $userReviewerId}, id: $id}
            ) {
                movieReview {
                  body
                  id
                  movieId
                  rating
                  title
                  userReviewerId
                }
            }
          }
          """;
  }

  String deleteMovieReviewById() {
    return r"""
          mutation deleteMovieReviewById($id: UUID!){
            deleteMovieReviewById(
              input: {id: $id}
            ) {
              clientMutationId
              deletedMovieReviewId
            }
          }
          """;
  }

  String fetchAllMovies() {
    return r"""
          query AllMovies {
            allMovies {
              nodes {
                id
                imgUrl
                movieDirectorId
                userCreatorId
                title
                releaseDate
                nodeId
                movieDirectorByMovieDirectorId {
                  id
                  name
                  age
                  nodeId
                }
                userByUserCreatorId {
                  id
                  name
                  nodeId
                }
                movieReviewsByMovieId {
                  nodes {
                    id
                    title
                    body
                    rating
                    movieId
                    nodeId
                    userByUserReviewerId {
                      id
                      name
                      nodeId
                    }
                  }
                }
              }
            }
          }
        """;
  }
}
