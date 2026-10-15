# Privacy Policy

**Last Updated: June 2026**

Your privacy is paramount to us. This Privacy Policy explains how **Expense Budget Tracker** ("Expense Manager", "we", "our", or "us") collects, uses, protects, and discloses information when you use our mobile application.

---

## 1. Information We Collect

### 1.1 Local Financial Data (Stored Locally on Your Device)
The core information you manage—including account names, account balances, expenses, incomes, categories, budgets, recurring reminders, debt/credit (*Udhar*) records, and attached receipt images—is **stored locally on your device** in a private SQLite database. We do **not** upload or sell your private transaction records to any third party.

### 1.2 Account Information (Optional)
If you optionally sign in using Google Sign-In or Email/Password via Firebase Authentication:
- We collect your **email address**, **display name**, and **profile photo URL**.
- This information is stored securely in Firebase Authentication and Google Cloud Firestore (`users/{uid}`) to manage your identity and cloud account state.

### 1.3 Device & Usage Information
When using online features or viewing ads:
- Anonymous crash diagnostics, device models, operating system version, and general network state may be processed by Google Play Services and Firebase.

---

## 2. Device Permissions We Request

The application requests only permissions strictly necessary for its features:

- **Notifications (`POST_NOTIFICATIONS`)**: Used to deliver daily reminder alerts, budget warnings, and recurring transaction reminders configured by you.
- **Microphone & Speech Recognition (`RECORD_AUDIO`, `SPEECH_RECOGNITION`)**: Used strictly when you open the Voice Assistant to dictate transaction entries via speech-to-text. Voice audio is processed by your device's native speech recognition service and is not recorded, stored, or transmitted by us.
- **Photo Library / Gallery (`READ_MEDIA_IMAGES` / Photo Library access)**: Used only when you choose to attach a photo of a receipt or bill to an expense record.

---

## 3. Third-Party Services & Advertising

We work with reputable third-party services that may collect information used to identify you according to their own privacy policies:

- **Google Mobile Ads (AdMob)**: Displays in-app banner, interstitial, and app-open advertisements. AdMob may collect and use advertising identifiers (such as Google Advertising ID or IDFA) to serve relevant ads. In regions requiring consent (such as the EEA and UK), we provide a Consent Management Platform (CMP) dialog.
- **Firebase Authentication & Firestore**: Manages identity and user profiles.
- **Google Play In-App Billing / Apple StoreKit**: Handles secure payment processing for purchasing "Remove Ads". Financial billing details (credit cards) are processed exclusively by Google/Apple and never touch our servers.

---

## 4. Data Retention and Account Deletion

- **Local Data**: You have complete control over your local data. You can export JSON or CSV backups, wipe the data, or uninstall the app to erase all locally stored records.
- **Cloud Account Deletion**: If you have created a cloud account, you can permanently delete your account and profile data at any time directly within the application by navigating to **Profile → Delete Account**. Upon confirmation, your Firebase Authentication identity and associated Firestore records are permanently deleted.

---

## 5. Security

We take reasonable technical precautions to protect your information:
- You can enable an optional in-app **App Lock PIN**, which is hashed and stored in your device's hardware-backed secure storage (`FlutterSecureStorage`).
- All cloud communications (Firebase Auth, Firestore, Remote Config) are encrypted in transit via Transport Layer Security (TLS/HTTPS).

---

## 6. Children's Privacy

The application is not directed toward children under 13 years of age. We do not knowingly collect personal identifiable information from children under 13.

---

## 7. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. Any updates will be published within the application with a revised "Last Updated" date.

---

## 8. Contact Us

If you have questions or concerns about this Privacy Policy or your data, please contact us at:
**privacy@expenseincome.app**
