// test_gemini.js — Run this to verify Gemini works
require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function testGemini() {
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

  const prompt = `
    A Pakistani farmer said: "Meri bhains ko 3 din se bukhaar hai"
    
    Extract information and return ONLY this JSON:
    {
      "animal": "buffalo or cattle or other",
      "symptom": "what is wrong",
      "duration_days": 3,
      "language": "punjabi or urdu or english"
    }
  `;

  console.log('Calling Gemini API...');
  const result = await model.generateContent(prompt);
  console.log('Response:', result.response.text());
}

testGemini().catch(console.error);