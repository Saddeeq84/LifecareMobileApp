// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

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

  final List<Map<String, String>> _appointments = [];
  int? _editingIndex;

  String? selectedPatient;

  // Mock list of registered patients
  final List<String> _registeredPatients = [
    'Amina Musa',
    'John Doe',
    'Maryam Ibrahim',
    'Fatima Sule',
    'Peter Okoye'
  ];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  Future<void> _scheduleNotification(String patient, DateTime dateTime) async {
    final androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Appointments',
      importance: Importance.max,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    final scheduledDate = TZDateTime.from(
      dateTime.toLocal().subtract(const Duration(minutes: 15)),
      local,
    );

    await widget.notificationsPlugin.zonedSchedule(
      dateTime.hashCode,
      'Upcoming Appointment',
      'Reminder: $patient has an appointment',
      scheduledDate,
      notificationDetails,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  void _submitAppointment() {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null &&
        selectedPatient != null) {
      final appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final date = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
      final time = selectedTime!.format(context);

      final appointment = {
        'patient': selectedPatient!,
        'date': date,
        'time': time,
        'note': _noteController.text,
        'datetime': appointmentDateTime.toIso8601String(),
      };

      setState(() {
        if (_editingIndex != null) {
          _appointments[_editingIndex!] = appointment;
          _editingIndex = null;
        } else {
          _appointments.add(appointment);
        }

        _appointments.sort((a, b) =>
            DateTime.parse(a['datetime']!).compareTo(DateTime.parse(b['datetime']!)));

        _clearForm();
      });

      _scheduleNotification(appointment['patient']!, appointmentDateTime);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editingIndex == null
              ? 'Appointment scheduled'
              : 'Appointment updated'),
        ),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _noteController.clear();
    selectedDate = null;
    selectedTime = null;
    selectedPatient = null;
    _editingIndex = null;
  }

  void _editAppointment(int index) {
    final appt = _appointments[index];
    setState(() {
      _editingIndex = index;
      selectedPatient = appt['patient']!;
      _noteController.text = appt['note']!;
      selectedDate = DateTime.parse(appt['datetime']!);
      selectedTime = TimeOfDay(
        hour: selectedDate!.hour,
        minute: selectedDate!.minute,
      );
    });
  }

  void _deleteAppointment(int index) {
    setState(() {
      _appointments.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = selectedDate != null
        ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
        : 'Select Date';
    final timeLabel =
        selectedTime != null ? selectedTime!.format(context) : 'Select Time';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: Colors.teal,
      ),
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
                    items: _registeredPatients.map((patient) {
                      return DropdownMenuItem<String>(
                        value: patient,
                        child: Text(patient),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      selectedPatient = value;
                    }),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please select a patient'
                        : null,
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
                    icon: Icon(_editingIndex == null ? Icons.save : Icons.edit),
                    label: Text(_editingIndex == null
                        ? 'Schedule Appointment'
                        : 'Update Appointment'),
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
            if (_appointments.isEmpty)
              const Text('No appointments scheduled yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: _appointments.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final appt = _appointments[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(appt['patient']!),
                      subtitle: Text(
                        'Date: ${appt['date']}\nTime: ${appt['time']}\nNotes: ${appt['note'] ?? ''}',
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 10,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editAppointment(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAppointment(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
// This screen allows CHWs to schedule appointments for patients, including setting reminders via local notifications.