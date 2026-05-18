const express = require('express');
const router = express.Router();
const { discoverAgent } = require('../agents/discover_agent');

// GET /api/v1/vets/nearby
router.get('/nearby', async (req, res) => {
  try {
    const { lat, lng, specialization, urgency, complexity } = req.query;

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

module.exports = router;
