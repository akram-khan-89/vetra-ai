const { GoogleGenerativeAI } = require('@google/generative-ai');
const diseases = require('../data/diseases.json');
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function diagnoseAgent(symptoms, animalType, visionFindings = []) {
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-lite' });
  
  const prompt = `
    You are a professional livestock veterinarian in Pakistan.
    
    Animal type: ${animalType}
    Symptoms reported: ${symptoms.join(', ')}
    Visual findings from camera: ${visionFindings.join(', ') || 'none'}
    
    Based on these symptoms, diagnose the most likely disease.
    
    Return ONLY valid JSON (no markdown, no explanation):
    {
      "primary_diagnosis": "disease name in English",
      "confidence_percent": 78,
      "risk_score": 8,
      "complexity_level": 2,
      "urgency": "immediate|same_day|next_day|routine",
      "reasoning": "brief 1-sentence explanation",
      "differential": ["other possible disease 1", "other possible disease 2"],
      "vet_required": true,
      "home_care": ["step 1", "step 2"],
      "required_specialization": "dairy_cattle|small_ruminants|general"
    }
  `;
  
  const result = await model.generateContent(prompt);
  let text = result.response.text();
  
  // Clean up if Gemini adds markdown code blocks
  text = text.replace(/```json/g, '').replace(/```/g, '').trim();
  
  return JSON.parse(text);
}

module.exports = { diagnoseAgent };
