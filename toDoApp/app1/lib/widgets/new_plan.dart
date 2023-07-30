import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app1/models/plan.dart';

class NewPlan extends StatefulWidget{

const NewPlan({
  super.key,});

@override
  State<NewPlan> createState() {
    return _NewPlanState();
  }
}

class _NewPlanState extends State<NewPlan>{
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;
  var _enteredTitle = '';
  var _enteredNotes = '';
  Urgency _selectedUrgency = Urgency.urgent;
  var _enteredDate = DateTime.now();

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

  void _editPlan() {

  }

  void _savePlan() async {
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
                        onPressed: _savePlan,
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



