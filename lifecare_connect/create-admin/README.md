# 🔧 LifeCare Connect Admin Utilities

Professional Firebase admin utilities for setting up and managing the LifeCare Connect healthcare application.

## 📋 Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure Firebase:**
   - Place your `serviceAccountKey.json` in this directory
   - Ensure you have admin access to the Firebase project

## 🚀 Available Commands

### **Create Admin User**
```bash
npm run admin
# Creates: admin@test.com with password: admin2025
```

### **Generate Test Facilities**
```bash
npm run facilities
# Creates sample hospitals, labs, pharmacies, scan centers, and eye centers
```

### **Add Training Materials**
```bash
npm run training
# Adds sample CHW training videos and PDF materials
```

### **Complete Setup**
```bash
npm run setup
# Runs all commands: admin + facilities + training materials
```

## 🗂️ Project Structure

```
create-admin/
├── admin-utils.js          # Main utility functions
├── package.json            # Dependencies and scripts
├── README.md              # This documentation
├── serviceAccountKey.json  # Firebase credentials (not in git)
└── node_modules/          # Dependencies
```

## 📚 Functionality

### Admin User Management
- Creates admin user with predefined credentials
- Handles existing user cleanup
- Sets up proper Firestore user record

### Test Facilities Generation
- **Hospitals**: General and specialized medical centers
- **Laboratories**: Diagnostic and testing facilities  
- **Pharmacies**: Prescription and wellness centers
- **Scan Centers**: Imaging and radiology services
- **Eye Centers**: Vision and optical care

### Training Materials Management
- **Video Content**: CHW training videos with metadata
- **PDF Resources**: Guidelines, checklists, and manuals
- **Proper Categorization**: Role-based content targeting
- **Usage Tracking**: Download and view counters

## 🔧 Direct Usage

You can also run commands directly:

```bash
# Individual commands
node admin-utils.js admin
node admin-utils.js facilities
node admin-utils.js training

# Complete setup
node admin-utils.js all
```

## ⚠️ Important Notes

- **Cleanup**: Old debugging scripts have been removed for clarity
- **Integration**: All functionality consolidated into single utility
- **Professional**: Organized structure for production use
- **Extensible**: Easy to add new commands and features

## 🚨 Security

- Keep `serviceAccountKey.json` secure and never commit to version control
- Admin credentials should be changed in production
- Review and update test data before production deployment
# or
node admin-utils.js admin
```
Creates an admin user with:
- Email: `admin@test.com`
- Password: `admin2025`
- Role: `admin`

### **Generate Test Facilities**
```bash
npm run facilities
# or
node admin-utils.js facilities
```
Creates sample healthcare facilities including:
- 🏥 Hospitals (2)
- 🧪 Laboratories (2)
- 💊 Pharmacies (2)
- 📷 Scan Centers (2)
- 👁️ Eye Centers (1)

### **Complete Setup**
```bash
npm run setup
# or
node admin-utils.js all
```
Runs both admin creation and test facilities generation.

## 🎯 Available Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `admin` | Create admin user only | `npm run admin` |
| `facilities` | Generate test facilities only | `npm run facilities` |
| `setup` | Complete setup (admin + facilities) | `npm run setup` |

## 🔒 Security Notes

- **Never commit** `serviceAccountKey.json` to version control
- **Change default admin password** in production
- **Remove test data** before production deployment
- **Restrict Firebase Admin SDK** access in production

## 📁 Files

- `admin-utils.js` - Main utility script
- `package.json` - Node.js dependencies and scripts
- `serviceAccountKey.json` - Firebase service account (not in repo)
- `README.md` - This documentation

## 🛠️ Development

This utility is designed for:
- ✅ Initial project setup
- ✅ Development environment seeding
- ✅ Testing data generation
- ❌ Production data management (use Firebase Console)

---

**Note**: These utilities are for development and testing purposes. For production environments, use the Firebase Console or properly secured admin operations.
