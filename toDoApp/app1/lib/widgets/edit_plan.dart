
/*

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app1/models/plan.dart';

class EditPlan extends StatefulWidget{

const EditPlan({
   required this.editingPlan,
  super.key});

final Plan editingPlan;

@override
  State<EditPlan> createState() {
    return _EditPlanState();
  }
}

class _EditPlanState extends State<EditPlan>{
  List<Plan> _plans = [];
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;
  late String _enteredTitle;
  late String _enteredNotes;
  late Urgency _selectedUrgency;
  late DateTime _enteredDate;

  @override
  void initState() {
    super.initState();
    // Initialize the form fields with the existing plan's data
    _enteredTitle = widget.editingPlan.title;
    _enteredNotes = widget.editingPlan.notes;
    _selectedUrgency = widget.editingPlan.urgency;
    _enteredDate = widget.editingPlan.date;
  }

  void _datePicker() async{
    final firstDate = DateTime.now();
    final lastDate = await showDatePicker(
      context: context, 
      initialDate: firstDate, 
      firstDate: DateTime(2023, 7, 20), // Example: Set the first allowed date
      lastDate: DateTime(2026, 1, 18), );
      setState(() {
        _enteredDate = lastDate!;
      });
  }
    void _removePlan(Plan plan) async{
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to delete this plan?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              setState(() {
                _plans.remove(plan); // Remove the plan from the list
              });
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );  
    final index = _plans.indexOf(plan);
    final url = Uri.https('flutter-c64cf-default-rtdb.firebaseio.com','plans.json');
    final response = await http.delete(url);
    if(response.statusCode >= 400){
      setState(() {
        _plans.insert(index, plan);
      });
    }
  }

  void _saveEditedPlan(Plan plan) async {
    _removePlan(plan);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https('flutter-c64cf-default-rtdb.firebaseio.com', 'plans.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': _enteredTitle,
          'urgency': _selectedUrgency.toString().split('.').last,
          'notes': _enteredNotes,
          'date': _enteredDate.toIso8601String(),
        }),
      );

      final Map<String, dynamic> resData = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(
        Plan(
          id: resData['name'],
          title: _enteredTitle,
          urgency: _selectedUrgency,
          notes: _enteredNotes,
          date: _enteredDate,
        ),
      );
    }
  }

  String transformUrgencyName(String name) {
    if (name.contains('m')) {
      return 'MEDIUM URGENCY';
    } 
    else if(name.contains('o')){
      return 'NOT URGENT';
    }
    else {
      return name.toUpperCase();
    }
  }


  @override
  Widget build(BuildContext context) {
    const double edgeDouble = 20;
    return MaterialApp(
       home: Scaffold(
        body:Expanded(
        child: Padding(
           padding: EdgeInsets.only(left:10 ,right: 10 ,top:60 ,),
          child: Expanded(
            child: Form(
              autovalidateMode: AutovalidateMode.always,
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextFormField(
                    onSaved: (newValue) {
                      _enteredTitle = newValue!;
                    },
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text(
                        'Title',
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Title can\'t be empty';
                      }
                      return null;
                    },
                  ),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          formatter.format(_enteredDate),
                              style: const TextStyle(
                                color : Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold
                              ),
                        ),
                        IconButton(
                          onPressed: _datePicker,
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(width: 30,),
                        Expanded(
                          child: DropdownButton(
                            value: _selectedUrgency,
                            items: Urgency.values
                                .map(
                                  (urgency) => DropdownMenuItem(
                                    value: urgency,
                                    child: Text(
                                      transformUrgencyName(urgency.name),
                                      
                                      style: const TextStyle(
                                        color: Color(0xFF1B5E20),
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedUrgency = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                     
                        TextFormField(
                        onSaved: (value) {
                          _enteredNotes = value!;
                        },
                        maxLength: 200,
                        decoration: const InputDecoration(
                          label: Text('Notes',style: TextStyle(
                                color : Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold),)
                        ),
                               ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed:() { _saveEditedPlan(widget.editingPlan);},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:const Color(0xFF1B5E20),
                              
                            ),
                            child: Text(_isSending ? 'Saving' : 'Save Edit',style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),),
                          ),
                          const SizedBox(width: 10,),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:const Color(0xFF1B5E20),
                              
                            ),
                            child: const Text('Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),),
                          ),              
                        ],
                      ),
                    const SizedBox(height: 20,)
                  ],
                
                ),
            ),
          ),
      
          ),
      ),
    ),);
    }
     
}


class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}
*/