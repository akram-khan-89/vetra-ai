const express = require('express');
const router = express.Router();
const { listenAgent } = require('../agents/listen_agent');

router.post('/voice', async (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text) {
      return res.status(400).json({ error: 'text is required' });
    }
    
    const result = await listenAgent(text);
    
    res.json({ success: true, data: result });
    
  } catch (error) {
    console.error('[LISTEN] Error in intake route:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
