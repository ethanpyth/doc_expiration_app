// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:flutter/material.dart' hide DateUtils;

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../model/model.dart';
import '../utils/utils.dart';
import '../utils/dbhelper.dart';

const menuDelete = "Delete";
const List<String> menuOptions = <String>[menuDelete];

class DocDetail extends StatefulWidget {
  final Doc? doc;
  final DbHelper dbh = DbHelper();
  DocDetail(Doc document, {Key? key, this.doc}) : super(key: key);

  @override
  State<DocDetail> createState() => _DocDetailState();
}

class _DocDetailState extends State<DocDetail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final int daysAhead = 5475;

  final TextEditingController expirationCtrl = TextEditingController();
  final TextEditingController titleCtrl = TextEditingController();
  final maskFormatter = MaskTextInputFormatter(
      mask: '####-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  bool fqYearCtrl = true;
  bool fqHalfYearCtrl = true;
  bool fqQuarterCtrl = true;
  bool fqMonthCtrl = true;
  bool fqLessMonthCtrl = true;

  @override
  void initState() {
    super.initState();
    _initCtrls();
  }

  @override
  Widget build(BuildContext context) {
    const String cStrDays = "Enter a number of days";
    TextStyle? tStyle = Theme.of(context).textTheme.titleMedium;
    String ttl = widget.doc!.title;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(ttl != "" ? widget.doc!.title : "New Document"),
        actions: (ttl == "")
            ? <Widget>[]
            : <Widget>[
                PopupMenuButton(
                    onSelected: _selectMenu,
                    itemBuilder: (BuildContext context) {
                      return menuOptions.map((String choice) {
                        return PopupMenuItem(
                            value: choice, child: Text(choice));
                      }).toList();
                    })
              ],
      ),
      body: Form(
          key: _formKey,
          // autovalidateMode: true,
          child: SafeArea(
            top: false,
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                TextFormField(
                  inputFormatters: const [
                    //WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]"))
                  ],
                  controller: titleCtrl,
                  style: tStyle,
                  validator: (val) => Val.validateTitle(val!),
                  decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      hintText: 'Enter the document name',
                      labelText: 'Document Name'),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        inputFormatters: [maskFormatter],
                        controller: expirationCtrl,
                        maxLength: 10,
                        decoration: InputDecoration(
                            icon: const Icon(Icons.calendar_today),
                            hintText:
                                'Expiry date (i.e. ${DateUtils.daysAheadAsStr(daysAhead)})',
                            labelText: 'Expiry Date'),
                        keyboardType: TextInputType.number,
                        validator: (val) => DateUtils.isValidate(val!)
                            ? null
                            : 'Not a valid future date',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      tooltip: 'Choose date',
                      onPressed: (() {
                        _chooseDate(context, expirationCtrl.text);
                      }),
                    )
                  ],
                ),
                Row(
                  children: const <Widget>[Expanded(child: Text(' '))],
                ),
                Row(
                  children: <Widget>[
                    const Expanded(child: Text('a: Alert @1.5 & 1 year(s)')),
                    Switch(
                        value: fqYearCtrl,
                        onChanged: (bool value) {
                          setState(() {
                            fqYearCtrl = value;
                          });
                        })
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Expanded(child: Text('b: Alert @ 6 months')),
                    Switch(
                        value: fqHalfYearCtrl,
                        onChanged: (bool value) {
                          setState(() {
                            fqHalfYearCtrl = value;
                          });
                        })
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Expanded(child: Text('b: Alert @ 3 months')),
                    Switch(
                        value: fqQuarterCtrl,
                        onChanged: (bool value) {
                          setState(() {
                            fqQuarterCtrl = value;
                          });
                        })
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Expanded(child: Text('b: Alert @ 1 months or less')),
                    Switch(
                        value: fqMonthCtrl,
                        onChanged: (bool value) {
                          setState(() {
                            fqMonthCtrl = value;
                          });
                        })
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text("Save"),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = DateTime.now();
    var initialDate = DateUtils.convertToDate(initialDateString) ?? now;

    initialDate = (initialDate.year >= now.year && initialDate.isAfter(now)
        ? initialDate
        : now);

    DatePicker.showDatePicker(context, showTitleActions: true,
        onConfirm: (date) {
      setState(() {
        DateTime dt = date;
        String r = DateUtils.ftDateAsStr(dt);
        expirationCtrl.text = r;
      });
    }, currentTime: initialDate);
  }

  void _initCtrls() {
    if (widget.doc != null) {
      titleCtrl.text = widget.doc!.title;
      expirationCtrl.text = widget.doc!.expiration;
    } else {
      titleCtrl.text = "";
      expirationCtrl.text = "";
    }
    fqYearCtrl = widget.doc!.fqYear != null
        ? Val.intToBool(widget.doc!.fqYear)
        : false;
    fqHalfYearCtrl = widget.doc!.fqHalfYear != null
        ? Val.intToBool(widget.doc!.fqHalfYear)
        : false;
    fqQuarterCtrl = widget.doc!.fqQuarter != null
        ? Val.intToBool(widget.doc!.fqQuarter)
        : false;
    fqMonthCtrl = widget.doc!.fqMonth != null
        ? Val.intToBool(widget.doc!.fqMonth)
        : false;
  }

  void _selectMenu(String value) async {
    switch (value) {
      case menuDelete:
        if (widget.doc!.id == -1) {
          return;
        }
        _deleteDoc(widget.doc!.id);
    }
  }

  void _deleteDoc(int id) async {
    int r = await widget.dbh.deleteDoc(widget.doc!.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _saveDoc() {
    widget.doc!.title = titleCtrl.text;
    widget.doc!.expiration = expirationCtrl.text;

    widget.doc!.fqYear = Val.boolToInt(fqYearCtrl);
    widget.doc!.fqHalfYear = Val.boolToInt(fqHalfYearCtrl);
    widget.doc!.fqQuarter = Val.boolToInt(fqQuarterCtrl);
    widget.doc!.fqMonth = Val.boolToInt(fqMonthCtrl);

    if (widget.doc!.id > -1) {
      debugPrint("_update->Doc Id: ${widget.doc!.id.toString()}");
      widget.dbh.updateDoc(widget.doc!);
      Navigator.pop(context, true);
    } else {
      Future<int?> idd = widget.dbh.getMaxId();
      idd.then((result) {
        debugPrint("_insert->Doc Id: ${widget.doc!.id.toString()}");
        widget.doc!.id = (result != null) ? result + 1 : 1;
        widget.dbh.insertDoc(widget.doc!);
        Navigator.pop(context, true);
      });
    }
  }

  void _submitForm() {
    final FormState? form = _formKey.currentState;

    if (!form!.validate()) {
      showMessage('Some data is invalid. Please correct.');
    } else {
      _saveDoc();
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
