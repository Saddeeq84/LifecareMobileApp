# Referral System Implementation Guide

## Overview
The referral system allows different roles to manage patient referrals with specific permissions and workflows.

## Role-Based Permissions

### 🩺 **Doctor**
- ✅ Can initiate referrals to facilities and CHWs
- ✅ Can approve or reject referrals sent to them
- ❌ Cannot delete referrals
- **Screen**: `doctor_referrals_screen.dart` → Uses `SharedReferralWidget(role: 'doctor')`

### 👩‍⚕️ **CHW (Community Health Worker)**
- ✅ Can initiate referrals to doctors and facilities
- ✅ Can approve/confirm receipt of referrals from doctors only (not facilities)
- ❌ Cannot delete referrals
- **Screen**: `referrals_screen.dart` → Uses `SharedReferralWidget(role: 'chw')`

### 🏥 **Facility**
- ❌ Cannot initiate referrals
- ✅ Can accept or reject referrals with reasons
- ❌ Cannot delete referrals
- **Screen**: `facility_referrals_screen.dart` → Uses `SharedReferralWidget(role: 'facility')`

### 👤 **Patient**
- ❌ Cannot initiate referrals
- ❌ Cannot approve, delete, or reject referrals
- ✅ Can view approved referrals in their appointments
- ✅ Can acknowledge approved referrals
- **Screen**: `patient_appointment_screen.dart` → Referrals tab with `SharedReferralWidget(role: 'patient')`

### 🔧 **Admin**
- ✅ Can view all referrals
- ✅ Can delete referrals
- ❌ Cannot approve, edit, or reject referrals
- **Screen**: `referrals_screen.dart` → Uses `SharedReferralWidget(role: 'admin')`

## File Structure

```
lib/
├── screens/
│   ├── sharedscreen/
│   │   ├── Shared_Referral_Widget.dart          # Main referral widget
│   │   └── make_referral_form.dart              # Form to create new referrals
│   ├── chwscreen/
│   │   └── referrals_screen.dart                # CHW referral interface
│   ├── doctorscreen/
│   │   └── doctor_referrals_screen.dart         # Doctor referral interface
│   ├── facilityscreen/
│   │   └── facility_referrals_screen.dart       # Facility referral interface
│   ├── adminscreen/
│   │   └── referrals_screen.dart                # Admin referral interface
│   └── patientscreen/
│       └── patient_appointment_screen.dart      # Patient view (referrals tab)
└── test_data/
    └── referral_test_data.dart                  # Test data generator
```

## Key Features

### 📱 **Tabbed Interface** (for CHW, Doctor, Facility)
- **Sent**: Referrals initiated by the user
- **Received**: Referrals sent to the user
- **All**: Combined view of all referrals

### 🔄 **Status Management**
- `pending`: Initial state
- `approved`: Accepted by recipient
- `rejected`: Declined by recipient
- `confirmed`: CHW confirmed receipt from doctor

### 🚨 **Urgency Levels**
- `urgent`: Red badge
- `high`: Orange badge
- `normal`: Blue badge
- `low`: Green badge

### 🎯 **Action Buttons** (Role-specific)
- **Approve/Reject**: For doctors on received referrals
- **Confirm Receipt**: For CHWs on doctor referrals
- **Accept/Reject with Reason**: For facilities
- **Acknowledge**: For patients on approved referrals
- **Delete**: For admins only

## Database Structure

### Referrals Collection
```firestore
/referrals/{referralId}
{
  patientId: string,
  patientName: string,
  fromUserId: string,
  fromRole: string,
  toUserId: string,
  toRole: string,
  reason: string,
  urgency: string, // 'urgent', 'high', 'normal', 'low'
  status: string, // 'pending', 'approved', 'rejected', 'confirmed'
  createdAt: Timestamp,
  actionBy?: string,
  actionDate?: Timestamp,
  actionReason?: string, // For facility rejections
  patientAcknowledged?: boolean, // For patient acknowledgment
  patientAcknowledgedAt?: Timestamp
}
```

## Security Rules

### Firestore Rules (Added to `firestore_rules_update.rules`)
- Role-based read/write permissions
- Users can only see referrals they sent or received
- Patients only see approved referrals for them
- Admins can view all but only delete

### Composite Indexes (Added to `firestore.indexes.json`)
- `fromUserId + status + createdAt`
- `toUserId + status + createdAt`
- `patientId + status + createdAt`

## Testing

### Generate Test Data
```dart
// In any screen, add a debug button or run once:
import '../test_data/referral_test_data.dart';

// Generate role-appropriate test referrals
await ReferralTestDataGenerator.generateTestReferrals();
```

## Navigation Integration

### CHW Dashboard
```dart
// Add referrals icon that navigates to:
Navigator.pushNamed(context, '/chw_referrals');
```

### Route Registration (in main.dart or app.dart)
```dart
'/chw_referrals': (context) => const CHWReferralScreen(),
'/doctor_referrals': (context) => const DoctorReferralsScreen(),
'/facility_referrals': (context) => const FacilityReferralsScreen(),
'/admin_referrals': (context) => const ReferralsScreen(),
```

## Patient Workflow
1. **Doctor/CHW** creates referral → Status: `pending`
2. **Recipient** (facility/doctor/chw) approves → Status: `approved`
3. **Patient** sees approved referral in appointments tab
4. **Patient** can acknowledge the referral
5. **System** notifies patient of required actions

## Error Handling
- Connection state checks in StreamBuilder
- User-friendly error messages
- Loading states during operations
- Confirmation dialogs for destructive actions

This implementation provides a comprehensive, role-based referral system that maintains proper access control while enabling seamless healthcare coordination between different user types.
