import 'dart:async';

import 'package:demo_redux/app_state.dart';
import 'package:demo_redux/item.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class OnListChangedAction {
  final List<Item> items;

  OnListChangedAction(this.items);
}

class RequestItemDataEventAction {}

class CancelItemDataEventAction {}

class AddItemAction {
  final Item item;
  final VoidCallback onValue;
  final FutureOr<dynamic> Function(dynamic error) onError;

  AddItemAction({
    this.item,
    this.onValue,
    this.onError,
  });
}

class EditItemAction {
  final Item item;
  final VoidCallback onValue;
  final FutureOr<dynamic> Function(dynamic error) onError;

  EditItemAction({
    this.item,
    this.onValue,
    this.onError,
  });
}

class RemoveItemAction {
  final Item item;
  final VoidCallback onValue;
  final FutureOr<dynamic> Function(dynamic error) onError;

  RemoveItemAction({
    this.item,
    this.onValue,
    this.onError,
  });
}

class ChangeOrderBy {
  final OrderBy orderBy;

  ChangeOrderBy(this.orderBy);
}

final appReducer = combineReducers(<Reducer<AppState>>[
  TypedReducer<AppState, OnListChangedAction>(onListChangeReducer),
  TypedReducer<AppState, ChangeOrderBy>(changeOrderByReducer),
]);

AppState onListChangeReducer(AppState state, OnListChangedAction action) {
  return state.copyWith(items: action.items);
}

AppState changeOrderByReducer(AppState state, ChangeOrderBy action) {
  final comparator = getComparator(action.orderBy);
  final items = new List<Item>.of(state.items)..sort(comparator);
  return state.copyWith(items: items);
}

Comparator<Item> getComparator(OrderBy orderBy) {
  if (orderBy == OrderBy.titleAsc) {
    return (l, r) => l.title.compareTo(r.title);
  }
  if (orderBy == OrderBy.titleDesc) {
    return (l, r) => r.title.compareTo(l.title);
  }
  if (orderBy == OrderBy.timeAsc) {
    return (l, r) => l.time.compareTo(r.time);
  }
  if (orderBy == OrderBy.timeDesc) {
    return (l, r) => r.time.compareTo(l.time);
  }
  throw StateError('State error');
}
