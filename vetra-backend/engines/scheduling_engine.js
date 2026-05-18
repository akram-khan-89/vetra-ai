const admin = require('firebase-admin');

function checkAvailability(vet, requestedTime, existingBookings = []) {
  const requestedDate = new Date(requestedTime);
  // Total conflict window: 60 min (service) + 30 min (travel) + 15 min (buffer) = 105 min
  const totalConflictMinutes = 105; 
  
  for (const booking of existingBookings) {
    const bookingDate = new Date(booking.appointment_time);
    const diffMs = Math.abs(requestedDate - bookingDate);
    const diffMins = diffMs / (1000 * 60);
    
    if (diffMins < totalConflictMinutes) {
      return {
        available: false,
        next_available_slot: getNextAvailableSlot(vet),
        conflict_reason: `Time conflict with an existing booking within the 105-minute buffer.`
      };
    }
  }
  
  return {
    available: true,
    next_available_slot: null,
    conflict_reason: null
  };
}

function getNextAvailableSlot(vet) {
  // Default for MVP as requested
  return "Tomorrow 10:00 AM"; 
}

async function createBooking(vet_id, case_id, farmer_id, appointment_time, pricing) {
  const db = admin.firestore();
  
  // Generate a timestamp-based booking ID
  const booking_id = `book_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;
  
  const bookingData = {
    booking_id,
    vet_id,
    farmer_id,
    case_id,
    appointment_time,
    status: "confirmed",
    pricing: pricing || {},
    whatsapp_sent: false,
    reminder_scheduled: true,
    created_at: admin.firestore.FieldValue.serverTimestamp()
  };

  // Save to Firestore
  await db.collection('bookings').doc(booking_id).set(bookingData);
  
  return { booking_id, appointment_time };
}

module.exports = { checkAvailability, getNextAvailableSlot, createBooking };
