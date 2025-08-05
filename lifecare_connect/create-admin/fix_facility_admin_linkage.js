// Script to scan Firestore 'facilities' collection and ensure each document has a valid 'adminUserId' field
// Requires serviceAccountKey.json in the same folder

const admin = require('firebase-admin');
const fs = require('fs');

const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixFacilityAdminLinkage() {
  // Find all users with role 'facility' and print their IDs
  const facilityUsersSnapshot = await db.collection('users').where('role', '==', 'facility').get();
  let count = 0;
  for (const doc of facilityUsersSnapshot.docs) {
    console.log(`Facility user: ${doc.id}, email: ${doc.data().email || 'N/A'}`);
    count++;
  }
  console.log(`Finished. Found ${count} facility users.`);
}

fixFacilityAdminLinkage().catch(console.error);
