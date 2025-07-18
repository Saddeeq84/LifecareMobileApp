// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CHWAppointmentsScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const CHWAppointmentsScreen({super.key, required this.notificationsPlugin});

  @override
  State<CHWAppointmentsScreen> createState() => _CHWAppointmentsScreenState();
}

class _CHWAppointmentsScreenState extends State<CHWAppointmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedPatient;
  String? editingAppointmentId;

  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _fetchPatients();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .where('chwId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      patients = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name'] as String})
          .toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _scheduleNotification(String patientName, DateTime dateTime) async {
    final androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Appointments',
      importance: Importance.max,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule 15 minutes before appointment time in local timezone
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local).subtract(Duration(minutes: 15));

    await widget.notificationsPlugin.zonedSchedule(
      dateTime.hashCode,
      'Upcoming Appointment',
      'Reminder: $patientName has an appointment',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate() ||
        selectedDate == null ||
        selectedTime == null ||
        selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final appointmentDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final appointmentData = {
      'patientId': selectedPatient,
      'patientName': patients.firstWhere((p) => p['id'] == selectedPatient)['name'],
      'date': appointmentDateTime.toIso8601String(),
      'note': _noteController.text.trim(),
      'chwId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      final appointmentsRef = FirebaseFirestore.instance.collection('appointments');

      if (editingAppointmentId != null) {
        // Update existing
        await appointmentsRef.doc(editingAppointmentId).update(appointmentData);
      } else {
        // Create new
        await appointmentsRef.add(appointmentData);
      }

      await _scheduleNotification(appointmentData['patientName'], appointmentDateTime);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(editingAppointmentId == null ? 'Appointment scheduled' : 'Appointment updated')),
      );

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving appointment: $e')),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _noteController.clear();
    selectedDate = null;
    selectedTime = null;
    selectedPatient = null;
    editingAppointmentId = null;
    setState(() {});
  }

  void _editAppointment(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dateTime = DateTime.parse(data['date']);

    setState(() {
      editingAppointmentId = doc.id;
      selectedPatient = data['patientId'];
      _noteController.text = data['note'] ?? '';
      selectedDate = dateTime;
      selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    });
  }

  Future<void> _deleteAppointment(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = selectedDate != null
        ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
        : 'Select Date';

    final timeLabel = selectedTime != null ? selectedTime!.format(context) : 'Select Time';

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final appointmentsStream = FirebaseFirestore.instance
        .collection('appointments')
        .where('chwId', isEqualTo: userId)
        .orderBy('date')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Appointment'), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedPatient,
                    decoration: const InputDecoration(
                      labelText: 'Select Patient',
                      prefixIcon: Icon(Icons.person_search),
                    ),
                    items: patients.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem<String>(
                        value: p['id'] as String,
                        child: Text(p['name'] as String),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedPatient = val),
                    validator: (val) => val == null ? 'Please select a patient' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: Text(dateLabel),
                    onTap: _pickDate,
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(timeLabel),
                    onTap: _pickTime,
                  ),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(editingAppointmentId == null ? Icons.save : Icons.edit),
                    label: Text(editingAppointmentId == null ? 'Schedule Appointment' : 'Update Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _submitAppointment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Scheduled Appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: appointmentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No appointments scheduled yet.');
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final date = DateTime.parse(data['date']);
                    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    final timeStr = TimeOfDay.fromDateTime(date).format(context);

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text(data['patientName'] ?? 'Unknown Patient'),
                        subtitle: Text(
                          'Date: $dateStr\nTime: $timeStr\nNotes: ${data['note'] ?? ''}',
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 10,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editAppointment(doc),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAppointment(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
