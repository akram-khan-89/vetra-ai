const express = require('express');
const router = express.Router();
const { runVetraWorkflow } = require('../orchestrator/antigravity_orchestrator');
const { executeAgent } = require('../agents/execute_agent');
const allVets = require('../data/vets.json').vets;

// POST /api/v1/workflow
router.post('/', async (req, res) => {
  try {
    const { text, farmer_lat, farmer_lng, vision_findings, vet, vet_id, diagnosis, pricing } = req.body;

    // Direct execution path if vet/vet_id is provided
    if (vet || vet_id) {
      let selectedVet = vet;
      if (!selectedVet && vet_id) {
        selectedVet = allVets.find(v => v.vet_id === vet_id);
      }

      if (!selectedVet) {
        return res.status(404).json({ error: 'Vet not found' });
      }

      // Ensure phone is normalized/assigned if missing or from the updated JSON
      const farmer = {
        name: "Akram Khan", 
        phone: "03001234567", 
        farmer_id: "farmer_default"
      };

      console.log(`[WORKFLOW ROUTE] Running executeAgent directly for vet ${selectedVet.name}`);
      const execute_result = await executeAgent(selectedVet, diagnosis || {}, farmer, pricing || {});
      
      return res.json({ success: true, data: execute_result });
    }

    if (!text || !farmer_lat || !farmer_lng) {
      return res.status(400).json({ error: 'text, farmer_lat, and farmer_lng are required' });
    }

    const result = await runVetraWorkflow({ text, farmer_lat, farmer_lng, vision_findings });

    res.json({ success: true, data: result });

  } catch (error) {
    console.error('[WORKFLOW ROUTE] Error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
