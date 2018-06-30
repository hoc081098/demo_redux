import 'package:demo_redux/date_time_picker.dart';
import 'package:demo_redux/item.dart';
import 'package:flutter/material.dart';

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
  final _formKey = new GlobalKey<FormState>();

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
            new Form(
              key: _formKey,
              autovalidate: true,
              child: new TextFormField(
                validator: (s) => s.isEmpty ? 'Invalid title' : null,
                autocorrect: true,
                autovalidate: true,
                controller: _titleController,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
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
            final formState = _formKey.currentState;
            if (formState != null && !formState.validate()) {
              return;
            }
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
