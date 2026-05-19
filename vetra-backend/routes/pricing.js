const express = require('express');
const router = express.Router();
const { calculateVetFee } = require('../engines/pricing_engine');
const allVets = require('../data/vets.json').vets;

// POST /api/v1/pricing
router.post('/', async (req, res) => {
  try {
    let { vet, request, farmer, vets, vet_id, urgency, complexity_level, farmer_total_bookings, budget_sensitive } = req.body;

    // Build request structure if flat parameters were supplied
    if (!request) {
      request = {
        urgency: urgency || 'routine',
        complexity_level: complexity_level || 1,
        budget_sensitive: budget_sensitive === true || budget_sensitive === 'true'
      };
    }

    // Build farmer structure if flat parameters were supplied
    if (!farmer) {
      farmer = {
        total_bookings: farmer_total_bookings !== undefined ? parseInt(farmer_total_bookings) : 0
      };
    }

    // Resolve vet object from vet_id if vet was not passed
    if (!vet && vet_id) {
      // Find the vet from data/vets.json
      const foundVet = allVets.find(v => v.vet_id === vet_id);
      if (foundVet) {
        // If we found the vet, we copy it. In a real app we'd get distance from GPS,
        // let's assign a mock distance or use current if present
        vet = { ...foundVet };
        // We'll give it a mock distance_km if not set, so travel fee works
        if (vet.distance_km === undefined) {
          vet.distance_km = 8.0; // default mock distance from requirements
        }
      }
    }

    if (!vet) {
      return res.status(400).json({ error: 'vet or vet_id is required' });
    }

    // If vets is not provided and budget_sensitive is true, populate it
    if (!vets && request.budget_sensitive) {
      vets = allVets.map((v, index) => ({
        ...v,
        distance_km: vet.distance_km !== undefined ? vet.distance_km + (index * 2) - 2 : 10.0
      }));
    }

    const pricing = calculateVetFee(
      vet, 
      request, 
      farmer, 
      vets || []
    );

    res.json({ success: true, data: pricing });

  } catch (error) {
    console.error('[PRICING ROUTE] Error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
