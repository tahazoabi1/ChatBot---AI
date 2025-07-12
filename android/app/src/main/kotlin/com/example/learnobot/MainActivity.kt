package com.example.learnobot

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    init {
        System.loadLibrary("llama")   // exact name without "lib" prefix
    }
}
