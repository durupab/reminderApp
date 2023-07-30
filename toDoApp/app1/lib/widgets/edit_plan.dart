import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app1/models/plan.dart';

class EditPlan extends StatefulWidget{

const EditPlan({
  required this.plan,
  super.key,});

  final Plan plan;

@override
  State<EditPlan> createState() {
    return _EditPlanState();
  }
}

class _EditPlanState extends State<EditPlan>{
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;
  var _enteredTitle = '';
  var _enteredNotes = '';
  Urgency _selectedUrgency = Urgency.urgent;
  var _enteredDate = DateTime.now() ;
    var _editedTitle = '';
  var _editedNotes = '';
  Urgency _editedUrgency = Urgency.urgent;
  var _editedDate = DateTime.now() ;

    @override
  void initState() {
    super.initState();
    _enteredTitle = widget.plan.title;
    _enteredNotes = widget.plan.notes;
    _selectedUrgency = widget.plan.urgency;
    _enteredDate = widget.plan.date;
    super.initState;
    _loadPlans();
  }

  void _datePicker() async{
    final firstDate = DateTime.now();
    final lastDate = await showDatePicker(
      context: context, 
      initialDate: firstDate, 
      firstDate: DateTime(2023, 7, 20), // Example: Set the first allowed date
      lastDate: DateTime(2026, 1, 18), );
      setState(() {
        _editedDate = lastDate!;
      });
    if (lastDate != null && lastDate != _enteredDate) {
      setState(() {
        _enteredDate = lastDate;
      });
    }
  }
  List<Plan> _plans = [];
  var _isLoading = true;
  String? _error;


void _loadPlans() async {
  final url = Uri.https('flutter-c64cf-default-rtdb.firebaseio.com', 'plans.json');

  final response = await http.get(url);

  if (response.statusCode >= 400) {
    setState(() {
      _error = 'Failed to fetch data.';
    });
  } else if (response.body == 'null') {
    setState(() {
      _plans = []; // Clear the existing plans list when there are no plans in the database
      _isLoading = false;
    });
  } else {
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<Plan> loadedPlans = [];
    for (final entry in listData.entries) {
      final Map<String, dynamic> planData = entry.value;
      final Plan plan = Plan(
        id: entry.key,
        title: planData['title'],
        urgency: _convertStringToUrgency(planData['urgency']),
        notes: planData['notes'],
        date: DateTime.parse(planData['date']),
      );
      loadedPlans.add(plan);
    }
    setState(() {
      _plans = loadedPlans; // Assign the loaded plans to the existing list
      _isLoading = false;
    });
  }
}

Urgency _convertStringToUrgency(String urgencyString) {
  switch (urgencyString) {
    case 'urgent':
      return Urgency.urgent;
    case 'mediumUrgency':
      return Urgency.mediumUrgency;
    case 'notUrgent':
      return Urgency.notUrgent;
    default:
      return Urgency.urgent; // Set a default value in case of invalid data
  }
}


  void _saveEditedPlan(Plan plan) async {
     setState(() {
        _plans.remove(plan);
        
     });   
    final url = Uri.https('flutter-c64cf-default-rtdb.firebaseio.com', 'plans/${plan.id}.json');
        final response = await http.delete(url); // Remove the plan from the list
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
          'title': _editedTitle,
          'urgency': _editedUrgency.toString().split('.').last,
          'notes': _editedNotes,
          'date': _editedDate.toIso8601String(),
        }),
      );

      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }
      //bu kısmı yapamıyor??
      //save eder etmez gelmiyor plan
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
    return Padding(
       padding: EdgeInsets.only(
        left: edgeDouble,
        right: edgeDouble,
        top: edgeDouble,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Expanded(
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               TextFormField(
                initialValue: _enteredTitle,
                onSaved: (newValue) {
                  _editedTitle = newValue!;
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
                      formatter.format(_editedDate),
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
                            _editedUrgency = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                 
                    TextFormField(
                    initialValue: _enteredNotes,
                    onSaved: (value) {
                      _editedNotes = value!;
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
                        onPressed:() {_saveEditedPlan(widget.plan);},             
                        style: ElevatedButton.styleFrom(
                          backgroundColor:const Color(0xFF1B5E20),
                          
                        ),
                        child: Text(_isSending ? 'Saving' : 'Save',style: const TextStyle(
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
    
      );
    }
}



