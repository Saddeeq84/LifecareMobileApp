// Script to migrate old health_records documents to add chwId at the top level
// Usage: Run this script with Node.js after configuring Firebase Admin SDK

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrateCHWId() {
  const recordsRef = db.collection('health_records');
  const snapshot = await recordsRef.get();
  let updatedCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    // Only update if chwId is missing at top level but present in consultationData
    if (!data.chwId && data.consultationData && data.consultationData.chwId) {
      await doc.ref.update({ chwId: data.consultationData.chwId });
      updatedCount++;
      console.log(`Updated document ${doc.id} with chwId: ${data.consultationData.chwId}`);
    }
  }
  console.log(`Migration complete. Updated ${updatedCount} documents.`);
}

migrateCHWId().catch(console.error);
