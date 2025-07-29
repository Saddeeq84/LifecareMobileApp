const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ==============================================================================
// ADMIN USER CREATION
// ==============================================================================

async function createAdmin() {
  const email = 'admin@test.com';
  console.log('🔧 Creating admin user...');
  
  try {
    // Delete user if exists
    const existingUser = await admin.auth().getUserByEmail(email);
    await admin.auth().deleteUser(existingUser.uid);
    console.log(`🗑️ Deleted existing user: ${email}`);
  } catch (e) {
    console.log(`ℹ️ No existing user to delete: ${email}`);
  }

  try {
    const newUser = await admin.auth().createUser({
      email,
      password: 'admin2025',
      emailVerified: true, 
    });

    console.log('✅ Created admin user:', newUser.uid);

    await admin.auth().setCustomUserClaims(newUser.uid, { role: 'admin' });
    console.log('✅ Assigned admin role to:', newUser.email);
    
    return newUser;
  } catch (error) {
    console.error('❌ Error creating admin user:', error);
    throw error;
  }
}

// ==============================================================================
// TEST FACILITIES DATA GENERATION (FOR DEVELOPMENT ONLY)
// ==============================================================================

const sampleFacilities = [
  // Hospitals
  {
    email: 'contact@cityhospital.com',
    facilityName: 'City General Hospital',
    facilityType: 'hospital',
    location: '123 Main Street, Downtown',
    phone: '+1234567890',
    contactPerson: 'Dr. Sarah Johnson',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['emergency', 'consultation', 'surgery', 'vaccination']
  },
  {
    email: 'info@stmaryhospital.com',
    facilityName: 'St. Mary Medical Center',
    facilityType: 'hospital',
    location: '456 Health Avenue, Medical District',
    phone: '+1234567891',
    contactPerson: 'Dr. Michael Brown',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['emergency', 'consultation', 'specialist_consultation', 'health_checkup']
  },

  // Laboratories
  {
    email: 'lab@quickdiagnostics.com',
    facilityName: 'Quick Diagnostics Lab',
    facilityType: 'laboratory',
    location: '789 Science Park, Lab District',
    phone: '+1234567892',
    contactPerson: 'Dr. Emily Chen',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['blood_test', 'urine_test', 'culture_test', 'hormone_test']
  },
  {
    email: 'contact@precisionlab.com',
    facilityName: 'Precision Medical Laboratory',
    facilityType: 'laboratory',
    location: '321 Research Boulevard, Science Hub',
    phone: '+1234567893',
    contactPerson: 'Dr. Robert Kim',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['blood_test', 'genetic_test', 'stool_test', 'culture_test']
  },

  // Pharmacies
  {
    email: 'info@healthpharmacy.com',
    facilityName: 'Health Plus Pharmacy',
    facilityType: 'pharmacy',
    location: '654 Wellness Street, Shopping Center',
    phone: '+1234567894',
    contactPerson: 'PharmD Lisa Wang',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['prescription_pickup', 'medication_consultation', 'vaccination', 'health_products']
  },
  {
    email: 'care@familypharmacy.com',
    facilityName: 'Family Care Pharmacy',
    facilityType: 'pharmacy',
    location: '987 Community Road, Residential Area',
    phone: '+1234567895',
    contactPerson: 'PharmD John Davis',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['prescription_pickup', 'medication_delivery', 'health_products', 'vaccination']
  },

  // Scan Centers
  {
    email: 'imaging@advancedscans.com',
    facilityName: 'Advanced Imaging Center',
    facilityType: 'scan_center',
    location: '147 Technology Drive, Medical Plaza',
    phone: '+1234567896',
    contactPerson: 'Dr. Amanda Lee',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['x_ray', 'mri', 'ct_scan', 'ultrasound']
  },
  {
    email: 'scans@radiologyplus.com',
    facilityName: 'Radiology Plus Center',
    facilityType: 'scan_center',
    location: '258 Diagnostic Lane, Healthcare Complex',
    phone: '+1234567897',
    contactPerson: 'Dr. Mark Wilson',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['x_ray', 'ultrasound', 'mammography', 'bone_density']
  },

  // Eye Centers
  {
    email: 'vision@cleareyecenter.com',
    facilityName: 'Clear Vision Eye Center',
    facilityType: 'eye_center',
    location: '369 Vision Street, Optical District',
    phone: '+1234567898',
    contactPerson: 'Dr. Jennifer Taylor',
    role: 'facility',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    services: ['eye_exam', 'vision_test', 'contact_lens', 'cataract_consultation']
  }
];

async function createTestFacilities() {
  console.log('🏥 Creating test facilities...');
  
  try {
    for (const facility of sampleFacilities) {
      const facilityRef = db.collection('facilities').doc();
      await facilityRef.set(facility);
      console.log(`✅ Created facility: ${facility.facilityName}`);
    }
    
    console.log('🎉 Successfully created all test facilities!');
    return true;
  } catch (error) {
    console.error('❌ Error creating test facilities:', error);
    throw error;
  }
}

// ==============================================================================
// TRAINING MATERIALS MANAGEMENT
// ==============================================================================

async function createTrainingMaterials() {
  console.log('📚 Creating sample training materials...');
  
  try {
    const trainingMaterials = [
      // Video Materials
      {
        title: 'Basic CHW Training Video',
        description: 'Introduction to Community Health Worker role and responsibilities',
        type: 'video',
        targetRole: 'chw',
        isActive: true,
        uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
        url: 'https://example.com/video1.mp4',
        duration: 1800, // 30 minutes
        downloadCount: 0,
        viewCount: 0,
        createdBy: 'admin',
        tags: ['basic', 'introduction', 'chw']
      },
      {
        title: 'Patient Care Techniques',
        description: 'Learn essential patient care techniques for CHWs',
        type: 'video',
        targetRole: 'chw',
        isActive: true,
        uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
        url: 'https://example.com/video2.mp4',
        duration: 2400, // 40 minutes
        downloadCount: 0,
        viewCount: 0,
        createdBy: 'admin',
        tags: ['patient-care', 'techniques', 'practical']
      },
      
      // PDF Materials
      {
        title: 'CHW Guidelines Manual',
        description: 'Comprehensive guidelines for Community Health Workers',
        type: 'pdf',
        targetRole: 'chw',
        isActive: true,
        uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
        url: 'https://example.com/chw-manual.pdf',
        fileName: 'chw-guidelines-manual.pdf',
        fileSize: 2048000, // 2MB
        downloadCount: 0,
        createdBy: 'admin',
        tags: ['manual', 'guidelines', 'reference']
      },
      {
        title: 'Health Assessment Checklist',
        description: 'Checklist for conducting basic health assessments',
        type: 'pdf',
        targetRole: 'chw',
        isActive: true,
        uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
        url: 'https://example.com/checklist.pdf',
        fileName: 'health-assessment-checklist.pdf',
        fileSize: 512000, // 512KB
        downloadCount: 0,
        createdBy: 'admin',
        tags: ['checklist', 'assessment', 'health']
      },
      {
        title: 'Malaria Management Guide',
        description: 'Guidelines for identifying and managing malaria cases',
        type: 'pdf',
        targetRole: 'chw',
        isActive: true,
        uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
        url: 'https://example.com/malaria-guide.pdf',
        fileName: 'malaria-management-guide.pdf',
        fileSize: 1024000, // 1MB
        downloadCount: 0,
        createdBy: 'admin',
        tags: ['malaria', 'disease-management', 'treatment']
      }
    ];

    for (const material of trainingMaterials) {
      await db.collection('training_materials').add(material);
      console.log(`✅ Added: ${material.title} (${material.type})`);
    }
    
    // Verify creation
    const snapshot = await db.collection('training_materials').get();
    console.log(`📊 Total training materials in database: ${snapshot.size}`);
    
    console.log('🎉 Successfully created all training materials!');
    return true;
    
  } catch (error) {
    console.error('❌ Error creating training materials:', error);
    throw error;
  }
}

// ==============================================================================
// MAIN EXECUTION
// ==============================================================================

async function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log(`
🔧 Firebase Admin Utility

Usage:
  node admin-utils.js [command]

Commands:
  admin           Create admin user (admin@test.com)
  facilities      Generate test facilities data
  training        Add sample training materials for CHWs
  all             Create admin + facilities + training materials
  
Examples:
  node admin-utils.js admin
  node admin-utils.js facilities
  node admin-utils.js training
  node admin-utils.js all
    `);
    return;
  }

  const command = args[0].toLowerCase();

  try {
    switch (command) {
      case 'admin':
        await createAdmin();
        break;
        
      case 'facilities':
        await createTestFacilities();
        break;
        
      case 'training':
        await createTrainingMaterials();
        break;
        
      case 'all':
        await createAdmin();
        await createTestFacilities();
        await createTrainingMaterials();
        break;
        
      default:
        console.error(`❌ Unknown command: ${command}`);
        console.log('Available commands: admin, facilities, training, all');
        process.exit(1);
    }
    
    console.log('🎉 Operation completed successfully!');
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Operation failed:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = {
  createAdmin,
  createTestFacilities,
  createTrainingMaterials
};
