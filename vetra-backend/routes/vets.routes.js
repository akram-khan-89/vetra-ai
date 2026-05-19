const express = require('express');
const router = express.Router();
const { discoverAgent } = require('../agents/discover_agent');
const { decideAgent } = require('../agents/decide_agent');

// GET /api/v1/vets/nearby
router.get('/nearby', async (req, res) => {
  try {
    const { lat, lng, urgency, complexity } = req.query;
    const specialization = req.query.specialization || req.query.specialty;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'Latitude and longitude are required' });
    }

    const farmer_lat = parseFloat(lat);
    const farmer_lng = parseFloat(lng);
    const comp_level = parseInt(complexity) || 1;

    console.log(`[DISCOVER ROUTE] Received request for location (${farmer_lat}, ${farmer_lng})`);
    
    const nearbyVets = await discoverAgent(
      farmer_lat, 
      farmer_lng, 
      specialization, 
      urgency, 
      comp_level
    );

    res.json({ success: true, data: nearbyVets });
  } catch (error) {
    console.error('[DISCOVER ROUTE] Error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

// POST /api/v1/vets/decide
router.post('/decide', async (req, res) => {
  try {
    const { vets = [], diagnosis, urgency } = req.body || {};

    if (!diagnosis) {
      return res.status(400).json({ error: 'diagnosis is required' });
    }

    console.log(`[DECIDE ROUTE] Received request to decide among ${vets.length} vets`);

    const decision = await decideAgent(vets, diagnosis, urgency);

    res.json({ success: true, data: decision });
  } catch (error) {
    console.error('[DECIDE ROUTE] Error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
