# Location-Based Reporting App 📍

A simplified Flutter app for submitting geotagged reports with media (image/video). Built for Iconic University Flutter Developer assessment.

## 🔧 Features
- User login/register (email & password)
- Submit reports with:
  - Title, description, category
  - Media attachment (camera/gallery/video)
  - Location via GPS
- View all previously submitted reports

## 📦 Tech Stack
- Flutter 3.x
- Firebase (Auth, Firestore, Storage)
- Google Maps + Geolocator
- Image/Video Picker

## 🚀 Setup Instructions

1. Clone this repo
2. Set up Firebase:
   - Enable Auth, Firestore, Storage
   - Add `google-services.json` to `android/app/`
   - Enable Maps SDK & get Google Maps API Key
3. Update `AndroidManifest.xml` with your API key
4. Run:

```bash
flutter pub get
flutter run
