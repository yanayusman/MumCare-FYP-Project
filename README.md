# MumCare Flutter App — Project Summary

**Project Name:** MumCare  
**Description:** A pregnancy journey companion mobile app for iOS & Android  
**Tech Stack:** Flutter, Dart, Supabase (PostgreSQL), Google OAuth  
**Status:** Frontend UI complete, Supabase Auth setup in progress

---

## 📱 Project Overview

MumCare is a comprehensive maternal health management app designed to support pregnant women throughout their pregnancy journey. The app includes appointment tracking, health monitoring, nutrition management, medication reminders, and educational content.

### Core Features
- 👤 User authentication (Email & Google Sign-In)
- 📅 Appointment scheduling & management
- 💓 Health monitoring (vitals, weight tracking, symptoms)
- 🥗 Nutrition management
- 💊 Medicine/medication tracking
- 📚 Educational content (Explorer)
- 👥 User profile management
- 🔔 Notifications
- 📊 Health data visualization

---

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point & routes
├── screens/
│   ├── login_screen.dart             # Login with Email/Google
│   ├── register_screen.dart          # Register with Email/Google
│   ├── profile_setup_screen.dart     # 3-step form (Personal, Medical, Husband)
│   ├── home_screen.dart              # Dashboard
│   ├── appointment_screen.dart       # Appointments list (Upcoming/Past)
│   ├── health_screen.dart            # Health monitoring with vitals & charts
│   ├── explorer_screen.dart          # Educational content with search
│   ├── profile_screen.dart           # User profile & settings
│   ├── email_login_screen.dart       # Email/password login (to build)
│   ├── nutrition_screen.dart         # (to build)
│   ├── medicine_screen.dart          # (to build)
│   ├── notification_screen.dart      # (to build)
│   └── [detail screens]              # (to build)
├── widgets/
│   └── bottom_nav_bar.dart           # Reusable bottom navigation
└── services/
    └── auth_service.dart             # Authentication logic
```

---

## ✅ Screens Built

### 1. **Login Screen** ✅
- Logo + app branding
- "Continue with E-Mail" button
- "Continue with Google" button
- "Sign up" link → Register screen

### 2. **Register Screen** ✅
- Same layout as Login
- Google & Email sign-in options
- "Already have account?" link

### 3. **Profile Setup Screen** ✅
**3-Step Multi-Form:**

**Step 1 — Personal Information**
- Full Name, IC Number, Date of Birth
- Ethnic, Citizenship (dropdowns)
- Phone Number, Home Address
- Occupation, Work Address

**Step 2 — Medical Information**
- Risk Factors
- THA/LNMP (Last Normal Menstrual Period)
- TAL/EDD (Expected Delivery Date)
- RE EDD (Revised EDD)
- Gravida, Para

**Step 3 — Husband Information**
- Full Name, IC Number
- Phone Number
- Occupation, Work Address

### 4. **Home Screen (Dashboard)** ✅
- User greeting ("Hi, Sarah!")
- Pregnancy progress card (week tracker + progress bar)
- Quick action grid (4 cards):
  - Next Appointment
  - Today's Health
  - Nutrition intake
  - Medications pending
- Today's Tip card
- Recent Activity section
- Bottom navigation bar

### 5. **Appointments Screen** ✅
- Toggle: Upcoming / Past tabs
- Appointment cards showing:
  - Type (Checkup, Ultrasound, etc.)
  - Doctor name
  - Date & Time
  - "View Details" & "Reschedule" buttons
- Add appointment button (+)

### 6. **Health Monitoring Screen** ✅
- Vitals grid (2x2):
  - Blood Pressure (120/80)
  - Weight (68 kg)
  - Heart Rate (78 bpm)
  - Baby Kicks (count)
- Weight Trend Chart (line chart with CustomPainter)
- Recent Symptoms list
- Add health record button (+)

### 7. **Explorer Screen** ✅
- Search bar
- Filter chips (All, Medication, Nutrition, Exercise)
- Featured article card with image overlay
- Article list with navigation arrows
- Click to view full articles (routing ready)

### 8. **Profile Screen** ✅
- User info card (avatar, name, email, due date, postnatal code)
- Settings menu (6 items):
  - Personal Information
  - Medical History
  - Healthcare Provider
  - Notifications
  - Privacy & Security
  - Help & Support
- Logout button with confirmation dialog

### 9. **Bottom Navigation Bar** ✅
- Reusable widget (imported in all screens)
- 5 nav items:
  - Appointments
  - Health
  - Home (FAB pink button)
  - Explorer
  - Profile
- Active state highlighting
- Navigation via routes

---

## 🎨 Design System

### Colors
- **Background:** `#FFF6F3` (light beige)
- **Primary:** `#E8A0A0` (pink/mauve)
- **Secondary:** `#D4537E` (deeper pink)
- **Dark Text:** `#2D1F17`
- **Light Text:** `#9B8070`
- **Borders:** `#E8DDD6`

### Typography
- **Font:** Inter (or default)
- **Headlines:** 20-26px, weight 600
- **Body:** 13-15px, weight 400-500
- **Small:** 10-12px, weight 400

### Components
- Border radius: 14-30px (rounded corners)
- Card shadows: subtle, border-based
- Buttons: filled (pink) or outlined (white)

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.0.10
  provider: ^6.1.2
  shared_preferences: ^2.3.2
  http: ^1.2.2
  supabase_flutter: ^2.3.4        # Database & Auth
  google_sign_in: ^6.2.1          # Google OAuth
```

---

## 🔐 Supabase Authentication Setup

### Step 1 — Environment Variables

In `main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

Get these from your Supabase Dashboard → **Project Settings → API**

### Step 2 — Auth Service

Location: `lib/services/auth_service.dart`

**Available Methods:**
```dart
AuthService.instance.signInWithGoogle()        // Google OAuth
AuthService.instance.signUpWithEmail(email, password)
AuthService.instance.signInWithEmail(email, password)
AuthService.instance.signOut()
AuthService.instance.currentUser               // Get logged-in user
AuthService.instance.isLoggedIn                // Check if authenticated
```

### Step 3 — Google OAuth Configuration

#### In Supabase Dashboard:
1. Go to **Authentication → Providers → Google**
2. Enable Google provider
3. Enter Google Client ID & Secret
4. Copy the **Callback URL** Supabase provides

#### In Google Cloud Console:
1. Create OAuth 2.0 credentials:
   - **Web Application** (for Supabase)
   - **Android** (for mobile testing)
2. Add Supabase callback URL to authorized redirect URIs
3. For Android: Add SHA-1 fingerprint to authorized apps

**Get Android SHA-1:**
```bash
cd android
./gradlew signingReport
```

#### In Android Project:
`android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.yourname.mumcare_app"  # must match Google Console
}
```

`android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

---

## 🗄️ Database Schema (Supabase)

### Tables to Create:

#### 1. **users** (managed by Supabase Auth)
- `id` (UUID, primary key)
- `email` (text)
- `created_at` (timestamp)

#### 2. **user_profiles** (custom table)
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT,
  ic_number TEXT,
  birth_date DATE,
  ethnic TEXT,
  citizenship TEXT,
  phone TEXT,
  home_address TEXT,
  occupation TEXT,
  work_address TEXT,
  
  -- Medical
  risk_factors TEXT,
  tha DATE,           -- LNMP
  tal DATE,           -- EDD
  re_edd DATE,
  gravida INTEGER,
  para INTEGER,
  
  -- Husband
  husband_name TEXT,
  husband_ic TEXT,
  husband_phone TEXT,
  husband_job TEXT,
  husband_address TEXT,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### 3. **appointments**
```sql
CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id),
  type TEXT,          -- 'Checkup', 'Ultrasound', etc.
  doctor_name TEXT,
  appointment_date DATE,
  appointment_time TIME,
  status TEXT,        -- 'upcoming', 'completed', 'cancelled'
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 4. **health_records**
```sql
CREATE TABLE health_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id),
  blood_pressure TEXT,  -- '120/80'
  weight DECIMAL,       -- kg
  heart_rate INTEGER,   -- bpm
  baby_kicks INTEGER,
  record_date DATE,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 5. **symptoms**
```sql
CREATE TABLE symptoms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id),
  symptom_name TEXT,    -- 'Morning sickness', 'Back pain'
  symptom_date DATE,
  severity TEXT,        -- 'mild', 'moderate', 'severe'
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 6. **nutrition_logs**
```sql
CREATE TABLE nutrition_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id),
  calories INTEGER,
  protein DECIMAL,
  carbs DECIMAL,
  fat DECIMAL,
  log_date DATE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 7. **medications**
```sql
CREATE TABLE medications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id),
  medication_name TEXT,
  dosage TEXT,
  frequency TEXT,       -- 'Once daily', 'Twice daily'
  start_date DATE,
  end_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🚀 Running the App

### Setup
```bash
flutter clean
flutter pub get
flutter run
```

### For Web Testing
```bash
flutter run -d chrome
```

### For Android Testing
```bash
flutter run -d emulator-id
```

---

## 📋 Screens Remaining to Build

| Screen | Status | Priority |
|---|---|---|
| Email Login | ⬜ | High |
| Nutrition Management | ⬜ | High |
| Medicine/Medication | ⬜ | High |
| Notification Settings | ⬜ | Medium |
| Personal Info Detail | ⬜ | Medium |
| Medical History | ⬜ | Medium |
| Healthcare Provider | ⬜ | Medium |
| Privacy & Security | ⬜ | Low |
| Help & Support | ⬜ | Low |

---

## 🔄 Integration Checklist

- [ ] Supabase project created with URL & anon key
- [ ] Google OAuth configured in Supabase & Google Cloud
- [ ] Firebase/Firebase Auth removed from project
- [ ] `AuthService` wired to Supabase
- [ ] Auto-redirect on login (if user already logged in)
- [ ] User profile setup form saves to `user_profiles` table
- [ ] Appointments load from database
- [ ] Health records load from database
- [ ] Logout clears session & returns to login
- [ ] Email login implemented
- [ ] Email verification (optional)
- [ ] Password reset flow (optional)

---

## 🎯 Next Steps (Recommended Order)

1. **Wire Email Login** → `email_login_screen.dart` with Supabase
2. **Save Profile Setup** → POST to `user_profiles` table on form completion
3. **Load Appointments** → Fetch from database in `appointment_screen.dart`
4. **Load Health Data** → Fetch weight trends & vitals from database
5. **Build Nutrition Screen** → Add nutrition tracking UI
6. **Build Medicine Screen** → Add medication/pill tracker UI
7. **Test end-to-end** → Login → Profile setup → Home → Browse screens

---

## 📚 Useful Resources

- **Supabase Docs:** https://supabase.com/docs/reference/dart
- **Flutter Supabase Package:** https://pub.dev/packages/supabase_flutter
- **Google Sign-In for Flutter:** https://pub.dev/packages/google_sign_in

---

## 💡 Notes

- All screens have **bottom navigation** using the shared `BottomNavBar` widget
- **No Firebase** — using Supabase PostgreSQL instead
- **Google Auth** is mocked until OAuth is fully configured
- **Form validation** is built-in on profile setup & login screens
- **Charts** use Flutter's built-in `CustomPaint` (no external charting library needed)
- **Color palette** is consistent across all screens

---

**Last Updated:** June 2026  
**App Status:** Alpha (UI complete, Auth & DB integration in progress)