// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, sort_child_properties_last, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class CHWPatient {
  final String name;
  final int age;
  final String gender;
  final String village;
  final String status;

  CHWPatient({
    required this.name,
    required this.age,
    required this.gender,
    required this.village,
    required this.status,
  });
}

class CHWMyPatientsScreen extends StatefulWidget {
  @override
  _CHWMyPatientsScreenState createState() => _CHWMyPatientsScreenState();
}

class _CHWMyPatientsScreenState extends State<CHWMyPatientsScreen> {
  List<CHWPatient> patients = [];

  void _addPatient(CHWPatient patient) {
    setState(() {
      patients.add(patient);
    });
  }

  void _openAddPatientForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CHWAddPatientScreen(onAdd: _addPatient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Patients (CHW)")),
      body: patients.isEmpty
          ? Center(child: Text("No patients yet. Add one!"))
          : ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final p = patients[index];
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(p.name),
                  subtitle:
                      Text("${p.age} yrs • ${p.village} • ${p.status}"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CHWPatientDetailScreen(patient: p),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPatientForm,
        child: Icon(Icons.add),
        tooltip: 'Add Patient',
      ),
    );
  }
}

class CHWAddPatientScreen extends StatefulWidget {
  final Function(CHWPatient) onAdd;

  CHWAddPatientScreen({required this.onAdd});

  @override
  _CHWAddPatientScreenState createState() => _CHWAddPatientScreenState();
}

class _CHWAddPatientScreenState extends State<CHWAddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  String gender = 'Female';
  String village = '';
  String status = 'Active';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Patient")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Full Name"),
                onSaved: (value) => name = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Enter patient name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                onSaved: (value) => age = int.tryParse(value ?? '0') ?? 0,
                validator: (value) =>
                    value!.isEmpty ? 'Enter age' : null,
              ),
              DropdownButtonFormField<String>(
                value: gender,
                items: ["Female", "Male"]
                    .map((g) =>
                        DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => gender = value ?? 'Female',
                decoration: InputDecoration(labelText: "Gender"),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Village"),
                onSaved: (value) => village = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Enter village' : null,
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: ["Active", "Follow-up Needed", "Referred"]
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => status = value ?? 'Active',
                decoration: InputDecoration(labelText: "Status"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState?.save();
                    widget.onAdd(CHWPatient(
                      name: name,
                      age: age,
                      gender: gender,
                      village: village,
                      status: status,
                    ));
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save Patient"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CHWPatientDetailScreen extends StatelessWidget {
  final CHWPatient patient;

  CHWPatientDetailScreen({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient Details")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${patient.name}", style: TextStyle(fontSize: 18)),
            Text("Age: ${patient.age}", style: TextStyle(fontSize: 18)),
            Text("Gender: ${patient.gender}", style: TextStyle(fontSize: 18)),
            Text("Village: ${patient.village}", style: TextStyle(fontSize: 18)),
            Text("Status: ${patient.status}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
// Note: Ensure that the recipientType and recipientName are passed correctly