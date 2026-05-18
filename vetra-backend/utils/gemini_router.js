const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const MODELS = {
  PRIMARY: 'gemini-2.5-flash',
  FALLBACK: 'gemini-3.1-flash-lite',
  EMERGENCY: 'gemini-2.5-flash-lite'
};

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Calls Gemini API with fallback models and retry logic.
 * @param {string} prompt - The prompt to send to Gemini.
 * @param {object} options - Additional options.
 * @returns {object} - Unified response format.
 */
async function callGemini(prompt, options = {}) {
  const isUrgent = prompt.toLowerCase().includes('urgent') || prompt.toLowerCase().includes('emergency');
  
  let modelsToTry = [MODELS.PRIMARY, MODELS.FALLBACK];
  if (!isUrgent) {
    modelsToTry.push(MODELS.EMERGENCY);
  } else {
    console.log(`[GEMINI ROUTER] Urgent prompt detected. Skipping emergency model.`);
  }

  console.log(`[GEMINI ROUTER] Starting request.`);

  let lastError = null;
  for (const modelName of modelsToTry) {
    console.log(`[GEMINI ROUTER] Trying model: ${modelName}`);
    const model = genAI.getGenerativeModel({ model: modelName });
    
    let retries = 0;
    const maxRetries = 2;
    let backoff = 1000; // Start with 1s
    
    while (retries <= maxRetries) {
      try {
        const result = await model.generateContent(prompt);
        const text = result.response.text();
        
        if (!text) {
          throw new Error("Empty response from Gemini");
        }
        
        console.log(`[GEMINI ROUTER] Success with model: ${modelName}`);
        return {
          success: true,
          model_used: modelName,
          data: text
        };
        
      } catch (error) {
        console.error(`[GEMINI ROUTER] Error with model ${modelName} (Attempt ${retries + 1}):`, error.message);
        lastError = error;
        
        if (retries < maxRetries) {
          console.log(`[GEMINI ROUTER] Retrying in ${backoff / 1000}s...`);
          await sleep(backoff);
          backoff *= 2; // 1s, 2s, 4s
          retries++;
        } else {
          console.log(`[GEMINI ROUTER] Model ${modelName} failed after ${maxRetries} retries.`);
          break; // Move to next model
        }
      }
    }
  }
  
  console.error(`[GEMINI ROUTER] All models failed.`);
  return {
    success: false,
    error: lastError ? `All models failed. Last error: ${lastError.message}` : "All Gemini models failed",
    fallback_mode: true
  };
}

module.exports = { callGemini };
