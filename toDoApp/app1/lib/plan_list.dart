import 'dart:convert';

import 'package:app1/widgets/edit_plan.dart';
import 'package:app1/widgets/new_plan.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app1/models/plan.dart';
import 'package:app1/plan_item.dart';

class PlanList extends StatefulWidget {
  const PlanList({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _PlanListState();
  }
}
class _PlanListState extends State<PlanList>{ 
  List<Plan> _plans = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState;
    _loadPlans();
  }

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

  void _editPlan(Plan plan){
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (context) => EditPlan(plan: plan,));
  }

  void _openAddPlan(){
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (context) => const NewPlan(),);
  }

  void _removePlan(Plan plan) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to delete this plan?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              setState(() {
                _plans.remove(plan); // Remove the plan from the list
              });

              final url = Uri.https('flutter-c64cf-default-rtdb.firebaseio.com', 'plans/${plan.id}.json');
              final response = await http.delete(url);
              if (response.statusCode >= 400) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: const Text('An error occurred while deleting the plan.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                setState(() {
                  _plans.insert(_plans.indexOf(plan), plan);
                });
              }
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
}

Future<void> _handleRefresh() async {
  // Fetch updated data from the server or any other data source
  _loadPlans();

  // Set state to trigger a rebuild and show the updated data
  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet'),);
    if(_isLoading){
      content = const Center(child: CircularProgressIndicator(),);
    }
    if(_plans.isNotEmpty){
      content = Container(
      color: const Color.fromARGB(255, 200, 230, 201),
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: _plans.length,
        itemBuilder: (ctx, index) {
          return PlanItem(
            key: ValueKey(_plans[index].id),
            plan: _plans[index],
            onRemove: () {
              // Call onRemovePlan with the plan to remove it from the list
              _removePlan(_plans[index]);
            },
            onEdit: () {
             _editPlan(_plans[index]);
            },
          );
        },
      ),
    );
    }
    if(_error != null){
      content = const Center(child: Text('error'),);
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text('Reminder'),
        actions: [
          IconButton(onPressed: () { _handleRefresh(); }, icon: const Icon(Icons.refresh)),

        ],
          ),
        body:
             Column(
              children: [
                Expanded(child: content),
                ],
              ),
    floatingActionButton: FloatingActionButton(
        onPressed: _openAddPlan,
         // Use the updated icon
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add),
      ),
    );
  }
}