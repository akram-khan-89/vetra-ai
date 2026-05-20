const admin = require('firebase-admin');
const path = require('path');

if (!admin.apps.length) {
  try {
    const serviceAccount = require(path.join(__dirname, '../firebase-service-account.json'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
  } catch (err) {
    console.error('[TRACER] Firebase initialization failed:', err.message);
  }
}

const db = admin.firestore();

async function saveAgentTrace(caseId, step, stepInput, stepOutput, reasoning = "") {
  if (!caseId) return;
  const traceData = {
    case_id: caseId,
    step,
    input: stepInput,
    output: stepOutput,
    reasoning,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  };
  try {
    await db.collection('agent_traces').add(traceData);
    console.log(`[TRACER] Saved trace for case: ${caseId}, step: ${step}`);
  } catch (e) {
    console.error(`[TRACER] Failed to save trace for step ${step}:`, e.message);
  }
}

module.exports = { saveAgentTrace };
