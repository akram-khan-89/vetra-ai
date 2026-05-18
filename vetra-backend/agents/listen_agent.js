const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function listenAgent(text) {
  console.log(`[LISTEN] Starting analysis for input: "${text}"`);
  
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-lite' });
  
  const prompt = `
    You are an expert AI veterinary triage assistant in Pakistan. Your job is to listen to a farmer describing their animal's health issues and perform clinical intake and enrichment. You do NOT diagnose diseases.
    
    The input text may be in Punjabi, Urdu, Roman Urdu, or English.
    
    Input Text: "${text}"
    
    Analyze the text and extract the following information. Return ONLY valid JSON (no markdown, no explanation):
    {
      "animal_type": "cow|buffalo|goat|sheep|poultry|unknown",
      "symptoms": ["explicit_symptom", "implied_symptom (possible)"],
      "duration_days": 3, 
      "urgency": "immediate|same_day|within_24h|routine",
      "language_detected": "Urdu|Punjabi|Roman Urdu|English",
      "confidence": 65,
      "completeness_score": 40,
      "needs_clarification": true,
      "clarification_question_urdu": "اردو میں سوال پوچھیں"
    }
    
    Rules for extraction and enrichment:
    1. **Symptoms**: Extract both explicit symptoms mentioned and implied symptoms that are clinically likely given the context. Mark implied symptoms with "(possible)". Example: "fever in buffalo for 3 days" -> ["fever", "weakness (possible)", "loss of appetite (possible)"].
    2. **Medical Reasoning**: First enrich the clinical picture by inferring implied symptoms before mapping. Do NOT jump directly to diagnosis.
    3. **Confidence**: Do NOT be overconfident. Base confidence on the number of symptoms detected, clarity of input, and presence of measurable data. Typical range should be 50-85%.
    4. **Completeness Score**: Rate from 0 to 100 based on how complete the clinical picture is. Consider if vitals (temperature), appetite, behavior, and duration are all provided.
    5. **Urgency**: Be realistic. "same_day" only for severe/multi-symptom cases. Otherwise use "within_24h" or "routine".
    6. **Needs Clarification**: If confidence is below 70 or completeness_score is below 60, set to true and provide a specific clarification question in Urdu.
    7. **Constraints**: Do NOT hallucinate or predict any disease names in this layer.
  `;
  
  console.log(`[LISTEN] Calling Gemini API...`);
  const result = await model.generateContent(prompt);
  let responseText = result.response.text();
  
  console.log(`[LISTEN] Received response from Gemini.`);
  
  // Clean up if Gemini adds markdown code blocks
  responseText = responseText.replace(/```json/g, '').replace(/```/g, '').trim();
  
  console.log(`[LISTEN] Parsing JSON response...`);
  return JSON.parse(responseText);
}

module.exports = { listenAgent };
