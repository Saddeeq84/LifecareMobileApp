import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFacilitiesScreen extends StatefulWidget {
  const AdminFacilitiesScreen({super.key});

  @override
  State<AdminFacilitiesScreen> createState() => _AdminFacilitiesScreenState();
}

class _AdminFacilitiesScreenState extends State<AdminFacilitiesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String _type = 'hospital';
  final _services = <String, bool>{
    'medicine_delivery': false,
    'lab_test': false,
    'scan': false,
    'hospital_appointment': false,
  };
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _addFacility() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final facilityDoc = {
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'contact': _contactCtrl.text.trim(),
      'type': _type,
      'services': _services,
    };

    await FirebaseFirestore.instance.collection('facilities').add(facilityDoc);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facility added')));
    _formKey.currentState!.reset();
    setState(() {
      _submitting = false;
      _services.updateAll((key, value) => false);
      _type = 'hospital';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Facilities'), backgroundColor: Colors.green.shade700),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Required' : null,),
              TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Address'), validator: (v) => v!.isEmpty ? 'Required' : null,),
              TextFormField(controller: _contactCtrl, decoration: const InputDecoration(labelText: 'Contact'), validator: (v) => v!.isEmpty ? 'Required' : null,),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'hospital', child: Text('Hospital')),
                  DropdownMenuItem(value: 'laboratory', child: Text('Laboratory')),
                  DropdownMenuItem(value: 'pharmacy', child: Text('Pharmacy')),
                  DropdownMenuItem(value: 'scan_center', child: Text('Scan Center')),
                ],
                onChanged: (v) { if (v != null) setState(() => _type = v); },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 16),
              const Text('Available Services', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._services.entries.map((e) {
                return CheckboxListTile(
                  title: Text(_displayLabel(e.key)),
                  value: e.value,
                  onChanged: (v) => setState(() => _services[e.key] = v ?? false),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _addFacility,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Facility'),
                ),
              ),
            ]),
          ),
          const Divider(height: 32),
          const Text('Existing Facilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('facilities').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const CircularProgressIndicator();
              final docs = snap.data!.docs;
              return Column(children: docs.map((d) {
                final dData = d.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(dData['name'] ?? ''),
                  subtitle: Text(dData['type'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => d.reference.delete(),
                  ),
                );
              }).toList());
            },
          ),
        ]),
      ),
    );
  }

  String _displayLabel(String key) {
    switch (key) {
      case 'lab_test':
        return 'Lab Test';
      case 'medicine_delivery':
        return 'Medicine Delivery';
      case 'scan':
        return 'Scan';
      case 'hospital_appointment':
        return 'Hospital Appointment';
      default:
        return key;
    }
  }
}
