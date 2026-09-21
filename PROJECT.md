# PesaBook — Project Memory

Last updated: 21 September 2026

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

Known testers:
- Mother (shopkeeper) — primary tester
- A shop owner in the same plot (approached 21 Sep, said busy)
- A teacher who requested the APK — not yet delivered
- A motorbike/Bolt rider — fit uncertain, deprioritized

NOTE: Stop counting testers who don't actually extend credit.

PITCH (Swahili, memorize this):
"Ni kitabu cha deni kwa simu — unaandika nani anakudai na pesa
ngapi, na inakuonyesha."

Translation: "It's a debt book for the phone — you write who owes you
and how much, and it shows you."

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
- flutter_lints ^6.0.0
- flutter_launcher_icons ^0.14.4 (dev)

Storage: SharedPreferences via StorageService.
No Firebase, no SQLite, no backend, no login.

Build command:
C:\flutter\bin\flutter.bat build apk
Output:
build\app\outputs\flutter-apk\app-release.apk
Last known APK size: 47.2 MB (STILL TOO BIG — see next actions)

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

TESTED: As of 21 Sep 2026, a signed APK installed over an existing
PesaBook install WITHOUT requiring uninstall. This is the proof
signing works. Future updates install cleanly.

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
- Debt age shown on each customer row ("today", "3 days", "2 months")
- App icon (PB wordmark on purple background)
- Release builds signed with PesaBook keystore

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

STILL OPEN (priority order):

1. "Balance: KES X" label in transaction history is ambiguous.
   It means balance AFTER that transaction, not current balance.
   Rename to "Remaining: KES X" or "After: KES X".

2. No record that a reminder was sent.
   If a shopkeeper sends dommy a WhatsApp reminder today, nothing
   is recorded. They can double-send and look like a nag.
   Add a "Reminder sent" entry to transaction history (greyed out,
   does not affect balance).

3. No backup/export feature.
   If a shopkeeper's phone breaks, or they reinstall the app, all
   records vanish. This is a trust-killer for real users.
   Should be the next major feature.

4. APK is 47.2 MB. Too large for WhatsApp sharing on limited data.
   Try: flutter build apk --split-per-abi

5. Icon source image was not square (999x642), so the launcher icon
   has white bands on the sides. Works, but looks slightly unpolished.
   Fix later with a square source PNG.

6. No transaction edit/delete.
   DECISION (16 Sep): Do NOT add general edit/delete. Instead:
    - Confirmation dialog before save (DONE)
    - Later: undo last transaction within a short window
    - Much later: Adjustment transaction type for legitimate corrections
      Reason: an editable money ledger can be doubted. Trust matters more.

7. SharedPreferences may need migration to SQLite eventually.
   It was designed for key-value flags, not money ledgers. Risk of
   data loss at scale. Not urgent for now, but plan for it before
   real users trust it with large amounts of money.

8. Signature mismatch is solved, but building on a new machine
   requires the keystore + key.properties setup (see Section 4).

---

## 7. NEXT ACTIONS (in order)

1. Update this PROJECT.md after every session.
2. Show the app to 3 more shopkeepers. Use the Swahili pitch.
   Ask the questions in Section 8. Write down what they say.
   DO NOT BUILD MORE FEATURES before this.
3. Add reminder logging (item 2 above).
4. Add backup/export (item 3 above).
5. Rename "Balance" label in transaction history (item 1).
6. Reduce APK size with --split-per-abi (item 4).
7. Fix icon to square source (item 5).

---

## 8. TESTING QUESTIONS TO ASK REAL USERS

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

## 9. RULES FOR WORKING ON THIS PROJECT

- Simple → useful → tested with real people → improve from evidence.
- Do not add features that have not been requested by real users.
- Commit after every working change. Push to GitHub.
- Run `flutter analyze` before every commit.
- Update this file whenever a decision is made or a bug is found.
- When starting a new AI chat, paste this entire file first.
- If the build fails with a memory error, check gradle.properties
  has -Xmx2G (not -Xmx8G — school computers can't handle 8 GB).

---

## 10. SESSION LOG

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
- Showed app to shopkeeper in same plot (said busy, no pitch yet)

---

## 11. THE HARD TRUTH TO REMEMBER

The idea is fine. The execution is on track. The technical work is
largely done.

The remaining risks are not technical:
- Not showing the app to real users out of fear.
- Building features users didn't ask for.
- Losing the keystore / key.properties (see Section 4).
- Handing the app to real shopkeepers before backup exists.

The goal is not to become a millionaire. The goal is to build
something real Kenyan shopkeepers actually use. The app is at the
point where showing it to people is more valuable than adding
features. Do that first. Then build what they tell you to build.

---

## 12. HOW TO START A NEW AI SESSION

Paste the whole file. Then say what you want to do next.
The AI will not remember you otherwise. This file is the memory.