const express = require('express');
const router = express.Router();
const { diagnoseAgent } = require('../agents/diagnose_agent');

router.post('/', async (req, res) => {
  try {
    const { symptoms, animal_type, vision_findings } = req.body;
    
    if (!symptoms || !animal_type) {
      return res.status(400).json({ error: 'symptoms and animal_type required' });
    }
    
    const diagnosis = await diagnoseAgent(symptoms, animal_type, vision_findings || []);
    
    res.json({ success: true, diagnosis });
    
  } catch (error) {
    console.error('Diagnosis error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
