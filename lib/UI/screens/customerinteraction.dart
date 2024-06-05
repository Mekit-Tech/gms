import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateInteractionScreen extends StatefulWidget {
  final String garageId;
  final String customerId;

  const CreateInteractionScreen({
    Key? key,
    required this.garageId,
    required this.customerId,
  }) : super(key: key);

  @override
  _CreateInteractionScreenState createState() =>
      _CreateInteractionScreenState();
}

class _CreateInteractionScreenState extends State<CreateInteractionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateTimeController =
      TextEditingController(text: DateTime.now().toString());
  final TextEditingController _odoController = TextEditingController();
  final TextEditingController _customerNoteController = TextEditingController();
  final TextEditingController _additionalProblemsController =
      TextEditingController();
  final TextEditingController _primaryJobController = TextEditingController();

  Future<void> _createInteraction() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('garages')
          .doc(widget.garageId)
          .collection('customers')
          .doc(widget.customerId)
          .collection('jobs') // Updated collection path
          .add({
        'date_time': _dateTimeController.text,
        'current_odo': _odoController.text,
        'customer_note': _customerNoteController.text,
        'additional_problems': _additionalProblemsController.text,
        'primary_job': _primaryJobController.text,
        'status': 'active', // Initialize status as 'active'
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Interaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date & Time',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2015, 8),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      final DateTime combinedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        _dateTimeController.text = combinedDateTime.toString();
                      });
                    }
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the date and time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _odoController,
                decoration: const InputDecoration(labelText: 'Current Odo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the current odo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _customerNoteController,
                decoration: const InputDecoration(labelText: 'Customer Note'),
              ),
              TextFormField(
                controller: _additionalProblemsController,
                decoration: const InputDecoration(
                    labelText: 'Additional Problems / Mechanic Remarks'),
              ),
              TextFormField(
                controller: _primaryJobController,
                decoration: const InputDecoration(labelText: 'Primary Job'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the primary job';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createInteraction,
        label: const Text('Create Interaction',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
