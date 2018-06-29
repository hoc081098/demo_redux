import 'package:demo_redux/app_state.dart';
import 'package:demo_redux/date_time_picker.dart';
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
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
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

  HomePageViewModel({
    @required this.items,
    @required this.addCallback,
    @required this.editCallback,
    @required this.removeCallback,
    @required this.orderByCallback,
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
                icon: Icon(Icons.sort),
                onPressed: () =>
                    _showSortOrderDialog(viewModel.orderByCallback, context),
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
                    textScaleFactor: 0.8,
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
            child: Icon(Icons.add),
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
                onValue: () => _showMessage('Item added successfully'),
                onError: (e) => _showMessage('Item added error: $e'),
              ),
            );
          },
          editCallback: (item) {
            store.dispatch(
              EditItemAction(
                item: item,
                onValue: () => _showMessage('Item edited successfully'),
                onError: (e) => _showMessage('Item edited error: $e'),
              ),
            );
          },
          removeCallback: (item) {
            store.dispatch(RemoveItemAction(
              item: item,
              onValue: () => _showMessage('Item removed successfully'),
              onError: (e) => _showMessage('Item removed error: $e'),
            ));
          },
          orderByCallback: (OrderBy value) =>
              store.dispatch(ChangeOrderBy(value)),
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
}

class ItemDialog extends StatefulWidget {
  final Item item;
  final String title;

  const ItemDialog({Key key, this.item, this.title}) : super(key: key);

  @override
  _ItemDialogState createState() => new _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  TextEditingController _titleController;
  TextEditingController _contentController;

  DateTime _time;

  @override
  void initState() {
    _titleController =
        new TextEditingController(text: widget.item?.title ?? '');
    _contentController =
        new TextEditingController(text: widget.item?.content ?? '');
    _time = widget.item?.time ?? DateTime.now();
    debugPrint(widget.item.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text(widget.title),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new TextField(
              controller: _titleController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            new TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Content',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
            new DateTimePicker(
              labelText: 'Select time',
              selectedDate: _time,
              selectedTime: new TimeOfDay.fromDateTime(_time),
              selectDate: (selectedDate) {
                _time = selectedDate;
                setState(() {});
              },
              selectTime: (selectedTime) {
                _time = new DateTime(
                  _time.year,
                  _time.month,
                  _time.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                setState(() {});
              },
            )
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        new FlatButton(
          child: new Text('Yes'),
          onPressed: () {
            final item = new Item(
              title: _titleController.text,
              content: _contentController.text,
              time: _time,
              id: widget.item?.id,
            );
            Navigator.of(context).pop(item);
          },
        ),
      ],
    );
  }
}
