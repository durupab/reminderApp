import 'package:app1/models/plan.dart';

import 'package:flutter/material.dart';


class PlanItem extends StatefulWidget{

  const PlanItem({super.key,
  required this.plan,
  required this.onRemove,
  required this.onEdit} );

  
  final Plan plan;
  final void Function() onRemove;
  final void Function() onEdit;

  
  @override
  State<PlanItem> createState() {
    return _PlanItemState();
  }
}

class _PlanItemState extends State<PlanItem>{
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    
    return Expanded(
      child: Row(children: [
              Checkbox(
                value: isChecked,
                onChanged: (newValue) {
                    setState(() {
                       isChecked = newValue ?? false;
                    });
                       },
                activeColor:const Color(0xFF1B5E20),
              ),
              Expanded(
                child: Card(
                color: const Color(0xFFA5D6A7) ,
                shape:  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                  ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.plan.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              Row(
                              children: [
                                Center(child: urgencyIcons[widget.plan.urgency]),
                                const SizedBox(width: 8,),
                                Text(widget.plan.formattedDate),
                            ],
                          ),
                            ],
                          ),
                          const SizedBox(height: 4,),
                          Row(
                            children: [
                              Text(
                                widget.plan.notes,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                ),  
                              ),
                              const Spacer(),
                              IconButton(onPressed:
                               widget.onRemove
                              , icon: const Icon(Icons.delete)),
                              IconButton(onPressed: widget.onEdit, icon: const Icon(Icons.edit))
                            ],
                          ),
                          
                  
                        ],
                            
                      ),
                    ),
                  
                  
                  
                  ),
                  
                          ),
              ),
              
            ],
          ),
    ) 
    ;
  }

}