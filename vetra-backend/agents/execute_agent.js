const { callGemini } = require('../utils/gemini_router');
const { createBooking } = require('../engines/scheduling_engine');

async function executeAgent(topVet, diagnosis, farmer, pricing) {
  console.log(`[EXECUTE] Starting execution for vet: ${topVet.name}`);

  const prompt = `
    You are an AI assistant for Vetra AI, a livestock health service in Pakistan.
    Generate a professional WhatsApp message in Urdu (Urdu script) to be sent to a veterinarian about a new booking.
    
    Details to include:
    - Vet Name: ${topVet.name}
    - Farmer Name: ${farmer.name}
    - Animal Type: ${diagnosis.animal_type}
    - Diagnosis: ${diagnosis.primary_diagnosis}
    - Confidence: ${diagnosis.confidence_percent}%
    - Urgency: ${diagnosis.urgency}
    - Farmer Phone: ${farmer.phone}
    
    Keep it under 100 words. Be professional, clear, and polite.
    Return ONLY the Urdu message text. Do not include any English translations or other text.
  `;

  console.log('[EXECUTE] Calling Gemini via router...');
  let message_urdu = "";
  try {
    const routerResult = await callGemini(prompt);
    
    if (!routerResult.success) {
      throw new Error(`Execute agent failed: ${routerResult.error}`);
    }
    
    message_urdu = routerResult.data.trim();
    // Strip any potential markdown code fences if Gemini adds them
    message_urdu = message_urdu.replace(/^```[a-zA-Z]*\n/gm, '').replace(/```$/gm, '').trim();
  } catch (error) {
    console.error('[EXECUTE] Gemini API Error:', error.message);
    message_urdu = `محترم ڈاکٹر ${topVet.name}، آپ کے لیے ایک نیا کیس ہے۔ فارمر: ${farmer.name}، جانور: ${diagnosis.animal_type}۔`;
  }

  // Step 2: Build WhatsApp deeplink
  // Ensure we remove leading zero and handle format
  const cleanPhone = topVet.phone.replace(/^0/, '');
  const whatsapp_link = `https://wa.me/92${cleanPhone}?text=${encodeURIComponent(message_urdu)}`;

  // Step 3: Create booking
  // Default appointment time to now + 2 hours
  const confirmed_time = new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString();
  
  console.log('[EXECUTE] Creating booking in Firestore...');
  const booking = await createBooking(
    topVet.vet_id, 
    diagnosis.case_id || `case_${Date.now()}`, 
    farmer.farmer_id || `farmer_${Date.now()}`, 
    confirmed_time, 
    pricing
  );

  return {
    message_urdu,
    whatsapp_link,
    booking_id: booking.booking_id,
    confirmed_time: booking.appointment_time,
    reminder_note: "Reminder set for 30 min before appointment",
    status: "confirmed"
  };
}

module.exports = { executeAgent };
