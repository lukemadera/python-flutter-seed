import 'dart:async';
//import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import './input_checkbox.dart';

class TaggableOpt extends Taggable {
  final String value;
  final String label;
  TaggableOpt({ this.value, this.label, });
  @override
  List<Object> get props => [value];

  ///// Converts the class to json string.
  //String toJson() => '''  {
  //  "name": $name,\n
  //  "position": $position\n
  //}''';
}

class InputFields {
  InputFields._privateConstructor();
  static final InputFields _instance = InputFields._privateConstructor();
  factory InputFields() {
    return _instance;
  }

  Widget inputEmail(var context, var formVals, String formValsKey, { String label = 'Email',
    String hint = 'your@email.com', var fieldKey = null, bool required = false }) {
    return TextFormField(
      key: fieldKey,
      initialValue: (formVals.containsKey(formValsKey)) ? formVals[formValsKey] : '',
      onSaved: (String value) { formVals[formValsKey] = value; },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (required && value.isEmpty) {
          return 'Required';
        } else {
          return validateEmail(value);
        }
      }
    );
  }

  Widget inputPassword(var context, var formVals, String formValsKey, { String label = 'Password',
    int minLen = -1, int maxLen = -1, var fieldKey = null, bool required = false }) {
    return TextFormField(
      key: fieldKey,
      initialValue: (formVals.containsKey(formValsKey)) ? formVals[formValsKey] : '',
      onSaved: (String value) { formVals[formValsKey] = value; },
      decoration: InputDecoration(
        labelText: label,
        //hintText: '',
      ),
      obscureText: true,
      validator: (value) {
        if (required && value.isEmpty) {
          return 'Required';
        } else {
          return validateMinMaxLen(value, minLen, maxLen);
        }
      },
    );
  }

  Widget inputText(var context, var formVals, String formValsKey, { String label = '', String hint = '',
    int minLen = -1, int maxLen = -1, var fieldKey = null, int maxLines = 1, int minLines = 1,
    int debounceChange = -1, Function(String) onChange = null, bool required = false }) {
    //TextEditingController controller;
    Timer debounce;
    return TextFormField(
      key: fieldKey,
      initialValue: (formVals.containsKey(formValsKey)) ? formVals[formValsKey] : '',
      //controller: controller,
      onSaved: (String value) { formVals[formValsKey] = value; },
      //onEditingComplete: () { print ('onEditingComplete ${controller.text}'); },
      onChanged: (String value) {
        if (onChange != null) {
          if (debounceChange > 0) {
            if (debounce?.isActive ?? false) debounce.cancel();
            debounce = Timer(Duration(milliseconds: debounceChange), () {
              formVals[formValsKey] = value;
              onChange(value);
            });
          } else {
            formVals[formValsKey] = value;
            onChange(value);
          }
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: (value) {
        if (required && value.isEmpty) {
          return 'Required';
        } else {
          return validateMinMaxLen(value, minLen, maxLen);
        }
      },
      maxLines: maxLines,
      minLines: minLines,
    );
  }

  Widget inputDateTime(var context, var formVals, String formValsKey, { String label = '', String hint = '',
    String dateTimeMin = '', String dateTimeMax = '', String datetimeFormat = 'yyyy-MM-ddTHH:mm:ss',
    var fieldKey = null, int debounceChange = -1, Function(String) onChange = null, bool required = false }) {

    DateTime now = new DateTime.now();
    DateTime firstDate = now.subtract(new Duration(days: 365 * 5));
    DateTime lastDate = now.add(new Duration(days: 365 * 5));
    if (dateTimeMin != '') {
      firstDate = DateTime.parse(dateTimeMin);
    }
    if (dateTimeMax != '') {
      lastDate = DateTime.parse(dateTimeMax);
    }

    Timer debounce;

    //return InputDatePickerFormField(
    //  key: fieldKey,
    //  initialDate: (formVals.containsKey(formValsKey)) ? DateTime.parse(formVals[formValsKey]) : now,
    //  firstDate: firstDate,
    //  lastDate: lastDate,
    //  //controller: controller,
    //  onDateSaved: (DateTime value) { formVals[formValsKey] = DateFormat(datetimeFormat).format(value); },
    //  //onEditingComplete: () { print ('onEditingComplete ${controller.text}'); },
    //  onDateSubmitted: (DateTime value) {
    //    String valueString = DateFormat(datetimeFormat).format(value);
    //    if (onChange != null) {
    //      if (debounceChange > 0) {
    //        if (debounce?.isActive ?? false) debounce.cancel();
    //        debounce = Timer(Duration(milliseconds: debounceChange), () {
    //          formVals[formValsKey] = valueString;
    //          onChange(valueString);
    //        });
    //      } else {
    //        formVals[formValsKey] = valueString;
    //        onChange(valueString);
    //      }
    //    }
    //  },
    //  fieldLabelText: label,
    //  fieldHintText: hint,
    //  //validator: (value) {
    //  //  if (required && value.isEmpty) {
    //  //    return 'Required';
    //  //  }
    //  //  return null;
    //  //},
    //);

    return TextFormField(
      key: fieldKey,
      initialValue: (formVals.containsKey(formValsKey)) ? formVals[formValsKey] : DateFormat(datetimeFormat).format(now),
      //controller: controller,
      onSaved: (String value) { formVals[formValsKey] = value; },
      //onEditingComplete: () { print ('onEditingComplete ${controller.text}'); },
      onChanged: (String value) {
        if (onChange != null) {
          if (debounceChange > 0) {
            if (debounce?.isActive ?? false) debounce.cancel();
            debounce = Timer(Duration(milliseconds: debounceChange), () {
              formVals[formValsKey] = value;
              onChange(value);
            });
          } else {
            formVals[formValsKey] = value;
            onChange(value);
          }
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: (value) {
        if (required && value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget inputCheckbox(var context, var formVals, String formValsKey, { String label = '',
    var fieldKey = null }) {
    return CheckboxFormField(
      title: Text(label),
      initialValue: (formVals.containsKey(formValsKey)) ? formVals[formValsKey] : false,
      //key: fieldKey,
      onSaved: (bool value) { formVals[formValsKey] = value; },
      validator: (value) {},
    );
  }

  Widget inputSelect(var options, var context, var formVals, String formValsKey, { String label = '',
    String hint = '', var fieldKey = null, bool required = false, onChanged = null }) {
    String value = (formVals.containsKey(formValsKey)) ? formVals[formValsKey] : null;
    return DropdownButtonFormField(
      key: fieldKey,
      value: value,
      onSaved: (String value) { formVals[formValsKey] = value; },
      //hint: Text(hint),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: (value) {
        if (required && value.isEmpty) {
          return 'Please select one';
        }
        return null;
      },
      onChanged: (String newVal) {
        formVals[formValsKey] = newVal;
        if (onChanged != null) {
          onChanged(newVal);
        }
      },
      items: options.map<DropdownMenuItem<String>>((opt) {
        return DropdownMenuItem<String>(
          value: opt['value'],
          child: Text(opt['label']),
        );
      }).toList(),
    );
  }

  Widget inputMultiSelect(var options, var context, var formVals, String formValsKey, { String label = '',
    String hint = '', var fieldKey = null, bool required = false, bool scroll = false }) {
    List<MultiSelectItem<dynamic>> items = options.map<MultiSelectItem<dynamic>>((opt) => MultiSelectItem(opt, opt['label'])).toList();
    var values = [];
    if (formVals.containsKey(formValsKey)) {
      for (var opt in options) {
        if (formVals[formValsKey].contains(opt['value'])) {
          values.add(opt);
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 5),
        Text(label, style: Theme.of(context).textTheme.subtitle1),
        MultiSelectChipField(
          key: fieldKey,
          initialValue: values,
          onSaved: (items) {
            if (items != null) {
              formVals[formValsKey] = items.map((item) => item['value'] ).toList();
            } else {
              formVals[formValsKey] = [];
            }
          },
          validator: (values) {
            if (required && (values == null || values.isEmpty)) {
              return 'Select at least one';
            }
            return null;
          },
          items: items,
          //title: Text(label),
          //headerColor: Colors.transparent,
          showHeader: false,
          decoration: BoxDecoration(
            border: Border.all(width: 0),
          ),
          //icon: Icon(Icons.check),
          //height: 40,
          scroll: scroll,
        ),
        SizedBox(height: 5),
      ]
    );
  }

  //Widget inputMultiSelect(List<Map<String, String>> options, var context, var formVals, String formValsKey, { String label = '',
  //  String hint = '', var fieldKey = null, bool required = false }) {
  //  List<String> emptyVal = [];
  //  if (!formVals.containsKey(formValsKey)) {
  //    formVals[formValsKey] = emptyVal;
  //  }
  //  return MultiSelectFormField(
  //    options: options,
  //    label: label,
  //    formVals: formVals,
  //    formValsKey: formValsKey,
  //    required: required,
  //    context: context,
  //    initialValue: (formVals.containsKey(formValsKey)) ? formVals[formValsKey] : emptyVal,
  //    onSaved: (values) {
  //      if (values != null) {
  //        formVals[formValsKey] = values;
  //      } else {
  //        formVals[formValsKey] = [];
  //      }
  //    },
  //    validator: (values) {
  //      print ('validator ${values}');
  //      if (required && (values == null || values.isEmpty)) {
  //        return 'Select at least one';
  //      }
  //      return null;
  //    },
  //    //buildChip: (Map<String, String> opt, var state) {
  //    //  print ('state ${state} ${opt}');
  //    //  return Padding(
  //    //    padding: EdgeInsets.only(right: 5),
  //    //    child: ChoiceChip(
  //    //      label: Text(opt['label']),
  //    //      backgroundColor: Theme.of(context).accentColor,
  //    //      selectedColor: Theme.of(context).primaryColor,
  //    //      selected: formVals[formValsKey].contains(opt['value']) ? true : false,
  //    //      onSelected: (bool selected) {
  //    //        print ('onSelected ${selected} ${formVals[formValsKey]} ${opt['value']} ${formVals[formValsKey].contains(opt['value'])} ${state}');
  //    //        if (!formVals.containsKey(formValsKey)) {
  //    //          formVals[formValsKey] = [];
  //    //        }
  //    //        if (formVals[formValsKey].contains(opt['value'])) {
  //    //          formVals[formValsKey].remove(opt['value']); 
  //    //        } else {
  //    //          formVals[formValsKey].add(opt['value']);
  //    //        }
  //    //        //setState(() {
  //    //        //  formVals[formValsKey] = formVals[formValsKey];
  //    //        //});
  //    //        print ('onSelected ${selected} ${formVals[formValsKey]} ${formVals[formValsKey].contains(opt['value'])}');
  //    //      },
  //    //    )
  //    //  );
  //    //}
  //  );
  //}

  Widget inputMultiSelectCreate(var options, Future<List<TaggableOpt>> Function(String) onSearch,
    var context, var formVals, String formValsKey, { String label = '',
    String hint = '', var fieldKey = null, bool required = false }) {
    List<TaggableOpt> selectedOpts = [];
    if (formVals.containsKey(formValsKey)) {
      for (var value in formVals[formValsKey]) {
        selectedOpts.add(TaggableOpt(value: value, label: value));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 5),
        FlutterTagging(
          initialItems: selectedOpts,
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
              //border: InputBorder.none,
              //filled: true,
              //fillColor: Colors.green.withAlpha(30),
              hintText: hint,
              labelText: label,
            ),
          ),
          findSuggestions: (String label) {
            label = label.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '').replaceAll(RegExp(r'\s\s+'), ' ');
            String value = label.replaceAll(RegExp(r'[ ]'), '_').toLowerCase();
            return onSearch(value);
          },
          additionCallback: (label) {
            label = label.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '').replaceAll(RegExp(r'\s\s+'), ' ');
            String value = label.replaceAll(RegExp(r'[ ]'), '_').toLowerCase();
            return TaggableOpt( value: value, label: label );
          },
          onAdded: (TaggableOpt opt) {
            return opt;
          },
          configureSuggestion: (opt) {
            return SuggestionConfiguration(
              title: Text(opt.label),
              additionWidget: Chip(
                avatar: Icon(
                  Icons.add_circle,
                  color: Colors.white,
                ),
                label: Text('Create New'),
                labelStyle: TextStyle(
                  color: Colors.white,
                  //fontSize: 14.0,
                  //fontWeight: FontWeight.w300,
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          },
          //wrapConfiguration: WrapConfiguration(
          //  runSpacing: 50,
          //),
          configureChip: (opt) {
            return ChipConfiguration(
              label: Text(opt.label),
              backgroundColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(color: Colors.white),
              deleteIconColor: Colors.white,
              //padding: EdgeInsets.only(bottom: 5, top: 5),
            );
          },
          onChanged: () {
            List<String> values = [];
            if (selectedOpts != null) {
              for (var opt in selectedOpts) {
                values.add(opt.value);
              }
            }
            formVals[formValsKey] = values;
          },
        ),
        SizedBox(height: 5),
      ]
    );
  }
}

String validateEmail(String value) {
  Pattern pattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Invalid email';
  else
    return null;
}

String validateMinMaxLen(String value, int minLen, int maxLen) {
  if (minLen > -1 && value.length < minLen) {
    return 'Min ${minLen} characters';
  } else if (maxLen > -1 && value.length > maxLen) {
    return 'Max ${maxLen} characters';
  }
  return null;
}
