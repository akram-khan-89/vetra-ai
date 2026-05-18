async function decideAgent(vets, diagnosis, urgency) {
  console.log(`[DECIDE] Starting decision for ${vets.length} vets`);
  
  if (!vets || vets.length === 0) {
    console.log(`[DECIDE] No vets to score.`);
    return {
      top_vet: null,
      alternatives: [],
      override_happened: false,
      override_reason: "No vets available"
    };
  }

  const req_spec = diagnosis.required_specialization;
  const disease = diagnosis.primary_diagnosis;

  const scoredVets = vets.map(vet => {
    // 1. Distance score: 0-5km=100, 5-10km=80, 10-20km=60, 20-30km=40
    let distance_score = 0;
    if (vet.distance_km <= 5) distance_score = 100;
    else if (vet.distance_km <= 10) distance_score = 80;
    else if (vet.distance_km <= 20) distance_score = 60;
    else if (vet.distance_km <= 30) distance_score = 40;
    
    // 2. Specialization match: exact=100, general=60, mismatch=0
    let spec_score = 0;
    if (vet.specialties && req_spec && vet.specialties.map(s => s.toLowerCase()).includes(req_spec.toLowerCase())) {
      spec_score = 100;
    } else if (vet.specialties && vet.specialties.map(s => s.toLowerCase()).includes('general')) {
      spec_score = 60;
    }
    
    // 3. Reliability percent
    const reliability = vet.reliability_percent || 0;
    
    // 4. Availability score: available_now=100, not=0
    const avail_score = vet.available_now ? 100 : 0;
    
    // 5. Rating score: weighted_rating_30days * 20
    const rating_score = (vet.weighted_rating_30days || 0) * 20;
    
    // 6. Disease experience: min(cases/50, 1) * 100
    const cases = (vet.disease_cases && vet.disease_cases[disease]) || 0;
    const exp_score = Math.min(cases / 50, 1) * 100;
    
    // 7. Price fit: 100 if affordable, less if over budget
    // Assuming a default budget of 1000 Rs since none is provided
    const budget = 1000;
    const price_score = vet.base_visit_fee_rs <= budget ? 100 : Math.max(0, 100 - (vet.base_visit_fee_rs - budget) / 10);
    
    // 8. Cancellation safety: 100 - cancellation_rate
    const cancel_safety = 100 - (vet.cancellation_rate || 0);
    
    // Calculate total weighted score
    const total_score = 
      distance_score * 0.20 +
      spec_score * 0.20 +
      reliability * 0.15 +
      avail_score * 0.15 +
      rating_score * 0.12 +
      exp_score * 0.10 +
      price_score * 0.05 +
      cancel_safety * 0.03;
      
    console.log(`[DECIDE] Vet ${vet.name}: Total=${total_score.toFixed(2)}, Dist=${distance_score}, Spec=${spec_score}, Rel=${reliability}, Avail=${avail_score}, Rat=${rating_score.toFixed(2)}, Exp=${exp_score.toFixed(2)}, Price=${price_score}, Cancel=${cancel_safety}`);
    
    return { ...vet, total_score, distance_score, spec_score, avail_score, rating_score, exp_score, price_score, cancel_safety };
  });
  
  // Sort by score descending
  scoredVets.sort((a, b) => b.total_score - a.total_score);
  
  const top_vet = scoredVets[0];
  const alternatives = scoredVets.slice(1, 3);
  
  // Find the nearest vet to check for override
  const nearestVet = scoredVets.reduce((prev, curr) => (prev.distance_km < curr.distance_km) ? prev : curr);
  
  const override_happened = nearestVet.vet_id !== top_vet.vet_id;
  let override_reason = "";
  if (override_happened) {
    override_reason = `Nearest vet ${nearestVet.name} (${nearestVet.distance_km.toFixed(2)}km) was not chosen because ${top_vet.name} scored higher (${top_vet.total_score.toFixed(2)} vs ${nearestVet.total_score.toFixed(2)}) based on other factors.`;
  }
  
  return {
    top_vet,
    alternatives,
    override_happened,
    override_reason
  };
}

module.exports = { decideAgent };
