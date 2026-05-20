const { callGemini } = require('../utils/gemini_router');

async function visionAgent(imageBase64) {
  console.log(`[VISION] Starting analysis of image`);
  
  const prompt = `
    You are an expert AI veterinary assistant. Analyze the provided animal image.
    Extract the following information and return ONLY valid JSON:
    {
      "eye_condition": "description of eyes",
      "nasal_discharge": "description of any discharge",
      "gait": "posture or gait if visible",
      "body_condition": "overall body condition",
      "risk_signals": ["signal1", "signal2"],
      "image_quality": "good|poor",
      "visual_findings": ["finding1", "finding2"]
    }
    
    Rules:
    - Return ONLY valid JSON (no markdown block or explanation).
    - If the image quality is so poor you cannot see the animal clearly, set "image_quality": "poor".
    - Populate "visual_findings" with key concise observations (e.g., "Yellow discharge", "Eye redness") as requested.
  `;

  const imagePart = {
    inlineData: {
      data: imageBase64,
      mimeType: "image/jpeg" 
    }
  };
  
  console.log(`[VISION] Calling Gemini via router...`);
  const routerResult = await callGemini([prompt, imagePart]);
  
  if (!routerResult.success) {
    throw new Error(`Vision agent failed: ${routerResult.error}`);
  }
  
  let responseText = routerResult.data;
  // Clean up if Gemini adds markdown code blocks
  responseText = responseText.replace(/```json/g, '').replace(/```/g, '').trim();
  
  console.log(`[VISION] Parsing JSON response...`);
  return JSON.parse(responseText);
}

module.exports = { visionAgent };
