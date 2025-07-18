import 'package:flutter/material.dart';

class FacilityForm extends StatefulWidget {
  final void Function({
    required String name,
    required String location,
    required String type,
  }) onSubmit;

  final bool isSubmitting;

  const FacilityForm({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  State<FacilityForm> createState() => _FacilityFormState();
}

class _FacilityFormState extends State<FacilityForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  String _selectedType = 'Primary';

  final List<String> facilityTypes = [
    'Primary',
    'Secondary',
    'Tertiary',
    'Clinic',
    'Hospital',
    'Pharmacy',
    'Laboratory',
    'Scan Center',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        type: _selectedType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: "Facility Name",
              border: OutlineInputBorder(),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationCtrl,
            decoration: const InputDecoration(
              labelText: "Location (State / LGA)",
              border: OutlineInputBorder(),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: "Facility Type",
              border: OutlineInputBorder(),
            ),
            items: facilityTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedType = val);
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: widget.isSubmitting ? null : _submit,
            icon: widget.isSubmitting
                ? const CircularProgressIndicator.adaptive()
                : const Icon(Icons.save),
            label: Text(widget.isSubmitting ? "Saving..." : "Submit"),
          ),
        ],
      ),
    );
  }
}
