# Master Design Blueprint: Result Publishing App

## 1. Core Purpose
Provide a fast, offline-capable, and aesthetically pleasing mobile interface for students and parents to seamlessly access academic results published by the MERN backend.

## 2. UX / User Flow
1. **Splash Screen**: Brand logo with smooth, modern loading animations.
2. **Auth Screen** *(Pending Confirmation)*: Student login for secure access to results.
3. **Home Dashboard**:
   - Search bar for Roll Number.
   - Global feed of "Recent Publications".
4. **Digital Marksheet**:
   - Detailed subject grades and total marks.
   - CGPA and Pass/Fail status prominently displayed.
   - Option to Download/Share PDF.

## 3. UI Aesthetics
- **Primary Color**: Deep Blue (`#0A3D91`) - Conveys trust and academics.
- **Accent Color**: Success Green (`#2E7D32`) - For positive feedback and "Pass" states.
- **Background**: Crisp White & Light Gray (`#F5F7FA`) - Enhances readability.
- **Typography**: Inter (Google Fonts) - Clean, modern, highly legible sans-serif.

## 4. Tech Architecture
- **Frontend**: Flutter (Dart)
- **State Management**: Riverpod
- **API Integration**: HTTP (to consume MERN Node.js/Express endpoints)
- **Local Cache**: SharedPreferences (for offline access)
