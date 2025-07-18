const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function createAdmin() {
  try {
    // ✅ Create new admin user
    const newUser = await admin.auth().createUser({
      email: 'admin@lifecare.com',
      password: 'NewSecurePassword123', // Choose a strong password you'll remember
    });

    console.log('✅ Created admin user:', newUser.uid);

    // ✅ Assign admin role via custom claims
    await admin.auth().setCustomUserClaims(newUser.uid, { role: 'admin' });
    console.log('✅ Assigned admin role to:', newUser.email);
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

createAdmin();
