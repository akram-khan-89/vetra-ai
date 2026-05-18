const express = require('express');
const router = express.Router();
const { handleNoShow, handleVetCancellation, handlePriceDispute } = require('../engines/dispute_handler');

// POST /api/v1/dispute/no-show
router.post('/no-show', async (req, res) => {
  try {
    const { booking_id } = req.body;
    if (!booking_id) {
      return res.status(400).json({ error: 'booking_id is required' });
    }
    
    const result = await handleNoShow(booking_id);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/v1/dispute/cancellation
router.post('/cancellation', async (req, res) => {
  try {
    const { booking_id, vet_name } = req.body;
    if (!booking_id) {
      return res.status(400).json({ error: 'booking_id is required' });
    }
    
    const result = await handleVetCancellation(booking_id, vet_name);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/v1/dispute/price-dispute
router.post('/price-dispute', async (req, res) => {
  try {
    const { booking_id, quoted_rs, charged_rs } = req.body;
    if (!booking_id || quoted_rs === undefined || charged_rs === undefined) {
      return res.status(400).json({ error: 'booking_id, quoted_rs, and charged_rs are required' });
    }
    
    const result = await handlePriceDispute(booking_id, quoted_rs, charged_rs);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
