const express = require('express');
const router = express.Router();
const { diagnoseAgent } = require('../agents/diagnose_agent');

// POST /api/v1/diagnose
router.post('/', async (req, res) => {
  try {
    // Defensive check for missing body
    if (!req.body) {
      return res.status(400).json({ error: 'Request body is missing' });
    }

    // Safe destructuring with defaults
    const { symptoms = [], animal_type, vision_findings = [] } = req.body || {};

    if (!symptoms || !Array.isArray(symptoms) || symptoms.length === 0) {
      return res.status(400).json({ error: 'symptoms must be a non-empty array' });
    }

    if (!animal_type) {
      return res.status(400).json({ error: 'animal_type is required' });
    }

    const diagnosis = await diagnoseAgent(symptoms, animal_type, vision_findings);

    res.json({ success: true, diagnosis });

  } catch (error) {
    console.error('[DIAGNOSE ROUTE] Error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
