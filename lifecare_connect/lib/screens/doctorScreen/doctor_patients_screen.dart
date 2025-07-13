import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A screen that displays a list of patients assigned to the doctor.
/// Fetches real-time data from Firestore and renders it as a scrollable list.
class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream that listens to changes in the 'patients' collection
        stream: FirebaseFirestore.instance.collection('patients').snapshots(),
        builder: (context, snapshot) {
          // Display a loading indicator while the connection is being established
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle any errors that occur during the fetch
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If the collection is empty or has no documents
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No patients found.'));
          }

          // Extract patient documents from snapshot
          final patients = snapshot.data!.docs;

          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              // Safely extract patient data
              final data = patients[index].data() as Map<String, dynamic>;

              // Retrieve individual patient fields with safe fallback values
              final String name = data['name'] ?? 'Unknown';
              final String age = data['age']?.toString() ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(name),
                  subtitle: Text('Age: $age'),
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      // TODO: Implement patient detail navigation
                      // Example:
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (_) => PatientDetailScreen(patientId: patients[index].id),
                      // ));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
