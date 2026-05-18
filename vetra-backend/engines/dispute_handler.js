const admin = require('firebase-admin');

/**
 * Handles vet no-show scenario.
 * @param {string} booking_id 
 */
async function handleNoShow(booking_id) {
  console.log(`[DISPUTE] Handling no-show for booking: ${booking_id}`);
  const db = admin.firestore();
  
  try {
    await db.collection('bookings').doc(booking_id).update({ status: 'vet_no_show' });
  } catch (error) {
    console.error(`[DISPUTE] Failed to update booking ${booking_id}:`, error.message);
    // Continue anyway for simulation purposes
  }
  
  return {
    action: "replacement_vet_found",
    new_vet_name: "Dr. Ahmed Siddiqui",
    new_time: "11:00 AM",
    compensation_rs: 100,
    penalty: "Dr. Rashid reliability score -5 points"
  };
}

/**
 * Handles vet cancellation scenario.
 * @param {string} booking_id 
 * @param {string} vet_name 
 */
async function handleVetCancellation(booking_id, vet_name) {
  console.log(`[DISPUTE] Handling cancellation by vet for booking: ${booking_id}`);
  const db = admin.firestore();
  
  try {
    await db.collection('bookings').doc(booking_id).update({ status: 'cancelled_by_vet' });
  } catch (error) {
    console.error(`[DISPUTE] Failed to update booking ${booking_id}:`, error.message);
    // Continue anyway for simulation purposes
  }
  
  return {
    action: "auto_rescheduled",
    new_vet_name: "Dr. Zainab Malik",
    new_time: "Same day 11:30 AM",
    farmer_notified: true,
    penalty: "Late cancellation flag added"
  };
}

/**
 * Handles price dispute scenario.
 * @param {string} booking_id 
 * @param {number} quoted_rs 
 * @param {number} charged_rs 
 */
async function handlePriceDispute(booking_id, quoted_rs, charged_rs) {
  console.log(`[DISPUTE] Handling price dispute for booking: ${booking_id}`);
  
  const overage = charged_rs - quoted_rs;
  const credit_issued = Math.min(overage * 0.5, 500);
  
  return {
    action: "escalated",
    overage_rs: overage,
    credit_issued_rs: credit_issued,
    status: "under_review"
  };
}

module.exports = { handleNoShow, handleVetCancellation, handlePriceDispute };
