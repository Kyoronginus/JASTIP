# JASTIP
a companion app for JASTIP, our boardgame.

## Firebase lobby setup

The lobby prototype uses Firebase Authentication with anonymous sign-in and Cloud
Firestore. In the Firebase Console for the same project as `GoogleService-Info.plist`:

1. Open **Authentication > Sign-in method** and enable **Anonymous**.
2. Open **Firestore Database > Rules**, replace the rules with the contents of
   [`firestore.rules`](./firestore.rules), and publish them.
3. Run `xcodegen generate`, then open `JASTIP.xcodeproj` and run the app on two devices
   or simulators. Create a lobby on one and join with its 4-letter code on the other.

The app synchronizes lobby membership, game setup, the host-controlled game clock and
events, player weights and boarding state, and scanned pieces through Firestore. The
lobby is a proof of concept: its short codes are easier to guess, any signed-in user who
knows a code can read the lobby, and there is no server-side rate limiting or host
migration. Do not use it for sensitive data or ship it publicly without strengthening
the backend.
