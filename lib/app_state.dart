import 'package:demo_redux/item.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final List<Item> items;
  final OrderBy orderBy;

  AppState({
    @required this.items,
    @required this.orderBy,
  });

  AppState.initialState()
      : items = <Item>[],
        orderBy = OrderBy.titleAsc;

  AppState copyWith({List<Item> items, OrderBy orderBy}) {
    return AppState(
      items: items ?? this.items,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
