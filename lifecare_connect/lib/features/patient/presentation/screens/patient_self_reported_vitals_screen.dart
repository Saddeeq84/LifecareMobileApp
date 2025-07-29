// ignore_for_file: prefer_const_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/data/services/health_records_service.dart';

class PatientSelfReportedVitalsScreen extends StatefulWidget {
  const PatientSelfReportedVitalsScreen({super.key});

  @override
  State<PatientSelfReportedVitalsScreen> createState() => _PatientSelfReportedVitalsScreenState();
}

class _PatientSelfReportedVitalsScreenState extends State<PatientSelfReportedVitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for vital signs
  final _bloodPressureSystolicController = TextEditingController();
  final _bloodPressureDiastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _temperatureUnit = 'Celsius';
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bloodSugarController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    
    if (weight != null && height != null && height > 0) {
      // Convert height to meters if in cm
      final heightInMeters = _heightUnit == 'cm' ? height / 100 : height;
      return weight / (heightInMeters * heightInMeters);
    }
    return null;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Future<void> _submitVitals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final bmi = _calculateBMI();
      
      final vitalsData = {
        'bloodPressure': {
          'systolic': int.tryParse(_bloodPressureSystolicController.text),
          'diastolic': int.tryParse(_bloodPressureDiastolicController.text),
          'unit': 'mmHg',
        },
        'heartRate': {
          'value': int.tryParse(_heartRateController.text),
          'unit': 'bpm',
        },
        'temperature': {
          'value': double.tryParse(_temperatureController.text),
          'unit': _temperatureUnit,
        },
        'weight': {
          'value': double.tryParse(_weightController.text),
          'unit': _weightUnit,
        },
        'height': {
          'value': double.tryParse(_heightController.text),
          'unit': _heightUnit,
        },
        'bmi': bmi != null ? {
          'value': double.parse(bmi.toStringAsFixed(1)),
          'category': _getBMICategory(bmi),
        } : null,
        'bloodSugar': _bloodSugarController.text.isNotEmpty ? {
          'value': double.tryParse(_bloodSugarController.text),
          'unit': 'mg/dL',
        } : null,
        'notes': _notesController.text.trim(),
        'recordedAt': DateTime.now().toIso8601String(),
        'submittedAt': DateTime.now().toIso8601String(),
      };

      await HealthRecordsService.saveSelfReportedVitals(
        patientUid: user.uid,
        patientName: user.displayName ?? 'Patient',
        vitalsData: vitalsData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vital signs recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving vital signs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _calculateBMI();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Reported Vital Signs'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monitor_heart, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Record Your Vital Signs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Blood Pressure
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blood Pressure (mmHg)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _bloodPressureSystolicController,
                            decoration: const InputDecoration(
                              labelText: 'Systolic',
                              hintText: '120',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final val = int.tryParse(value);
                                if (val == null || val < 70 || val > 250) {
                                  return 'Enter valid systolic (70-250)';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _bloodPressureDiastolicController,
                            decoration: const InputDecoration(
                              labelText: 'Diastolic',
                              hintText: '80',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final val = int.tryParse(value);
                                if (val == null || val < 40 || val > 150) {
                                  return 'Enter valid diastolic (40-150)';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Heart Rate
            TextFormField(
              controller: _heartRateController,
              decoration: const InputDecoration(
                labelText: 'Heart Rate (bpm)',
                hintText: '72',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.favorite),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final val = int.tryParse(value);
                  if (val == null || val < 30 || val > 220) {
                    return 'Enter valid heart rate (30-220 bpm)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Temperature
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Temperature',
                      hintText: '36.5',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.thermostat),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _temperatureUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Celsius', 'Fahrenheit'].map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _temperatureUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Weight and Height for BMI calculation
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight ($_weightUnit)',
                      hintText: '70',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.monitor_weight),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => setState(() {}), // Trigger BMI recalculation
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: 'Height ($_heightUnit)',
                      hintText: '170',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => setState(() {}), // Trigger BMI recalculation
                  ),
                ),
              ],
            ),
            
            // BMI Display
            if (bmi != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getBMIColor(bmi).withOpacity(0.1),
                  border: Border.all(color: _getBMIColor(bmi)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'BMI: ${bmi.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getBMIColor(bmi),
                      ),
                    ),
                    Text(
                      _getBMICategory(bmi),
                      style: TextStyle(
                        fontSize: 16,
                        color: _getBMIColor(bmi),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // Blood Sugar (Optional)
            TextFormField(
              controller: _bloodSugarController,
              decoration: const InputDecoration(
                labelText: 'Blood Sugar (mg/dL) - Optional',
                hintText: '100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.water_drop),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final val = double.tryParse(value);
                  if (val == null || val < 30 || val > 500) {
                    return 'Enter valid blood sugar (30-500 mg/dL)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any symptoms or observations',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVitals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Vital Signs',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Important Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: Once submitted, this vital signs record cannot be edited or deleted for audit trail compliance.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
