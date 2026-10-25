# Veracity

Take a photo of a letter, bill, lease or contract. Veracity explains it in plain words in your own language, quotes the lines in the original it is based on, lists what to do, and flags signs of a scam.

Built for the Congressional App Challenge.

## How it works

```
Flutter ios app  ->  api/analyze.js (keeps the API key)  ->  Google Gemini (vision)
```

The app sends the page photos and the chosen language to the backend. The backend asks Gemini for a structured JSON answer and returns it. Photos are not stored. Only the text of each result is saved on the user's own device, as history.

## Layout

```
api/analyze.js          Prompt, JSON schema, language list, Gemini call
scripts/local-server.js Local copy of the backend, port 3000
scripts/test-gemini.js  Quick check that the key and model work
vercel.json             Vercel config
app/lib/                Flutter app
  languages.dart        20 languages (names must match api/analyze.js)
  models/               Analysis model and JSON parsing
  services/             api, speech (Read Aloud), history
  screens/              home, camera, processing, overview and the detail screens
  widgets/common.dart   Shared colors and widgets
ARCHITECTURE.md         Diagrams and design notes
```

## Setup

1. Install Flutter and Node.js. Check Flutter with `flutter doctor`.
2. Get a Gemini API key at https://aistudio.google.com/apikey.
3. Create a `.env` file in the project root:
   ```
   GEMINI_API_KEY=your-key
   ```
   Optional: `GEMINI_MODEL` to override the default `gemini-3.5-flash-lite`.
4. From `app/`, run `flutter pub get`.

## Run locally

Terminal 1, from the project root:
```
node scripts\local-server.js
```
Terminal 2:
```
cd app
flutter run --release -d 00008110-001A2D463C87801E --dart-define=API_BASE=http://10.0.0.164:3000
```
Restart the backend after changing `.env`.

## Deploy

Build the iOS app, run with flutter to deploy it to iPhone. Add `GEMINI_API_KEY` under Project, Settings, Environment Variables.

## Things to try

- A utility bill (low or medium risk, amount and due date)
- A "pay with gift cards or be arrested" letter (high risk)
- A lease (clauses and things to ask before signing)
- A blurry photo (asks for a clearer one)

