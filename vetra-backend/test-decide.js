const { decideAgent } = require('./agents/decide_agent');
const vets = require('./data/vets.json').vets;

// Mock diagnosis object
const diagnosis = { 
  primary_diagnosis: 'bovine_pneumonia', 
  urgency: 'same_day',
  required_specialization: 'dairy_cattle' // Added this to help testing
};

// Mock distances for testing since vets.json doesn't have distance_km
const vetsWithDistance = vets.map((vet, index) => ({
  ...vet,
  distance_km: (index + 1) * 4 // 4km, 8km, 12km...
}));

decideAgent(vetsWithDistance, diagnosis, 'same_day').then(r => console.log(JSON.stringify(r, null, 2)));
