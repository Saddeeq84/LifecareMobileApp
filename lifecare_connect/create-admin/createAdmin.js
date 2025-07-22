const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function createAdmin() {
  const email = 'admin@test.com';
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
  } catch (error) {
    console.error('❌ Error creating user:', error);
  }
}

createAdmin();
