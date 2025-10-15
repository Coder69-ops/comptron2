# Comptron: Student Event Companion App

Build a cross-platform (Android/iOS) Flutter app for a university club, using **MongoDB** (Atlas) as the backend.

The app supports two main roles: **Students (Users)** and **Admins (Organizers/Club Officers)**.

## Features and Workflow

### For Students (Users)

- **Browse/Discover Events:** List all upcoming events, with filters (type, date, tags/favorites).
- **Register for Events:** Minimal form registers the user for an event and creates a registration entry in the database.
- **Generate QR Pass:** After registration, generate a unique QR code tied to their event registration (`registrationId` or an ObjectId hash).
- **Personal Agenda & Favorites:** Let users favorite events and view a personalized list of registered/upcoming events.
- **Add to Calendar:** One-tap “Add to Calendar” with .ics file/link for reminders.
- **Push Notifications:** Notify students of reminders (24h/1h before), changes, new announcements, etc.
- **Fast QR Check-in:** Students show their QR code at the event door; admins scan it with the app for validated entry.
- **Announcements/Resources:** Announcements feed + resources/docs section for key materials and links.
- **Offline Ready:** Store QR/event info locally for check-in and access if internet is down.
- **Profile:** Basic profile info, view participation/badge history.

### For Admins (Organizers)

- **Create Events:** Admin panel (in-app or web) to create, edit, and manage events with custom fields and capacity limits.
- **Approve or Waitlist:** Auto-waitlist if capacity is reached, promote from waitlist if space opens.
- **QR Code Scanning:** Scan participant QR codes on entry and validate them against MongoDB records. No duplicate entries.
- **Live Analytics:** View real-time stats (registered/checked-in/available seats, peak entry windows, etc.).
- **Notifications/Announcements:** Create announcements and send push notifications to targeted or all users.
- **Manual Check-in:** Search by name/email/ID for entry if QR is lost/damaged.
- **Reports:** Export attendance and registration data.
- **Offline Mode:** Cache attendee/registration list on device, sync check-ins when network resumes.

## Stack

- **Flutter** (UI)
- **MongoDB/Atlas** (for data storage, authentication, and real-time updates)
- **Backend API** (Node.js/Express/Dart backend recommended for auth, push notifications, QR validation, ICS file generation)
- **Push Notifications** (via native services or third-party integration)

## Focus

- Fast, secure, one-tap event registration and entry via QR codes
- Privacy-first: no PII inside QR codes, only backend lookup
- Modern, clean, responsive UI (supporting dark mode and offline viewing)
- Timely reminders (push & calendar) to maximize show-up rate

---

**Implement all core features for both student and admin users as described above, using Flutter front end with MongoDB as persistent and real-time data backend.**



# Comptron UI/UX Design Prompt

Design a mobile event companion app (Flutter, MongoDB backend). The design must:

## 1. Follow Latest UI/UX Trends
- Use **modern, clean layouts** with generous white space, clear hierarchy, and minimalist iconography.
- Favor **rounded corners**, subtle shadows, micro-interactions, and soft gradients for a friendly, polished appearance.
- Support **dark mode/light mode** toggles, adapting automatically to system preference.
- Employ **animated transitions** for navigation and major state changes (e.g., check-in success, page loads).
- Use **floating action buttons** and sticky navigation elements to optimize on-the-go usability.
- Implement context-based UI hints or just-in-time nudges for key actions (e.g., “Show QR” before event).

## 2. Intuitive Navigation & Information Architecture
- **Home:** Featured events, quick actions (“Register”, “My QR”, “Favorites”), notifications badge, and project showcase highlights.
- **Navigation Bar:** Bottom tab bar with Events, Announcements, Resources, Profile, and (if unlocked) Projects.
- **Discover Events:** Search and filter controls, filters for tags/dates/types, sort by popularity/upcoming.
- **Project Showcase:** Grid or card-style gallery with project image, title, tags, and author. Gallery updates live after admin approval.
- **Event Details:** Prominent image, details, “Add to Calendar” button, capacity left, FAQ link, and prominent “Register”/“Show QR” button.
- **Registration/QR Screen:** Large readable QR, color-coded entry state, share/save/brightness toggle, check-in animation.
- **Profile:** Avatar, participations, badges, editable info, theme switch (dark/light).
- **Admin Console:** Clean dashboard cards/lists, approval workflows (toggle/switch for approvals), live stats, custom themes.
- **Empty States:** Playful but clear illustrations/messages for blank screens (“No upcoming events”, etc.)
 
## 3. Consistent and Modern Theme
- Use a cohesive color palette (suggest: blue/violet/amber with white and dark gray backgrounds).
- Typography should be consistent (e.g., Google Fonts’ Inter or Roboto, readable and scalable).
- Primary action button style: pill-shaped, prominent color.
- Cards and lists: Rounded, slight elevation, consistent spacing and divider use.
- Accent colors only for highlights, alerts, or action prompts.

## 4. Accessibility and Usability
- All text/highlights meet **WCAG AA** color contrast ratio.
- Large, tappable hitboxes for mobile use.
- Provide haptic feedback for key actions (check-in, submit).
- Screen reader-friendly labels and navigation.
- Localized for English, but ready for other languages.

## 5. Delightful Micro Features
- Subtle animated success/failure icons on check-in/scan.
- Modern toast/snackbar for status messages.
- Swipe to favorite events and remove from agenda.
- Animated badge unlock and “confetti” on major milestones.
- In-app feedback with animated sent/progress messages.

## 6. Project Showcase Integration
- Card/gallery of approved projects—visually appealing, supports images/videos, preview, and tags.
- Admin panel for project approval with clear status badge (“Pending”, “Approved”, “Rejected”).
- Public project cards link to full details and author info.

---

**Design every page and component as described with maximum consistency and a latest-generation app look. Provide clickable prototypes in Figma/Flutter and sample theme files if possible. Each user experience should feel smooth, engaging, and visually top-tier for 2025 standards.**
