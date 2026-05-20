const { callGemini } = require('../utils/gemini_router');
const diseases = require('../data/diseases.json');
require('dotenv').config();

const HOME_CARE_URDU_MAP = {
  "isolation": "بیمار جانور کو دوسرے جانوروں سے الگ (قرنطینہ) کریں",
  "strict_isolation": "بیمار جانور کو فوری طور پر بالکل الگ تھلگ رکھیں",
  "isolate": "بیمار جانور کو تندرست جانوروں سے فورا الگ کریں",
  "isolate_body": "جانور کی لاش کو دوسرے تندرست جانوروں کی پہنچ سے الگ رکھیں",
  "isolate_aborted_animal": "اسقاط حمل والی گائے کو دوسرے جانوروں سے فورا الگ کریں",
  "immediate_isolation": "بیمار جانور کو فوری طور پر دوسرے جانوروں سے الگ کریں",
  "paracetamol": "درد اور بخار کو کم کرنے کے لیے پیراسیٹامول یا متعلقہ دوا دیں",
  "electrolyte_water": "جانور کو نمکیاتی پانی یا او آر ایس (ORS) پلائیں",
  "electrolytes": "پانی میں الیکٹرولائٹس (نمکیات) ملا کر جانور کو پلائیں",
  "ORS_solution": "او آر ایس (ORS) یا نمک اور چینی کا محلول بنا کر پلائیں",
  "fluids": "پانی اور نمکیات کا وافر استعمال یقینی بنائیں",
  "oral_electrolytes": "جانور کو منہ کے ذریعے الیکٹرولائٹس اور او آر ایس محلول دیں",
  "keep_warm": "جانور کو خشک، گرم اور ہوا دار جگہ پر رکھیں",
  "cold_compress": "سوجے ہوئے تھنوں پر ٹھنڈے پانی کی پٹی یا برف سے ٹکور کریں",
  "frequent_milking": "تھنوں سے بار بار اور مکمل دودھ نکالیں تاکہ سوزش کم ہو",
  "hoof_cleaning": "کھر کو صاف پانی سے اچھی طرح دھویں",
  "iodine_wash": "کھر کے زخموں کو جراثیم کش آیوڈین محلول سے دھوئیں",
  "keep_dry": "جانور کے بیٹھنے کی جگہ کو بالکل خشک اور صاف رکھیں",
  "mouth_cleaning": "جانور کے منہ کو ہلکے نمکین پانی یا لال دوا (KMnO4) سے دھوئیں",
  "soft_food": "جانور کو نرم چارہ، دلیا یا آسانی سے ہضم ہونے والی خوراک دیں",
  "soft_leaves": "جانور کو کھانے کے لیے درختوں کے نرم پتے اور نرم گھاس دیں",
  "soft_food_or_fluids": "نرم چارہ اور پینے کے لیے نیم گرم پانی یا نمکیاتی محلول دیں",
  "walk_animal": "گیس اور ہاضمہ بہتر کرنے کے لیے جانور کو تھوڑا چلائیں پھرائیں",
  "no_water_for_now": "ابھی کے لیے جانور کو پانی پینے سے روکیں",
  "massage_flank": "پیٹ کے بائیں حصے (کھبے پاسے) پر نیچے سے اوپر ہلکا مساج کریں",
  "tick_removal": "جانور کے جسم سے چچڑیوں کو ہاتھ سے یا چمٹی سے احتیاط سے اتاریں",
  "tick_control": "چچڑیوں کے خاتمے کے لیے جانور کے جسم اور باڑے میں اسپرے کریں",
  "fly_control": "مکھیوں اور مچھروں سے بچاؤ کے لیے باڑے میں دھواں یا دوا کا اسپرے کریں",
  "wound_care": "زخموں کو صاف رکھیں اور جراثیم کش مرہم یا نیلا تھوتھا لگائیں",
  "shade": "گرمی سے بچانے کے لیے جانور کو سائے تلے باندھیں",
  "cool_water": "پینے کے لیے تازہ اور ٹھنڈا پانی ہر وقت دستیاب رکھیں",
  "fan": "ہوا کی آمد و رفت کے لیے پنکھا چلائیں",
  "wetting_body": "دن میں دو سے تین بار جانور کے جسم پر ٹھنڈا پانی ڈالیں",
  "do_not_touch_without_gloves": "دستانے پہنے بغیر بیمار جانور یا لاش کو ہاتھ مت لگائیں",
  "do_not_open_carcass": "مردہ جانور کی لاش کا پیٹ ہرگز نہ پھاڑیں تاکہ جراثیم نہ پھیلیں",
  "use_gloves_when_handling": "بیمار جانور کی دیکھ بھال کے دوران ربڑ کے دستانے لازمی پہنیں",
  "dispose_fetus_safely": "ضائع ہونے والے بچے اور جیر کو زمین میں گہرا گڑھا کھود کر چونا ڈال کر دبائیں",
  "keep_in_dark_quiet_place": "جانور کو اندھیرے، پرسکون اور پرشور ماحول سے دور رکھیں",
  "soft_bedding": "جانور کے نیچے نرم اور خشک بستر (توری یا پرالی) بچھائیں",
  "keep_away_from_marshy_areas": "جانوروں کو دلدلی، کیچڑ اور کھڑے گندے پانی والی جگہوں پر مت لے جائیں",
  "clean_environment": "جانور کے رہنے کی جگہ کو بالکل صاف ستھرا اور ہوادار رکھیں",
  "clean_bedding": "نیچے بچھانے والا چارہ یا بستر روزانہ تبدیل اور صاف رکھیں",
  "clean_surroundings": "باڑے کے ارد گرد کی صفائی کا خاص خیال رکھیں تاکہ مکھی مچھر پیدا نہ ہوں",
  "sunlight": "جلد کی بیماریوں کی صورت میں جانور کو کچھ دیر دھوپ میں باندھیں",
  "iodine_application": "تاثرہ جلد یا زخموں پر آیوڈین محلول لگائیں",
  "manual_removal_if_few": "اگر چچڑیاں کم تعداد میں ہوں تو ہاتھ سے نکالیں اور جلا دیں",
  "eye_wash": "آنکھوں کو صاف اور ٹھنڈے پانی کے چھینٹوں سے دھوئیں",
  "bottle_feed_kids": "بکری کے بچوں کو فیڈر یا بوتل کے ذریعے صاف دودھ پلائیں",
  "wear_gloves": "کام شروع کرنے سے پہلے دستانے پہنیں",
  "offer_molasses": "جانور کو فوری طاقت کے لیے گڑ کا پانی یا شیرہ پلائیں",
  "high_energy_feed": "دودھ دینے والے جانوروں کو زیادہ توانائی والی معیاری ونڈہ خوراک دیں",
  "do_not_pull_membranes": "بچہ دانی سے باہر لٹکتی جیر کو زبردستی مت کھینچیں",
  "monitor_temperature": "جانور کا بخار (تھرمامیٹر سے) باقاعدگی سے چیک کریں",
  "keep_clean_and_moist": "باہر نکلے ہوئے عضو (پچھاوے) کو بالکل صاف اور گیلے تولیے سے ڈھانپ کر رکھیں",
  "wrap_in_wet_towel": "بچہ دانی کو گیلے اور صاف تولیے میں لپیٹیں تاکہ جراثیم اور رگڑ سے بچ سکے",
  "keep_animal_calm": "جانور کو پرسکون رکھیں اور اسے زیادہ ہلنے جلنے مت دیں",
  "do_not_pull_blindly": "بچہ پیدا ہوتے وقت اندھا دھند طاقت سے مت کھینچیں",
  "lubricate_with_clean_soap": "پیدائش کی نالی میں صاف صابن کا پانی یا سرسوں کا تیل ڈال کر اسے چکنا کریں",
  "stop_milk": "بیمار بچھڑے کو کچھ دیر کے لیے ماں کا دودھ پلانا بند کر کے صرف الیکٹرولائٹس دیں",
  "clean_navel_with_iodine": "نوزائیدہ بچے کی ناف کو دن میں دو بار آیوڈین محلول سے دھوئیں",
  "remove_grain": "جانور کے سامنے سے ہر قسم کا اناج اور ونڈہ فوری ہٹا لیں",
  "offer_hay": "جانور کو کھانے کے لیے صرف خشک گھاس یا ہری لوسن دیں",
  "baking_soda_in_water": "تیزابیت ختم کرنے کے لیے پانی میں 50 گرام میٹھا سوڈا (بیکنگ سوڈا) ملا کر پلائیں",
  "confine_animal": "جانور کی نقل و حرکت روک دیں اور اسے آرام دہ جگہ پر باندھیں",
  "elevate_front_legs": "جانور کے بیٹھنے کا رخ ایسا رکھیں کہ اس کے اگلے پاؤں پچھلے حصوں سے تھوڑے اونچے ہوں"
};

async function diagnoseAgent(symptoms, animalType, visionFindings = []) {
  console.log(`[DIAGNOSE] Starting diagnosis for animal: ${animalType}`);
  console.log(`[DIAGNOSE] Symptoms received: ${symptoms.join(', ')}`);
  console.log(`[DIAGNOSE] Vision findings: ${visionFindings.length > 0 ? visionFindings.join(', ') : 'none'}`);

  // Build a concise disease reference from the DB for context
  const diseaseContext = diseases.diseases
    .filter(d => d.animal_types.includes(animalType) || d.animal_types.includes('cattle'))
    .map(d => `- ${d.name} (Urdu: ${d.urdu_name || 'نامعلوم'}): symptoms [${d.key_symptoms.join(', ')}], urgency: ${d.urgency}, risk: ${d.risk_score}`)
    .join('\n');

  console.log(`[DIAGNOSE] Loaded ${diseases.diseases.length} diseases from DB, filtered relevant ones for context.`);

  const prompt = `
    You are a professional livestock veterinarian in Pakistan.
    
    Animal type: ${animalType}
    Symptoms reported: ${symptoms.join(', ')}
    Visual findings from camera: ${visionFindings.join(', ') || 'none'}
    
    Reference list of known livestock diseases in Pakistan:
    ${diseaseContext}
    
    Based on the symptoms and the reference list above, diagnose the most likely disease.
    
    Return ONLY valid JSON (no markdown, no explanation):
    {
      "primary_diagnosis": "disease name in English",
      "disease_name_urdu": "بیماری کا نام اردو میں (e.g. پی پی آر, منہ کھر, تھیلریا etc.)",
      "confidence_percent": 78,
      "risk_score": 8,
      "complexity_level": 2,
      "urgency": "immediate|same_day|next_day|routine",
      "reasoning": "brief 1-sentence explanation referencing the specific symptoms",
      "differential": ["other possible disease 1", "other possible disease 2"],
      "vet_required": true,
      "home_care": ["specific step 1 in English", "specific step 2 in English"],
      "home_care_urdu": ["مخصوص قدم 1 اردو میں", "مخصوص قدم 2 اردو میں"],
      "required_specialization": "dairy_cattle|small_ruminants|general|large_animal_expert|reproductive"
    }
    
    IMPORTANT: 
    - disease_name_urdu MUST be the actual Urdu name of the diagnosed disease. Use the Urdu names provided in the reference list where possible. Never write "نامعلوم بیماری".
    - home_care_urdu MUST be the Urdu translation of each home_care step, written in simple Urdu for a Pakistani farmer.
  `;

  console.log(`[DIAGNOSE] Calling Gemini via router...`);
  const routerResult = await callGemini(prompt);
  
  if (!routerResult.success) {
    throw new Error(`Diagnose agent failed: ${routerResult.error}`);
  }
  
  let text = routerResult.data;
  console.log(`[DIAGNOSE] Received response from Gemini (Model: ${routerResult.model_used}).`);

  // Strip markdown code fences if present
  text = text.replace(/```json/g, '').replace(/```/g, '').trim();

  console.log(`[DIAGNOSE] Parsing JSON response...`);
  const parsed = JSON.parse(text);

  // Find matching disease from local DB by English name, ID, or acronym
  const primaryDiagLower = (parsed.primary_diagnosis || '').toLowerCase().trim();
  let match = diseases.diseases.find(d => {
    const dbNameLower = d.name.toLowerCase().trim();
    const dbIdLower = d.id.toLowerCase().trim();
    
    // 1. Direct match on name or ID
    if (dbNameLower === primaryDiagLower || dbIdLower === primaryDiagLower) return true;
    
    // 2. Parentheses/Acronym handling: e.g. "PPR (Goat Plague)" match "ppr" or "goat plague"
    const nameWithoutParen = dbNameLower.replace(/\s*\([^)]*\)\s*/g, '').trim();
    if (nameWithoutParen === primaryDiagLower) return true;
    
    const parenContentMatch = d.name.match(/\(([^)]+)\)/);
    if (parenContentMatch && parenContentMatch[1].toLowerCase().trim() === primaryDiagLower) return true;
    
    // 3. Substring check: e.g. "Lumpy Skin Disease" vs "Lumpy Skin Disease (LSD)"
    if (dbNameLower.includes(primaryDiagLower) || primaryDiagLower.includes(dbNameLower)) return true;
    
    return false;
  });

  if (match) {
    console.log(`[DIAGNOSE] Matched disease in DB: ${match.name} (ID: ${match.id})`);
  }

  // Fallback/Override for Urdu disease name
  if (match && match.urdu_name) {
    parsed.disease_name_urdu = match.urdu_name;
    console.log(`[DIAGNOSE] Using curated Urdu name from DB: ${parsed.disease_name_urdu}`);
  } else if (!parsed.disease_name_urdu || 
             parsed.disease_name_urdu.includes('نامعلوم') || 
             parsed.disease_name_urdu.toLowerCase().includes('unknown') ||
             parsed.disease_name_urdu.trim() === '') {
    parsed.disease_name_urdu = parsed.primary_diagnosis || 'نامعلوم بیماری';
  }

  // Log completion
  console.log(`[DIAGNOSE] Diagnosis complete: ${parsed.primary_diagnosis} (${parsed.confidence_percent}% confidence)`);

  // Ensure home_care_urdu is populated with correct translations
  if (!Array.isArray(parsed.home_care_urdu) || parsed.home_care_urdu.length === 0) {
    // If Gemini didn't return home_care_urdu or it is empty, generate it from the database matching or Gemini's home_care English steps
    parsed.home_care_urdu = [];
    const sourceSteps = parsed.home_care || (match ? match.home_care : []);
    if (Array.isArray(sourceSteps)) {
      parsed.home_care_urdu = sourceSteps.map(step => {
        const key = step.toString().trim();
        // Look up in our curated translation map
        if (HOME_CARE_URDU_MAP[key]) return HOME_CARE_URDU_MAP[key];
        if (HOME_CARE_URDU_MAP[key.toLowerCase()]) return HOME_CARE_URDU_MAP[key.toLowerCase()];
        
        // Also do a partial match check
        const foundKey = Object.keys(HOME_CARE_URDU_MAP).find(k => key.toLowerCase().includes(k) || k.includes(key.toLowerCase()));
        if (foundKey) return HOME_CARE_URDU_MAP[foundKey];
        
        return step; // Fallback to English if untranslatable
      });
    }
  } else {
    // Even if Gemini returned some translations, let's normalize them
    // If the returned list is just copies of English keys, translate them using our map
    parsed.home_care_urdu = parsed.home_care_urdu.map((step, idx) => {
      const stepStr = step.toString().trim();
      const engStep = (parsed.home_care && parsed.home_care[idx]) ? parsed.home_care[idx].toString().trim() : '';
      
      // If the step is written in English alphabet, or is a database key, translate it
      if (/^[a-zA-Z_ ]+$/.test(stepStr)) {
        if (HOME_CARE_URDU_MAP[stepStr]) return HOME_CARE_URDU_MAP[stepStr];
        if (HOME_CARE_URDU_MAP[stepStr.toLowerCase()]) return HOME_CARE_URDU_MAP[stepStr.toLowerCase()];
      }
      
      // If the corresponding English step is a DB key, and we have a curated translation, we should use our curated translation for maximum quality!
      if (engStep && HOME_CARE_URDU_MAP[engStep.toLowerCase()]) {
        return HOME_CARE_URDU_MAP[engStep.toLowerCase()];
      }
      
      return step;
    });
  }

  return parsed;
}

module.exports = { diagnoseAgent };
