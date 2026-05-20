<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" />
<img src="https://img.shields.io/badge/Google_Gemini-AI-4285F4?style=for-the-badge&logo=google&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />

# 🐾 Vetra AI

### Intelligent Veterinary AI Platform for Rural Farmers

*Speak your animal's symptoms. Get a diagnosis. Book a vet. All in one tap.*

[Features](#-features) · [Architecture](#-architecture) · [Tech Stack](#-tech-stack) · [Getting Started](#-getting-started) · [API Reference](#-api-reference) · [AI Agents](#-ai-agents)

</div>

---

## The Problem

Livestock farmers in rural Pakistan face a critical gap: when an animal falls sick, every hour of delay risks death. Veterinarians are far away, helplines are in English, and most farmers can't type complex medical descriptions on a smartphone.

**Vetra AI is the bridge.** Speak in Urdu. Take a photo. The AI diagnoses, explains, and books the right vet — automatically.

---

## ✨ Features

### 🎙️ Multi-Modal Intake
Farmers describe symptoms by **voice** (Urdu or English) or by **photographing the animal**. No typing, no English required.

### 🧠 AI-Powered Diagnosis
Powered by **Google Gemini**, Vetra matches symptoms against a livestock disease database and returns:
- Primary diagnosis + confidence score (e.g. *"Foot and Mouth Disease — 92%"*)
- Risk level on a 1–10 scale
- Step-by-step home-care instructions in **both English and Urdu**

### 📍 Smart Vet Discovery & Booking
The system finds nearby vets filtered by **GPS location** and **required specialty**, then uses an AI decision agent to pick the best match based on distance, rating, and availability. Appointment booked. Notification sent. Done.

### 🔍 Live Agent Reasoning Trace
A real-time glassmorphic panel shows the AI's internal thought process step by step — every decision, confidence score, and reasoning logged transparently as it happens.

### 🇵🇰 Built for Pakistan
Full **Urdu/English toggle** on every screen. Designed for low-literacy users with large tap targets, icon-heavy navigation, and color-coded risk indicators.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter App                          │
│  Voice Intake → Camera Screen → Diagnosis → Vet Map     │
│             ↕ Firestore Real-time Stream                 │
└──────────────────────┬──────────────────────────────────┘
                       │ REST API
┌──────────────────────▼──────────────────────────────────┐
│                   Express Backend                        │
│                                                          │
│  LISTEN → DIAGNOSE → DISCOVER → DECIDE → EXECUTE        │
│     ↕           ↕          ↕        ↕        ↕          │
│  Gemini     Gemini      Firestore  Gemini   FCM          │
│  Language   Vision      + Maps     Agent   Push          │
└─────────────────────────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                     Firebase                             │
│     Firestore  │  Storage  │  Auth  │  Cloud Messaging  │
└─────────────────────────────────────────────────────────┘
```

### Case Lifecycle

| Phase | What Happens | Agent Trace Example |
|-------|-------------|---------------------|
| `SESSION` | Unique `case_id` generated | `vtx-0042 initialized` |
| `LISTEN` | Voice transcribed → symptoms extracted | `Extracted: fever, lethargy, foot lesions` |
| `VISION` | Animal photo analyzed by Gemini Vision | `Skin lesions detected. Severity: HIGH` |
| `DIAGNOSE` | Symptoms matched → diagnosis + risk score | `FMD — 92% confidence. Risk: 8/10` |
| `DISCOVER` | Nearby vets fetched by GPS + specialty | `3 bovine specialists found within 12 km` |
| `DECIDE` | AI agent picks optimal vet | `Dr. Ali Khan selected — 4.9★, 3.2 km` |
| `EXECUTE` | Booking confirmed + notifications sent | `Booking ID: bk-7821. Vet notified.` |

---

## 🛠️ Tech Stack

**Frontend (Flutter)**

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `speech_to_text` | Real-time voice capture |
| `image_picker` | Camera & gallery access |
| `google_maps_flutter` | Interactive vet discovery map |
| `cloud_firestore` | Real-time agent trace streaming |
| `firebase_storage` | Image/audio upload |
| `geolocator` | GPS coordinates for vet search |

**Backend (Node.js / Express)**

| Package | Purpose |
|---------|---------|
| `@google/generative-ai` | Gemini API — diagnosis, vision, decision agents |
| `firebase-admin` | Firestore & Storage server-side access |
| `multer` | Multipart image/audio upload handling |
| `node-cron` | Scheduled background jobs |

**Cloud Services:** Firebase Firestore · Firebase Storage · Firebase Auth · Firebase Cloud Messaging · Google Gemini Pro · Google Gemini Vision · Google Maps Platform

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) v3.11+
- [Node.js](https://nodejs.org/) v18+
- Firebase project (Firestore + Storage + Auth + FCM enabled)
- [Google Gemini API Key](https://aistudio.google.com/app/apikey)
- Google Maps API Key (Geocoding + Distance Matrix + Maps SDK)

---

### 1. Clone the Repo

```bash
git clone https://github.com/your-username/vetra-ai.git
cd vetra-ai
```

### 2. Backend Setup

```bash
cd vetra-backend
npm install
```

Rename `.env.example` to `.env` and fill in your keys:

```env
GEMINI_API_KEY=your_gemini_api_key
GOOGLE_MAPS_API_KEY=your_maps_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
PORT=3000
```

Place your `firebase-service-account.json` in the `vetra-backend/` root *(do not commit this file)*.

```bash
node server.js
# ✓ Server running on http://localhost:3000
```

### 3. Flutter App Setup

```bash
cd vetra_ai
flutter pub get
```

Configure Firebase using the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=your_firebase_project_id
```

Or manually place `google-services.json` (Android → `android/app/`) and `GoogleService-Info.plist` (iOS → `ios/Runner/`).

Update your backend URL in `lib/services/api_service.dart`:

```dart
const String baseUrl = 'http://YOUR_BACKEND_IP:3000/api';
```

```bash
flutter run
```

---

## 📡 API Reference

All endpoints are prefixed with `/api`.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/session/new` | Create a new case session, returns `case_id` |
| `POST` | `/listen` | Extract symptoms from voice/transcript via Gemini |
| `POST` | `/vision` | Analyze animal photo for clinical indicators |
| `POST` | `/diagnose` | Full diagnosis — disease, confidence, risk, home-care |
| `GET` | `/vets/nearby` | Fetch nearby vets by GPS + specialty filter |
| `POST` | `/vets/decide` | AI agent selects optimal vet from candidates |
| `POST` | `/booking/confirm` | Confirm booking + send FCM push notifications |

<details>
<summary><b>Example: POST /api/diagnose</b></summary>

**Request**
```json
{
  "case_id": "vtx-0042",
  "symptoms": ["fever", "lethargy", "foot lesions", "reduced appetite"],
  "visual_findings": ["skin lesions on distal limbs", "abnormal posture"],
  "animal": { "species": "bovine", "age": 4, "weight": 380 }
}
```

**Response**
```json
{
  "disease": "Foot and Mouth Disease",
  "confidence": 92,
  "risk_level": 8,
  "requires_vet": true,
  "home_care_en": "Isolate the animal immediately. Clean foot lesions with mild antiseptic...",
  "home_care_ur": "جانور کو فوری طور پر الگ کریں۔ پاؤں کے زخموں کو ہلکے جراثیم کش سے صاف کریں...",
  "differentials": ["Bluetongue", "Bovine Viral Diarrhea"]
}
```
</details>

---

## 🤖 AI Agents

Vetra AI runs four custom Gemini-powered agents, each handling one phase of the case:

| Agent | Phase | Model | Strategy |
|-------|-------|-------|----------|
| **Symptom Extraction** | `LISTEN` | Gemini Pro | Few-shot prompting — maps informal Urdu farmer speech to structured clinical symptom arrays |
| **Visual Analysis** | `VISION` | Gemini Vision | Zero-shot visual prompt — identifies posture, lesions, coat condition, discharge from animal photos |
| **Clinical Diagnosis** | `DIAGNOSE` | Gemini Pro | Chain-of-thought with veterinary disease ontology — ranks by symptom overlap, assigns risk 1–10, generates bilingual home-care |
| **Vet Decision** | `DECIDE` | Gemini Pro | Weighted scoring rubric — specialty 40%, distance 30%, rating 20%, availability 10% |

All agents output structured JSON parsed and validated server-side before reaching the client.

---

## 📁 Project Structure

```
vetra-ai/
├── vetra_ai/                   # Flutter mobile app
│   └── lib/
│       ├── screens/            # Voice intake, camera, diagnosis, vet discovery
│       ├── widgets/            # Agent trace panel (glassmorphism)
│       ├── providers/          # State management
│       ├── services/           # API calls, Firebase
│       └── theme/              # StitchColors design system
│
└── vetra-backend/              # Node.js Express API
    ├── routes/                 # session, listen, vision, diagnose, vets, booking
    ├── agents/                 # symptomAgent, visionAgent, diagnosisAgent, decisionAgent
    ├── firebase/               # Firebase Admin SDK init
    ├── .env.example
    └── server.js
```

---

## 🔒 Security Notes

- All API keys stored in `.env` — **never committed to source control**
- `firebase-service-account.json` excluded via `.gitignore`
- All Gemini API calls made **server-side** — the Flutter client never holds the API key
- Firebase Security Rules should restrict Firestore reads/writes to authenticated users only

---

## 🗺️ Roadmap

- [ ] Offline-first diagnosis via on-device ML model
- [ ] In-app vet teleconsultation (video/audio)
- [ ] IoT livestock wearable sensor integration
- [ ] Disease outbreak heatmaps from anonymized case data
- [ ] Expanded language support: Punjabi, Sindhi, Pashto

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

<div align="center">

*Vetra AI — Empowering farmers. Protecting livestock. Saving livelihoods.*

</div>
