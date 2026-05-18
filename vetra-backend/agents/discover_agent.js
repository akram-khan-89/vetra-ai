const fs = require('fs');
const path = require('path');

// Haversine formula to calculate distance between two points on Earth
function haversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) *
    Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

async function discoverAgent(
  farmer_lat,
  farmer_lng,
  required_specialization,
  urgency,
  complexity_level
) {
  // normalize inputs
  farmer_lat = Number(farmer_lat);
  farmer_lng = Number(farmer_lng);
  complexity_level = Number(complexity_level);

  console.log(`[DISCOVER] Start (${farmer_lat}, ${farmer_lng})`);
  console.log(`[DISCOVER] specialty=${required_specialization}, urgency=${urgency}, complexity=${complexity_level}`);

  // load JSON safely
  const vetsPath = path.join(__dirname, '../data/vets.json');
  const vetsData = JSON.parse(fs.readFileSync(vetsPath, 'utf8'));

  const vetsArray = Array.isArray(vetsData)
    ? vetsData
    : vetsData.vets;

  if (!vetsArray || !Array.isArray(vetsArray)) {
    throw new Error("Invalid vets.json structure");
  }

  // map + distance
  const withDistance = vetsArray.map(vet => {
    const distance = haversineDistance(
      farmer_lat,
      farmer_lng,
      vet.location.lat,
      vet.location.lng
    );

    return {
      ...vet,
      distance_km: distance
    };
  });

  // normalize urgency
  const isEmergency = urgency === 'immediate' || urgency === 'same_day';

  // filter
  const filteredVets = withDistance.filter(vet => {
    const isSpecialist = required_specialization
      ? vet.specialties?.map(s => s.toLowerCase())
        .includes(required_specialization.toLowerCase())
      : true;

    const meetsComplexity =
      complexity_level
        ? vet.complexity_level >= complexity_level
        : true;

    const withinNormalRange = vet.distance_km <= 30;
    const withinEmergencyRange = vet.distance_km <= 50;
    const isEmergencyVet = vet.emergency_24hr === true;

    // normal match
    if (isSpecialist && meetsComplexity && withinNormalRange) {
      return true;
    }

    // emergency match
    if (isEmergency && isEmergencyVet && withinEmergencyRange) {
      return true;
    }

    return false;
  });

  // sort by distance
  filteredVets.sort((a, b) => a.distance_km - b.distance_km);

  console.log(`[DISCOVER] Found ${filteredVets.length} vets`);

  return filteredVets;
}

module.exports = { discoverAgent };