# PesaBook — Project Memory

Last updated: 15 September 2026

---

## 1. WHAT THIS IS

PesaBook is a simple Android debt/credit bookkeeping app for small
businesses and shopkeepers in Kenya.

The core workflow:
Shopkeeper gives goods on credit → records customer + amount owed →
later records payment → sees current balance and transaction history →
optionally sends a payment reminder.

The app answers one question quickly: "Who owes me money, and how much?"

It is NOT full accounting software. Keep it simple.

---

## 2. TARGET USERS

Primary: Kenyan small shopkeepers and informal businesses who sell
on credit and currently track debts in notebooks, memory, or WhatsApp.

Secondary: Other small operators who personally keep customer credit
records.

Known testers (verify they actually use it daily, not once):
- Mother (shopkeeper) — primary tester
- A shop owner who requested the app
- A motorbike/Bolt rider — fit uncertain
- A teacher who requested the APK

NOTE: Stop counting testers who don't actually extend credit. A Bolt
rider who doesn't give credit is not a user. Focus on shopkeepers.

---

## 3. TECH STACK

- Framework: Flutter (Android only for now)
- Language: Dart (SDK ^3.12.2)
- Android: Kotlin/Gradle, Java 17, JVM target 17
- IDE: Android Studio on a Windows school computer
- Flutter path: C:\flutter\bin\flutter.bat

Packages currently used:
- cupertino_icons ^1.0.8
- url_launcher ^6.3.0
- shared_preferences ^2.5.3
- flutter_lints ^6.0.0

Storage: SharedPreferences via a custom StorageService.
There is NO Firebase, NO SQLite, NO backend, NO login.

Build command:
C:\flutter\bin\flutter.bat build apk
Output:
build\app\outputs\flutter-apk\app-release.apk
Last known APK size: 47.0 MB (STILL TOO BIG — see next actions)

Distribution: manual APK sideload. No Play Store yet.

GitHub repo: https://github.com/ericvaati703-beep/Pesabook-.git
Branch: main

---

## 4. FEATURES BUILT

- Add customer (name, optional phone, initial debt)
- Add Debt from Home
- Add New Debt to existing customer (reactivates paid customers)
- Record Payment (validates: numeric, > 0, cannot exceed balance)
- Customer details screen (balance, history, edit, actions)
- Transaction history (newest first, shows balance after each)
- Edit customer
- Customers screen (search, owing section, paid section)
- Home screen (total owed, active customers sorted by amount, search)
- Send Reminder (WhatsApp + SMS, editable message, pulls shop details)
- Shop Setup (shop name, payment method, till/paybill/pochi numbers)
- Debt age shown on each customer row (e.g. "12 days", "2 months")

---

## 5. KNOWN BUGS / ISSUES

FIXED:
- ~~App name showed "pesabook1"~~ → renamed display name to PesaBook
- ~~Send Reminder enabled on PAID customers~~ → now disabled
- ~~Balances shown in red everywhere~~ → now neutral on lists,
  green only for PAID
- ~~No debt age on customer rows~~ → now shows on Home + Customers

STILL OPEN (priority order):

1. App icon is still the default Flutter logo.
   → Need a 512x512+ PNG. Use flutter_launcher_icons package.
   → Do NOT change the Android package name yet.

2. Transaction history label "Balance: KES X" is ambiguous.
   → It means balance AFTER that transaction. Rename to
   "Remaining: KES X" or "After: KES X".

3. No way to edit or delete a transaction.
   → If a shopkeeper mis-enters 5000 instead of 500, no recovery.
   This is a trust-killer for a money app. Add long-press →
   edit/delete with confirmation.

4. No record that a reminder was sent.
   → Add a "Reminder sent" entry to transaction history (greyed out,
   does not affect balance).

5. Shop Setup: payment method dropdown doesn't change the field label.
   → Field below should update when dropdown changes.

6. APK is 47 MB. Too large for WhatsApp sharing on limited data.
   → Try: flutter build apk --split-per-abi
   → Check for unused assets.

---

## 6. NEXT ACTIONS (in order)

1. Install latest APK on phone and verify the four fixes above.
2. Replace app icon with a proper PesaBook icon.
3. Rename "Balance" label to "Remaining" in transaction history.
4. Add transaction edit/delete.
5. Log reminders in transaction history.
6. Reduce APK size with split-per-abi.
7. Sit in one real shop for a full day and watch how credit is
   actually tracked. Do not build more features before doing this.

---

## 7. TESTING QUESTIONS TO ASK REAL USERS

Ask these and WRITE DOWN the answers:

- "Did you actually send a reminder? What did the customer say?
  Did you feel awkward?"
- "If you opened this app, what would you want to know that
  isn't shown?"
- "How many credit transactions do you do in a day?"
- "Would you pay KES 100/month for this? Why or why not?"

---

## 8. RULES FOR WORKING ON THIS PROJECT

- Simple → useful → tested with real people → improve from evidence.
- Do not add features that have not been requested by real users.
- Commit after every working change. Push to GitHub so nothing is lost.
- Run `flutter analyze` before every commit. Fix errors before pushing.
- Update this file whenever a decision is made or a bug is found.
- When starting a new AI chat, paste this entire file first.

---

## 9. SESSION LOG

15 Sep 2026:
- Created PROJECT.md
- Renamed display name from pesabook1 to PesaBook
- Disabled Send Reminder for paid customers
- Changed red balances to neutral on Home + Customers lists
- Added debt age to customer rows
- All changes committed and pushed to GitHub
- APK rebuilt (47 MB)

---

## 10. THE HARD TRUTH TO REMEMBER

The idea is fine. The execution is on track.

The risks are:
- Data loss (SharedPreferences is not built for a money ledger — plan
  a migration to SQLite before real users trust it with real money).
- Losing trust after one bad entry with no undo.
- Building features users didn't ask for.
- Being unable to explain the app without an AI.

The goal is not to become a millionaire. The goal is to build something
real Kenyan shopkeepers actually use. That is achievable.