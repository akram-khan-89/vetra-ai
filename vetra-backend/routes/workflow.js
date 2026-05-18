const express = require('express');
const router = express.Router();
const { runVetraWorkflow } = require('../orchestrator/antigravity_orchestrator');

// POST /api/v1/workflow
router.post('/', async (req, res) => {
  try {
    const { text, farmer_lat, farmer_lng, vision_findings } = req.body;

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
