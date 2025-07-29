# LifeCare Connect 🏥

A comprehensive Flutter healthcare application connecting patients, doctors, facilities, and community health workers (CHWs) for seamless healthcare delivery.

## 🎯 Project Overview

LifeCare Connect is a multi-role healthcare platform that enables:
- **Patients**: Book appointments, access health records, communicate with providers
- **Doctors**: Manage patients, appointments, and consultations  
- **Facilities**: Offer services, manage bookings, coordinate patient care
- **CHWs**: Register patients, create referrals, manage community health
- **Admins**: System administration and oversight

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (see Firestore setup guide)
4. Run `flutter run` to start the application

## 📚 Documentation

### **Core Documentation:**
- 🔥 **[Firestore Complete Guide](FIRESTORE_COMPLETE_GUIDE.md)** - Comprehensive database setup, security rules, referral system, and best practices

### **Architecture:**
- **Frontend**: Flutter with clean architecture pattern
- **Backend**: Firebase Firestore with comprehensive security rules
- **Authentication**: Firebase Auth with role-based access control
- **Storage**: Firebase Storage for media files
- **Messaging**: Firebase Cloud Messaging for notifications

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart              # App configuration
├── config/               # App configuration
├── constants/            # App constants
├── helpers/              # Utility functions
├── models/               # Data models
├── screens/              # UI screens
│   ├── adminscreen/      # Admin interface
│   ├── chwscreen/        # CHW interface  
│   ├── doctorscreen/     # Doctor interface
│   ├── facilityscreen/   # Facility interface
│   ├── patientscreen/    # Patient interface
│   └── sharedscreen/     # Shared components
├── services/             # Business logic & API calls
└── widgets/              # Reusable UI components
```

## 🔒 Security & Permissions

The app implements comprehensive role-based security through Firestore security rules:
- **Authentication required** for all operations
- **Role-specific permissions** with approval workflows
- **Data isolation** ensuring users only access appropriate data
- **Audit trails** for sensitive healthcare operations

See [Firestore Complete Guide](FIRESTORE_COMPLETE_GUIDE.md) for detailed security implementation.

## 🚀 Features

### **Patient Features:**
- Registration and profile management
- Appointment booking with doctors
- Service requests to facilities
- Health record access
- Secure messaging
- View and acknowledge approved referrals

### **Doctor Features:**
- Patient management dashboard
- Appointment scheduling
- Medical consultations and notes
- Referral management (initiate and approve referrals)
- Training material access

### **Facility Features:**
- Service catalog management
- Patient booking management
- Service delivery tracking
- Patient communication
- Accept/reject referrals with reasons

### **CHW Features:**
- Patient registration and management
- Doctor referral system (initiate referrals to doctors/facilities)
- Health record management
- Community health tracking
- Confirm receipt of doctor referrals

### **Admin Features:**
- User management and approval
- System monitoring
- Content management
- Bug report management

## 🛠️ Technology Stack

- **Frontend**: Flutter, Dart
- **Backend**: Firebase Firestore
- **Authentication**: Firebase Auth  
- **Storage**: Firebase Storage
- **Messaging**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web (responsive design)

## 🤝 Contributing

1. Follow Flutter best practices and coding standards
2. Test thoroughly before submitting changes
3. Update documentation for new features
4. Ensure security rules are updated for new collections

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

For technical setup and database configuration, see [Firestore Complete Guide](FIRESTORE_COMPLETE_GUIDE.md).
