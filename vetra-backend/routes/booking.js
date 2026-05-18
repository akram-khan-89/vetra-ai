const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

// POST /api/v1/booking
router.post('/', async (req, res) => {
  try {
    const { vet_id, case_id, farmer_id, diagnosis, pricing, appointment_time } = req.body;

    if (!vet_id || !case_id || !farmer_id) {
      return res.status(400).json({ error: 'vet_id, case_id, and farmer_id are required' });
    }

    const db = admin.firestore();
    
    // Generate a timestamp-based booking ID
    const booking_id = `book_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;
    
    // Default appointment time to now + 2 hours if not provided
    const confirmed_time = appointment_time || new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString();

    const bookingData = {
      booking_id,
      vet_id,
      farmer_id,
      case_id,
      appointment_time: confirmed_time,
      status: "confirmed",
      pricing: pricing || {},
      whatsapp_sent: false,
      reminder_scheduled: true,
      created_at: admin.firestore.FieldValue.serverTimestamp()
    };

    // Save to Firestore
    await db.collection('bookings').doc(booking_id).set(bookingData);

    res.json({
      booking_id,
      confirmed_time,
      status: "confirmed",
      message: "Booking confirmed"
    });

  } catch (error) {
    console.error('[BOOKING ROUTE] Error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
