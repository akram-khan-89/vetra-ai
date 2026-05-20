const express = require('express');
const router = express.Router();
const { listenAgent } = require('../agents/listen_agent');
const { visionAgent } = require('../agents/vision_agent');

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

router.post('/image', async (req, res) => {
  try {
    const { image_base64, case_id } = req.body;
    
    if (!image_base64) {
      return res.status(400).json({ error: 'image_base64 is required' });
    }
    
    const result = await visionAgent(image_base64);
    
    res.json(result);
    
  } catch (error) {
    console.error('[VISION] Error in image route:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
