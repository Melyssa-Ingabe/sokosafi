import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Whether the bottom navigation is showing the search box, and which tab
/// to go back to when search closes.
class NavSearchCubit extends Cubit<NavSearchState> {
  NavSearchCubit() : super(const NavSearchState());

  void open({required int returnIndex}) =>
      emit(NavSearchState(isSearching: true, returnIndex: returnIndex));

  void dismiss() => emit(NavSearchState(returnIndex: state.returnIndex));
}

class NavSearchState extends Equatable {
  const NavSearchState({this.isSearching = false, this.returnIndex = 0});

  final bool isSearching;
  final int returnIndex;

  @override
  List<Object> get props => [isSearching, returnIndex];
}
