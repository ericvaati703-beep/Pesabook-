# PesaBook — Project Memory

Last updated: 29 September 2026

---

## 1. WHAT THIS IS

PesaBook is a simple Android debt/credit bookkeeping app for small
businesses and shopkeepers in Kenya.

Core workflow:
Shopkeeper gives goods on credit → records customer + amount owed →
later records payment → sees balance and transaction history →
optionally sends a payment reminder.

Answers one question quickly: "Who owes me money, and how much?"

NOT full accounting software. Keep it simple.

---

## 2. TARGET USERS

Primary: Kenyan small shopkeepers and informal businesses who sell
on credit and currently track debts in notebooks, memory, or WhatsApp.

Secondary: Other small operators who personally keep customer credit
records.

Known testers and users:
- Mother (shopkeeper) — early tester
- Duka/motorbike circle in the same plot — DAILY ACTIVE USER
  (see Section 12 for what they said)
- Juice shop owner — asked about M-Pesa payment prompts (logged)
- A teacher who requested the APK — not yet delivered
- A shop owner who said "busy" — approached twice, not yet engaged
- A kiosk owner (same area) — witnessed a debt dispute, not yet shown

PITCH (Swahili, memorize):
"Ni kitabu cha deni kwa simu — unaandika nani anakudai na pesa
ngapi, na inakuonyesha."

Translation: "It's a debt book for the phone — you write who owes
you and how much, and it shows you."

Use this BEFORE the person says "I'm busy." Don't start tapping
through screens. Let them ask.

---

## 3. TECH STACK

- Framework: Flutter (Android only for now)
- Language: Dart (SDK ^3.12.2)
- Android: Kotlin/Gradle, Java 17, JVM target 17
- IDE: Android Studio on a Windows school computer
- Flutter path: C:\flutter\bin\flutter.bat

Packages:
- cupertino_icons ^1.0.8
- url_launcher ^6.3.0
- shared_preferences ^2.5.3
- path_provider ^2.1.6
- share_plus ^13.3.0
- flutter_lints ^6.0.0
- flutter_launcher_icons ^0.14.4 (dev)

Storage: SharedPreferences via StorageService.
No Firebase, no SQLite, no backend, no login.

Build command:
C:\flutter\bin\flutter.bat build apk
Output:
build\app\outputs\flutter-apk\app-release.apk
Last known APK size: 48.1 MB (STILL TOO BIG — see next actions)

IMPORTANT BUILD NOTE: compileSdk in android/app/build.gradle.kts is
pinned to 36 (not flutter.compileSdkVersion). The school computer
had SDK 36 already installed but not SDK 35, and Flutter tried to
download 35 which took 30+ minutes. Pinning to 36 avoids the
download. If a build ever fails with an SDK version error, that
line is the first place to look.

GitHub: https://github.com/ericvaati703-beep/Pesabook-.git
Branch: main

---

## 4. SIGNING (CRITICAL — NEVER LOSE THIS)

Keystore file:
C:\Users\Admin\keystores\pesabook-keystore.jks
ALSO backed up to phone Downloads folder

Password: Shakurpesa925E
Alias: pesabook
Key algorithm: RSA 2048
Validity: 10,000 days (~27 years)

key.properties location:
android/key.properties
This file is in .gitignore — it must NEVER reach GitHub.

The keystore file is NOT in the project folder. It lives at
C:\Users\Admin\keystores\. If the school computer is wiped and the
phone backup is also lost, updates to PesaBook become impossible
forever. Keep the backup.

TESTED: Signed APK installs over existing install WITHOUT uninstall.
This is the proof signing works. Future updates install cleanly.

IMPORTANT: If you ever build on a DIFFERENT computer, you must:
1. Copy pesabook-keystore.jks to that machine
2. Recreate android/key.properties there with the correct path
3. Use the same password

---

## 5. FEATURES BUILT

- Add customer (name, optional phone, initial debt)
- Add Debt from Home
- Add New Debt to existing customer (reactivates paid customers)
- Record Payment (validates numeric, > 0, cannot exceed balance)
- Confirmation dialog before saving payment or new debt
- Customer details screen (balance, history, edit, actions)
- Transaction history (newest first, shows balance after each)
- Edit customer
- Customers screen (search, owing section, paid section)
- Home screen (total owed, active customers sorted by amount, search)
- Send Reminder (WhatsApp + SMS, editable message, pulls shop details)
- Send Reminder disabled on PAID customers
- Shop Setup (shop name, payment method, till/paybill/pochi numbers)
- Shop Setup loads saved values when reopened
- Payment details optional in Shop Setup (None option added)
- Debt age shown on each customer row ("today", "3 days", "2 months")
  — counts calendar days, not elapsed hours
- App icon (PB wordmark on purple background)
- Release builds signed with PesaBook keystore
- Tagline on Home screen explaining what PesaBook does
- BACKUP (export only): "Back up now" button in Shop Setup creates a
  JSON file and opens Android share sheet. Tested — file contains
  full shop, customer, and transaction data.

---

## 6. KNOWN ISSUES

FIXED (do not redo):
- App name "pesabook1" → renamed to "PesaBook"
- Send Reminder enabled on PAID customers → now disabled
- Red balances everywhere → now neutral, green only for PAID
- No debt age on customer rows → now shown
- Shop Setup didn't load saved values → now does
- Black screen after saving Shop Setup on first launch → fixed
- APK required uninstall before update → signing solved this
- Debt age counted hours instead of calendar days → fixed
- Shop Setup blocked users without a payment method → now optional

STILL OPEN (priority order):

1. NO RESTORE FEATURE. **THIS IS THE NEXT TASK.**
   Backup export works. But there is no way to load a backup file
   back into the app yet. So if a user loses their phone, they have
   the file but cannot recover the data. This is the missing half.
   Design decisions already made:
    - Restore button in Shop Setup, below Backup
    - Replace mode, not merge (simpler, fewer bug surfaces)
    - Reads the .json file, validates "app": "PesaBook", loads data
    - Confirmation dialog showing backup date and customer count

2. No automatic backup reminder.
   Decided 29 Sep: don't build yet. Users haven't complained about
   forgetting to back up. Revisit when evidence appears.

3. "Balance: KES X" label in transaction history is ambiguous.
   It means balance AFTER that transaction, not current balance.
   Rename to "Remaining: KES X" or "After: KES X".

4. APK is 48.1 MB. Too large for WhatsApp sharing on limited data.
   Try: flutter build apk --target-platform android-arm64
   (check size first, then decide)

5. No record that a reminder was sent.
   Decided 22 Sep: don't build unless a real user asks.

6. No transaction edit/delete.
   DECISION (16 Sep): Do NOT add general edit/delete. Instead:
    - Confirmation dialog before save (DONE)
    - Later: undo last transaction within a short window
    - Much later: Adjustment transaction type for legitimate corrections
      Reason: an editable money ledger can be doubted.

7. SharedPreferences may need migration to SQLite eventually.
   Risk of data loss at scale. Not urgent. Plan before real users
   trust it with large amounts of money.

8. Icon source image was not square (999x642), so the launcher
   icon has white bands on the sides. Works, but slightly unpolished.

---

## 7. REQUESTED FEATURES (not building yet)

Logged because real users asked. Do NOT build without more evidence.

- **M-Pesa STK Push / payment prompts.**
  Requested by: juice shop owner (24 Sep 2026).
  What it is: user types a customer's number, customer receives
  an M-Pesa prompt, enters PIN, money moves.
  Why not now: requires a backend server, Daraja API production
  access, a registered business, a Paybill/Till in that business's
  name, public HTTPS callback, hosting, and a user account system.
  This is a different product, not a feature.
  Revisit when: multiple users ask AND there is money for hosting
  AND a registered business exists.

- **Play Store distribution.**
  Requested by: two separate users (duka guy + motorbike rider).
  Cost: $25 one-time Google developer registration.
  Requires: signed APK (DONE) + RESTORE feature (NOT DONE) +
  privacy policy + store listing.
  Do this AFTER restore exists. No point listing on Play Store if
  users can lose their data on reinstall.

---

## 8. NEXT ACTIONS (in order)

1. Update PROJECT.md after every session.
2. **Build the RESTORE feature** (item 1 in Section 6).
   This completes backup+restore and unblocks Play Store.
3. Show the app to 2-3 more credit-selling shops. Use the pitch.
   Ask the questions in Section 9. Write down answers.
4. Rename "Balance" label in transaction history (Section 6 item 3).
5. Reduce APK size (Section 6 item 4).
6. Register Play Store developer account (after restore is done).
7. Fix icon to square source (Section 6 item 8).

---

## 9. TESTING QUESTIONS TO ASK REAL USERS

Ask these and WRITE DOWN the answers. Word for word.

- "Do you have customers who owe you money right now?"
- "Can I show you how I track mine, and you tell me if it
  makes sense?" (then show Home screen for 20 seconds, no talking)
- "If you had this on your phone, would you use it? Why or why not?"
- "Did you ever send a reminder? What did the customer say?
  Did you feel awkward?"
- "What would you want to know that isn't shown?"
- "How many credit transactions do you do in a day?"
- "Would you pay KES 100/month for this? Why or why not?"

Rules for asking:
- Do not pitch. Ask, listen, walk away.
- "No" is valuable. "Yes to be polite" is not.
- Never install the app on someone else's phone during a first
  conversation. Demo on yours only.

---

## 10. RULES FOR WORKING ON THIS PROJECT

- Simple → useful → tested with real people → improve from evidence.
- Do not add features that have not been requested by real users.
- Commit after every working change. Push to GitHub.
- Run `flutter analyze` before every commit.
- Update this file whenever a decision is made or a bug is found.
- When starting a new AI chat, paste this entire file first.
- If the build fails with a memory error, check gradle.properties
  has -Xmx2G (not -Xmx8G).
- If the build hangs downloading Android SDK, check compileSdk is
  pinned to 36 in build.gradle.kts (see Section 3).

---

## 11. SESSION LOG

15 Sep 2026:
- Created PROJECT.md
- Renamed display name from pesabook1 to PesaBook
- Disabled Send Reminder for paid customers
- Changed red balances to neutral on Home + Customers lists
- Added debt age to customer rows

16 Sep 2026:
- Added confirmation dialog before saving payments and debts
- Fixed Shop Setup to load saved values on open

17 Sep 2026:
- Fixed black screen after saving Shop Setup on first launch
- Created keystore + key.properties (with corrections)
- Configured gradle.properties for lower memory (-Xmx2G)
- Backed up keystore to phone Downloads

18 Sep 2026:
- Built first signed APK successfully
- Installed signed APK (final uninstall/reinstall)

21 Sep 2026:
- Generated app icon (PB wordmark on purple)
- Verified signed APK updates over existing install WITHOUT uninstall
- Showed app to shopkeeper in same plot (said busy)

22 Sep 2026:
- Added tagline on Home screen explaining what PesaBook does

24 Sep 2026:
- Showed app to juice shop owner. He asked about M-Pesa payment
  prompts (STK Push). Logged as requested feature, not building.

26 Sep 2026:
- Sent app to a duka owner through a mutual friend with no message.
  He downloaded it and started using it daily.

28 Sep 2026:
- Fixed debt age to count calendar days (was counting hours)
- Made Shop Setup payment details optional
- Met the duka user on the road. He called me "developer" and
  showed the app to his motorbike friends unprompted.

29 Sep 2026:
- Added backup feature (export only). New file backup_service.dart.
- Shop Setup now has a "Backup" section with "Back up now" button.
- Installed path_provider and share_plus packages.
- Pinned compileSdk to 36 in build.gradle.kts to avoid SDK 35
  download (school computer had 36, not 35).
- Tested backup: exported full data as JSON, shared to Google Drive.
  File contains shop, customers, transactions with dates.
- RESTORE still not built — next session.

---

## 12. WHAT REAL USERS ARE TELLING US

This is evidence, not opinion. Update every session.

**Duka / motorbike circle (same plot) — September 2026:**

- Uses PesaBook daily since 26 Sep 2026
- Called me "developer" when we met on the road
- Showed the app to other motorbike riders unprompted
- One rider PAID OFF A DEBT specifically to stop being "number one"
  on the list. Nobody reminded him. Nobody messaged him. He just
  didn't want to be at the top of the list.
  → THIS IS THE MOST IMPORTANT FINDING. Social pressure from
  sorting by debt amount changes payment behaviour. It fell out
  of the "sort by highest debt" feature by accident.
- Two users have asked if the app is on Play Store
- One asked if the app can send M-Pesa payment prompts (STK Push)

**Juice shop owner (24 Sep 2026):**

- Asked if the app can send M-Pesa prompts instead of just
  recording payments
- NOTE: juice shops are usually pay-on-the-spot, not credit-based.
  He may not be the right user.

**Kiosk owner (same area, 28 Sep 2026):**

- Not approached yet. Witnessed a real customer dispute over what
  was written in her debt book. This is the exact problem PesaBook
  solves. Plan: go back in a quiet hour, use the dispute as the
  opening line.

---

## 13. THE HARD TRUTH TO REMEMBER

The idea is fine. The execution is on track. The technical work is
largely done. There is at least one real daily user.

The remaining risks are not technical:
- NOT BUILDING RESTORE. Backup exists but cannot be restored yet.
  This is the last step before Play Store.
- Not showing the app to more credit-selling shops.
- Losing the keystore / key.properties (see Section 4).
- Building features users didn't ask for.

On income: PesaBook will not pay bills in the near term. There is
no payment model, no user base, no distribution. Income must come
from elsewhere (matatu work, jobs) while PesaBook grows slowly in
the background. That is not failure — that is how most products are
actually built.

The goal is not to become a millionaire. The goal is to build
something real Kenyan shopkeepers actually use. One person is
already using it daily and telling his friends.

---

## 14. HOW TO START A NEW AI SESSION

Paste the whole file. Then say what you want to do next.
The AI will not remember you otherwise. This file is the memory.