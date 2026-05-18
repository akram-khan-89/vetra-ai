const admin = require('firebase-admin');
const path = require('path');
const { listenAgent } = require('../agents/listen_agent');
const { diagnoseAgent } = require('../agents/diagnose_agent');
const { discoverAgent } = require('../agents/discover_agent');
const { decideAgent } = require('../agents/decide_agent');
const { executeAgent } = require('../agents/execute_agent');

// Initialize Firebase Admin
const serviceAccount = require(path.join(__dirname, '../firebase-service-account.json'));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function runVetraWorkflow(input) {
  const { text, farmer_lat, farmer_lng, vision_findings = [] } = input;
  const case_id = `case_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  console.log(`[ORCHESTRATOR] Starting workflow for case: ${case_id}`);

  const trace_id = case_id;

  async function saveTrace(step, stepInput, stepOutput, reasoning = "") {
    const traceData = {
      case_id,
      step,
      input: stepInput,
      output: stepOutput,
      reasoning,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    };
    try {
      await db.collection('agent_traces').add(traceData);
      console.log(`[ORCHESTRATOR] Saved trace for step: ${step}`);
    } catch (e) {
      console.error(`[ORCHESTRATOR] Failed to save trace for step ${step}:`, e.message);
    }
  }

  try {
    // Step 1: Listen
    const listen_result = await listenAgent(text);
    await saveTrace('listen', { text }, listen_result, "Extracted symptoms and animal type");

    const { symptoms, animal_type, urgency } = listen_result;

    // Step 2: Diagnose
    const diagnosis = await diagnoseAgent(symptoms, animal_type, vision_findings);
    await saveTrace('diagnose', { symptoms, animal_type, vision_findings }, diagnosis, diagnosis.reasoning);

    const { required_specialization, complexity_level } = diagnosis;

    // Step 3: Discover
    const ranked_vets = await discoverAgent(farmer_lat, farmer_lng, required_specialization, urgency, complexity_level);
    await saveTrace('discover', { farmer_lat, farmer_lng, required_specialization, urgency, complexity_level }, { count: ranked_vets.length }, "Found nearby vets");

    // Step 4: Decide
    const decision = await decideAgent(ranked_vets, diagnosis, urgency);
    await saveTrace('decide', { ranked_vets_count: ranked_vets.length, diagnosis, urgency }, decision, decision.override_reason || "Selected top vet");

    // Step 5: Execute
    const topVet = decision.top_vet;
    let execute_result = null;
    
    if (topVet) {
      // Mock farmer data since it's not passed in input
      const farmer = {
        name: "Akram Khan", 
        phone: "03001234567", 
        farmer_id: "farmer_default"
      };
      
      // Mock pricing data or use defaults
      const pricing = { total_rs: topVet.base_visit_fee_rs || 1000 };
      
      // Pass case_id to diagnosis for the agent
      diagnosis.case_id = case_id;

      execute_result = await executeAgent(topVet, diagnosis, farmer, pricing);
      await saveTrace('execute', { topVet_id: topVet.vet_id, diagnosis }, execute_result, "Generated message and created booking");
    } else {
      execute_result = {
        status: "failed",
        reason: "No vet available"
      };
      await saveTrace('execute', { topVet_id: null }, execute_result, "Skipped execution because no vet was available");
    }

    return {
      listen_result,
      diagnosis,
      ranked_vets,
      decision,
      execute_result,
      trace_id
    };

  } catch (error) {
    console.error(`[ORCHESTRATOR] Error in workflow:`, error);
    await saveTrace('error', { input }, { error: error.message }, "Workflow failed");
    throw error;
  }
}

module.exports = { runVetraWorkflow };
