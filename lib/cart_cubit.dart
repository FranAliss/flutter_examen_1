import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_examen/cart_state_class.dart';
import 'package:flutter_examen/main.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState([], 0.0));

  void addToCart(Movie movie) {
    final List<Movie> currentCart = state.movies;
    final double currentTotalCost = state.totalCost;
    currentCart.add(movie);

    final double newTotalCost = currentTotalCost + 30.0;

    emit(CartState(List.from(currentCart), newTotalCost));
  }

  void removeFromCart(Movie movie) {
    final List<Movie> currentCart = state.movies;
    final double currentTotalCost = state.totalCost;

    if (currentCart.contains(movie)) {
      currentCart.remove(movie);
      final double newTotalCost = currentTotalCost - 30.0;
      emit(CartState(List.from(currentCart), newTotalCost));
    }
  }
}
