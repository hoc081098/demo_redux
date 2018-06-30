import 'package:demo_redux/app_state.dart';
import 'package:demo_redux/edit_add_item_dialog.dart';
import 'package:demo_redux/item.dart';
import 'package:demo_redux/middleware.dart';
import 'package:demo_redux/reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final store = new Store<AppState>(
    appReducer,
    initialState: new AppState.initialState(),
    middleware: createMiddleWares(),
  );

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      child: new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData.dark(),
        home: new MyHomePage(),
      ),
      store: store,
    );
  }
}

@immutable
class HomePageViewModel {
  final List<Item> items;
  final void Function(Item) addCallback;
  final void Function(Item) editCallback;
  final void Function(Item) removeCallback;
  final ValueChanged<OrderBy> orderByCallback;
  final VoidCallback removeAllCallback;

  HomePageViewModel({
    @required this.items,
    @required this.addCallback,
    @required this.editCallback,
    @required this.removeCallback,
    @required this.orderByCallback,
    @required this.removeAllCallback,
  });
}

class MyHomePage extends StatelessWidget {
  final _dateFormat = new DateFormat.yMMMd().add_Hm();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _colors = <Color>[
    Colors.cyan,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.black,
    Colors.teal
  ];

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, HomePageViewModel>(
      onInit: (store) {
        store.dispatch(RequestItemDataEventAction());
        store.dispatch(ChangeOrderBy(OrderBy.titleAsc));
      },
      onDispose: (store) => store.dispatch(CancelItemDataEventAction()),
      builder: (BuildContext context, HomePageViewModel viewModel) {
        return new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: new Text('Demo redux flutter'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Sort order',
                icon: Icon(Icons.sort),
                onPressed: () =>
                    _showSortOrderDialog(viewModel.orderByCallback, context),
              ),
              IconButton(
                tooltip: 'Remove all',
                icon: Icon(Icons.delete_forever),
                onPressed: () =>
                    _showRemoveAllDialog(viewModel.removeAllCallback, context),
              ),
            ],
          ),
          body: new ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final item = viewModel.items[index];
              return new ExpansionTile(
                trailing: new Row(
                  children: <Widget>[
                    new IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditDialog(
                          viewModel.editCallback, context, item),
                    ),
                    new IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        viewModel.removeCallback(item);
                      },
                    ),
                  ],
                ),
                leading: CircleAvatar(
                  child: Text(item.title[0].toUpperCase()),
                  foregroundColor: Colors.white,
                  backgroundColor:
                      _colors[item.title.hashCode % _colors.length],
                ),
                title: ListTile(
                  title: Text(
                    item.title,
                    textScaleFactor: 1.2,
                  ),
                  subtitle: Text(
                    _dateFormat.format(item.time),
                    textScaleFactor: 0.7,
                  ),
                ),
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.content),
                  ),
                ],
              );
            },
            itemCount: viewModel.items.length,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(viewModel.addCallback, context),
            child: Icon(
              Icons.add,
            ),
            tooltip: 'Add new item',
            elevation: 12.0,
          ),
        );
      },
      converter: (Store<AppState> store) {
        return new HomePageViewModel(
          items: store.state.items,
          addCallback: (item) {
            store.dispatch(
              AddItemAction(
                item: item,
                onComplete: () => _showMessage('Item added successfully'),
                onError: (e) => _showMessage('Item added error: $e'),
              ),
            );
          },
          editCallback: (item) {
            store.dispatch(
              EditItemAction(
                item: item,
                onComplete: () => _showMessage('Item edited successfully'),
                onError: (e) => _showMessage('Item edited error: $e'),
              ),
            );
          },
          removeCallback: (item) {
            store.dispatch(RemoveItemAction(
              item: item,
              onComplete: () {
                _scaffoldKey.currentState?.showSnackBar(SnackBar(
                  content: Text('Item removed successfully'),
                  action: new SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      store.dispatch(
                        AddItemAction(
                          item: item,
                          onComplete: () => _showMessage('Undo successfully'),
                          onError: (e) => _showMessage('Undo error: $e'),
                        ),
                      );
                    },
                  ),
                ));
              },
              onError: (e) => _showMessage('Item removed error: $e'),
            ));
          },
          orderByCallback: (OrderBy value) =>
              store.dispatch(ChangeOrderBy(value)),
          removeAllCallback: () => store.dispatch(
                RemoveAllItemAction(
                  onError: (e) => _showMessage('Remove all error: $e'),
                  onComplete: () => _showMessage('Remove all successfully'),
                ),
              ),
        );
      },
    );
  }

  _showMessage(String msg) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(msg)));
  }

  _showAddDialog(void addCallback(Item item), BuildContext context) async {
    final item = await showDialog<Item>(
        context: context,
        builder: (BuildContext context) {
          return new ItemDialog(title: 'Add new item');
        });
    if (item != null) addCallback(item);
  }

  _showEditDialog(
      void editCallback(Item item), BuildContext context, Item item) async {
    final edited = await showDialog<Item>(
        context: context,
        builder: (BuildContext context) {
          return new ItemDialog(
            title: 'Edit item',
            item: item,
          );
        });
    if (edited != null) editCallback(edited);
  }

  _showSortOrderDialog(
      ValueChanged<OrderBy> orderByCallback, BuildContext context) async {
    final orderBy = await showDialog<OrderBy>(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: Text('Select sort order'),
            children: <Widget>[
              new SimpleDialogOption(
                child: Text('Title ascending'),
                onPressed: () =>
                    Navigator.pop<OrderBy>(context, OrderBy.titleAsc),
              ),
              new SimpleDialogOption(
                child: Text('Title descending'),
                onPressed: () =>
                    Navigator.pop<OrderBy>(context, OrderBy.titleDesc),
              ),
              new SimpleDialogOption(
                child: Text('Time ascending'),
                onPressed: () =>
                    Navigator.pop<OrderBy>(context, OrderBy.timeAsc),
              ),
              new SimpleDialogOption(
                child: Text('Time descending'),
                onPressed: () =>
                    Navigator.pop<OrderBy>(context, OrderBy.timeDesc),
              ),
            ],
          );
        });
    orderByCallback(orderBy);
  }

  _showRemoveAllDialog(
      VoidCallback removeAllCallback, BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Remove all items'),
          content: Text(
            "This action can't be undone",
            textScaleFactor: 0.8,
            style: TextStyle(color: Colors.redAccent),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            new FlatButton(
              child: new Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (res) removeAllCallback();
  }
}
