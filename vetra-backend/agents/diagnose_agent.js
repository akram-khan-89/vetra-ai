const { GoogleGenerativeAI } = require('@google/generative-ai');
const diseases = require('../data/diseases.json');
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function diagnoseAgent(symptoms, animalType, visionFindings = []) {
  console.log(`[DIAGNOSE] Starting diagnosis for animal: ${animalType}`);
  console.log(`[DIAGNOSE] Symptoms received: ${symptoms.join(', ')}`);
  console.log(`[DIAGNOSE] Vision findings: ${visionFindings.length > 0 ? visionFindings.join(', ') : 'none'}`);

  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-lite' });

  // Build a concise disease reference from the DB for context
  const diseaseContext = diseases.diseases
    .filter(d => d.animal_types.includes(animalType) || d.animal_types.includes('cattle'))
    .map(d => `- ${d.name}: symptoms [${d.key_symptoms.join(', ')}], urgency: ${d.urgency}, risk: ${d.risk_score}`)
    .join('\n');

  console.log(`[DIAGNOSE] Loaded ${diseases.diseases.length} diseases from DB, filtered relevant ones for context.`);

  const prompt = `
    You are a professional livestock veterinarian in Pakistan.
    
    Animal type: ${animalType}
    Symptoms reported: ${symptoms.join(', ')}
    Visual findings from camera: ${visionFindings.join(', ') || 'none'}
    
    Reference list of known livestock diseases in Pakistan:
    ${diseaseContext}
    
    Based on the symptoms and the reference list above, diagnose the most likely disease.
    
    Return ONLY valid JSON (no markdown, no explanation):
    {
      "primary_diagnosis": "disease name in English",
      "confidence_percent": 78,
      "risk_score": 8,
      "complexity_level": 2,
      "urgency": "immediate|same_day|next_day|routine",
      "reasoning": "brief 1-sentence explanation referencing the specific symptoms",
      "differential": ["other possible disease 1", "other possible disease 2"],
      "vet_required": true,
      "home_care": ["specific step 1", "specific step 2"],
      "required_specialization": "dairy_cattle|small_ruminants|general|large_animal_expert|reproductive"
    }
  `;

  console.log(`[DIAGNOSE] Calling Gemini API...`);
  const result = await model.generateContent(prompt);
  let text = result.response.text();
  console.log(`[DIAGNOSE] Received response from Gemini.`);

  // Strip markdown code fences if present
  text = text.replace(/```json/g, '').replace(/```/g, '').trim();

  console.log(`[DIAGNOSE] Parsing JSON response...`);
  const parsed = JSON.parse(text);
  console.log(`[DIAGNOSE] Diagnosis complete: ${parsed.primary_diagnosis} (${parsed.confidence_percent}% confidence)`);

  return parsed;
}

module.exports = { diagnoseAgent };
