# Phase 6 device test checklist

Use this on a real phone before each release. Tick each box. If something
fails, write down the phone, the theme and the language, and take a
screenshot.

## 0. Get the latest build onto your phone

Open the Terminal app on your Mac and paste these lines one at a time:

```
cd "/Users/baraka/Desktop/Blessed Bible"
git checkout main
git pull
flutter pub get
flutter run --release
```

`flutter run --release` asks which device to use if more than one is
connected. Type the number next to your phone and press Enter.

Test on at least: one small Android phone (about 5.5 inch), one large
Android phone, and one iPhone if you have one.

## 1. First launch (onboarding)

Uninstall the app first so you see onboarding again.

- [ ] The language step shows English, Français, Italiano, Română, Kiswahili, Tagalog.
- [ ] Choosing Français switches every following step to French at once.
- [ ] The Bible step suggests the Bible that matches the chosen language.
- [ ] The comfort step changes the page color and text size live.
- [ ] The reminder step only asks for notification permission after you turn the reminder on.
- [ ] The account step works offline: "Skip" goes straight into the app.
- [ ] Close the app on step 3 (swipe it away), reopen it: it resumes on step 3.

## 2. Languages

Repeat quickly for French, Swahili and Tagalog (Settings → Language).

- [ ] Every screen you open is in that language (Home, Read, Study, Plans, Your Space, Settings).
- [ ] No text is cut off with "…" where it should fit, and no yellow/black overflow stripes appear.
- [ ] A daily reminder notification arrives in that language (set it 2 minutes ahead to test).
- [ ] The home-screen widget shows its labels in that language (Android).

## 3. Themes

Settings → Appearance. Check Light, Sepia, Dark, OLED Dark, Dawn, Dusk and one more.

- [ ] Text is easy to read on every screen, including buttons on the gold accent.
- [ ] Card borders and dividers are visible but subtle.
- [ ] Sheets and dialogs have a dimmed background behind them.

## 4. Accessibility

Turn these on in the phone's settings, one at a time, then use the app for a minute.

**Largest text size** (Android: Settings → Display → Font size, maximum; iPhone: Settings → Accessibility → Display & Text Size → Larger Text, maximum)
- [ ] Onboarding, Settings, Plans and Read show all text without overlapping.
- [ ] Buttons grow with the text instead of clipping it.

**Screen reader** (Android: TalkBack; iPhone: VoiceOver)
- [ ] Every button on the bottom bar and top bar is read with a name, not "button" alone.
- [ ] In Read, double-tap-and-hold (or the actions menu) on a verse opens verse actions.
- [ ] In Your Space → Notes, each note has a delete button that is read aloud.
- [ ] Theme swatches and highlight colors are read by name.

**Remove animations** (Android: Settings → Accessibility → Remove animations; iPhone: Accessibility → Motion → Reduce Motion)
- [ ] Page changes jump instead of sliding; the background glow stops moving.
- [ ] Finishing a plan day shows the message without confetti.

**Increase contrast / Reduce transparency** (iPhone: Accessibility → Display & Text Size; Android: High contrast text)
- [ ] Frosted glass bars become solid.

## 5. Consistency

- [ ] Turn on airplane mode and open Commentary and Bible Stories: a friendly "Something went wrong" message with "Try again" appears, never technical error text.
- [ ] Deleting a bookmark or highlight shows "Undo" and Undo brings it back.
- [ ] Deleting a folder or your account asks you to confirm first.
- [ ] Buttons and titles use sentence case ("Save note", not "Save Note").

## 6. Sign-in and sync (regression)

- [ ] Sign in with Google from Your Space → account menu.
- [ ] Add a bookmark on phone A; it appears on phone B after sign-in.
- [ ] Sign out works and the app still opens offline.

## When you are done

Tell Claude which boxes failed (or "all passed"), with the phone model,
theme and language for each failure.
