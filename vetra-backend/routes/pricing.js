const express = require('express');
const router = express.Router();
const { calculateVetFee } = require('../engines/pricing_engine');

// POST /api/v1/pricing
router.post('/', async (req, res) => {
  try {
    const { vet, request, farmer, vets } = req.body;

    if (!vet || !request) {
      return res.status(400).json({ error: 'vet and request objects are required' });
    }

    const pricing = calculateVetFee(
      vet, 
      request, 
      farmer || { total_bookings: 0 }, 
      vets || []
    );

    res.json({ success: true, data: pricing });

  } catch (error) {
    console.error('[PRICING ROUTE] Error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
