package com.baraka.bibleapp

import com.ryanheise.audioservice.AudioServiceActivity

// AudioServiceActivity (not FlutterActivity) is what lets the chapter audio
// keep playing with lock-screen and notification controls while the app is in
// the background.
class MainActivity : AudioServiceActivity()
