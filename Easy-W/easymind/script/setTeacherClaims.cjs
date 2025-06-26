const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Replace with your service account key path

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function setTeacherClaims() {
  try {
    const teacherDocs = await admin.firestore().collection('teacherRequests').where('status', '==', 'Active').get();
    console.log(`Found ${teacherDocs.size} active teachers`);

    if (teacherDocs.empty) {
      console.log('No active teachers found in teacherRequests collection.');
      return;
    }

    const updates = [];
    for (const doc of teacherDocs.docs) {
      const uid = doc.id;
      const teacherData = doc.data();
      console.log(`Processing teacher UID: ${uid}, Email: ${teacherData.email}`);

      // Verify the user exists in Firebase Authentication
      try {
        await admin.auth().getUser(uid);
        updates.push(
          admin.auth().setCustomUserClaims(uid, { role: 'teacher' })
            .then(() => console.log(`Set role: teacher for UID: ${uid}`))
            .catch(error => console.error(`Failed to set claim for UID ${uid}:`, error))
        );
      } catch (error) {
        console.error(`User with UID ${uid} not found in Firebase Authentication:`, error);
      }
    }

    await Promise.all(updates);
    console.log(`Successfully set teacher roles for ${updates.length} users`);
  } catch (error) {
    console.error('Error setting teacher roles:', error);
  }
}

setTeacherClaims();