function calculateVetFee(vet, request, farmer, vets = []) {
  const base_fee = vet.base_visit_fee_rs || 0;
  const travel_fee = (vet.distance_km || 0) * 30;
  
  let urgency_fee = 0;
  switch (request.urgency) {
    case 'immediate': urgency_fee = 500; break;
    case 'same_day': urgency_fee = 200; break;
    case 'next_day': urgency_fee = 0; break;
    case 'routine': urgency_fee = 0; break;
  }
  
  let complexity_fee = 0;
  switch (request.complexity_level) {
    case 1: complexity_fee = 0; break;
    case 2: complexity_fee = 300; break;
    case 3: complexity_fee = 800; break;
  }
  
  const currentHour = new Date().getHours();
  const night_fee = (currentHour >= 21 || currentHour < 7) ? 400 : 0;
  
  const subtotal = base_fee + travel_fee + urgency_fee + complexity_fee + night_fee;
  
  const loyalty_multiplier = (farmer && farmer.total_bookings >= 3) ? 0.90 : 1.0;
  const total_rs = subtotal * loyalty_multiplier;
  const loyalty_discount_rs = subtotal - total_rs;
  
  let budget_alternative = null;
  if (request.budget_sensitive && vets.length > 0) {
    // Find cheapest vet based on base_visit_fee_rs
    budget_alternative = vets.reduce((prev, curr) => (prev.base_visit_fee_rs < curr.base_visit_fee_rs) ? prev : curr);
    // If the cheapest vet is the current vet, we don't need to suggest an alternative
    if (budget_alternative && budget_alternative.vet_id === vet.vet_id) {
      budget_alternative = null;
    }
  }
  
  return {
    base_fee,
    travel_fee,
    urgency_fee,
    complexity_fee,
    night_fee,
    loyalty_discount_rs,
    total_rs,
    budget_alternative
  };
}

module.exports = { calculateVetFee };
