# CoolMovies-Mobile

![Flutter Version](https://img.shields.io/badge/Flutter-2.0+-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-2.12+-blue.svg)

## About the Application

CoolMovies-Mobile is a Flutter application that allows users to browse a list of movies and share their reviews about them. Users can discover popular movies, view details about each film, and read reviews from other users. The application also includes authentication features for a personalized experience.

## Key Features

### Authentication

- **Login/Logout**: Users can log in to their existing accounts or log out to exit the application. It's a 'fake' login (without password), just to explore some features of the app.

- **Navigation without Login**: The application allows users to navigate content without the need to log in. However, some features, such as creating reviews, are available only to authenticated users.

### State Management

- **Riverpod**: We use the global state manager Riverpod to manage the application's state, enabling synchronization with secure storage in the login section.

- **Secure Storage**: Sensitive user login data is securely stored using Secure Storage.

- **Stream Builder**: We implement the Stream Builder to manage the different possible login states and application screens. This provides a seamless and responsive experience for users.

### Movie Reviews

- **Creation, Editing, and Removal of Reviews**: Authenticated users can create, edit, and remove reviews for movies they have watched, allowing them to share their opinions and experiences with other users.

- **Movie Details Viewing**: Users can view complete details of a movie, including the synopsis, cast, and reviews from other users.

- **Star Ratings**: We use the `flutter_rating_bar` library to allow users to view and rate movies with stars, making the rating more intuitive and engaging.

## Getting Started

Follow these steps to run the project on your local machine:

1. **Prerequisites**: Make sure you have Flutter (2.0+) and Dart (2.12+) installed on your system.

2. **Clone the Repository**: Clone this repository to your development environment using the following command:

    ```bash
    git clone https://github.com/your-username/coolmovies-mobile.git
    ```

3. **Install Dependencies**: Navigate to the project directory and run the following command to install all required dependencies:

    ```bash
    flutter pub get
    ```

4. **Explore the Application**: Open the application on your emulator/device and start exploring the list of movies, log in, and try out all the available features.