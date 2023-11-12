import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_examen/cart_cubit.dart';
import 'package:flutter_examen/cart_state_class.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class Movie {
  final int id;
  final String title;

  Movie({required this.id, required this.title});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
    );
  }
}

class MovieService {
  static Future<List<Movie>> fetchMovies() async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=fa3e844ce31744388e07fa47c7c5d8c3'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      return data.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Movies no cargaron');
    }
  }
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  final CartCubit cartCubit = CartCubit();

  void showShoppingCart() {
    _navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) {
      return ShoppingCartScreen(cartCubit: cartCubit);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: Scaffold(
        body: BlocProvider(
          create: (context) => cartCubit, // Use the existing CartCubit instance
          child: MovieListScreen(showShoppingCart),
        ),
      ),
    );
  }
}

class MovieListScreen extends StatelessWidget {
  final Function showShoppingCart;

  MovieListScreen(this.showShoppingCart);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peliculas App'),
      ),
      body: MovieList(),
      floatingActionButton: ShoppingCartButton(showShoppingCart),
    );
  }
}

class MovieList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: MovieService.fetchMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final movies = snapshot.data;
          return ListView.builder(
            itemCount: movies!.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                title: Text(movie.title),
                trailing: IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    context.read<CartCubit>().addToCart(movie);
                  },
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ShoppingCartButton extends StatelessWidget {
  final Function showShoppingCart;

  ShoppingCartButton(this.showShoppingCart);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showShoppingCart();
      },
      label: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return Text(
              'Carrito (${state.movies.length}) - Bs ${state.totalCost.toStringAsFixed(2)}');
        },
      ),
      icon: const Icon(Icons.shopping_cart),
    );
  }
}

class ShoppingCartScreen extends StatefulWidget {
  final CartCubit cartCubit;

  ShoppingCartScreen({required this.cartCubit});

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        bloc: widget
            .cartCubit, // Use widget.cartCubit to access the passed instance
        builder: (context, state) {
          final cart = state.movies;
          return ListView.builder(
            itemCount: cart.length,
            itemBuilder: (context, index) {
              final movie = cart[index];
              return ListTile(
                title: Text(movie.title),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_shopping_cart),
                  onPressed: () {
                    widget.cartCubit.removeFromCart(movie);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
