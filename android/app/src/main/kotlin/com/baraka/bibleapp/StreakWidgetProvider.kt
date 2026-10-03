package com.baraka.bibleapp

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StreakWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_streak).apply {
                // Read synced data from Flutter
                val streakCount = widgetData.getInt("streak_count", 0)
                val isLit = widgetData.getBoolean("streak_is_lit", false)
                val wotdWord = widgetData.getString("wotd_word", "Grace (Charis)") ?: "Grace (Charis)"
                val wotdSnippet = widgetData.getString("wotd_snippet", "The unmerited favor and divine love of God bestowed upon humanity.") ?: ""
                val bgStyle = widgetData.getString("widget_bg_style", "gradient_dusk") ?: "gradient_dusk"
                val textMode = widgetData.getString("widget_text_mode", "auto") ?: "auto"

                // Bind text
                setTextViewText(R.id.streak_count, "$streakCount Days")
                setTextViewText(R.id.wotd_word, wotdWord)
                setTextViewText(R.id.wotd_snippet, wotdSnippet)

                // Background & theme styling
                val isDark = applyWidgetTheme(context, this, bgStyle, textMode)

                if (isLit) {
                    setTextViewText(R.id.streak_subtitle, "Streak Active! 🔥")
                    setTextColor(R.id.streak_subtitle, if (isDark) Color.parseColor("#4ADE80") else Color.parseColor("#16A34A"))
                } else {
                    setTextViewText(R.id.streak_subtitle, "Read today to keep streak")
                    setTextColor(R.id.streak_subtitle, if (isDark) Color.parseColor("#D4D4D8") else Color.parseColor("#71717A"))
                }

                // Click Intent to open app
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    appWidgetId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun applyWidgetTheme(context: Context, views: RemoteViews, style: String, textMode: String): Boolean {
        val (drawableRes, defaultDark) = when (style) {
            "gradient_dawn" -> Pair(R.drawable.widget_bg_gradient_dawn, true)
            "gradient_dusk" -> Pair(R.drawable.widget_bg_gradient_dusk, true)
            "gradient_emerald" -> Pair(R.drawable.widget_bg_gradient_emerald, true)
            "gradient_golden" -> Pair(R.drawable.widget_bg_gradient_golden, true)
            "gradient_royal" -> Pair(R.drawable.widget_bg_gradient_royal, true)
            "glass_light" -> Pair(R.drawable.widget_bg_glass_light, false)
            "glass_dark" -> Pair(R.drawable.widget_bg_glass_dark, true)
            "solid_light" -> Pair(R.drawable.widget_bg_solid_light, false)
            "solid_dark" -> Pair(R.drawable.widget_bg_solid_dark, true)
            "transparent" -> Pair(R.drawable.widget_bg_transparent, true)
            else -> Pair(R.drawable.widget_bg_gradient_dusk, true)
        }

        views.setInt(R.id.widget_container, "setBackgroundResource", drawableRes)

        val isDark = when (textMode) {
            "light" -> false
            "dark" -> true
            else -> defaultDark
        }

        val primaryTextColor = if (isDark) Color.WHITE else Color.parseColor("#18181B")
        val secondaryTextColor = if (isDark) Color.parseColor("#D4D4D8") else Color.parseColor("#52525B")
        val labelColor = if (isDark) Color.parseColor("#FDE047") else Color.parseColor("#D97706")
        val dividerColor = if (isDark) Color.parseColor("#26FFFFFF") else Color.parseColor("#1F000000")

        views.setTextColor(R.id.streak_count, primaryTextColor)
        views.setTextColor(R.id.wotd_label, labelColor)
        views.setTextColor(R.id.wotd_word, primaryTextColor)
        views.setTextColor(R.id.wotd_snippet, secondaryTextColor)
        views.setInt(R.id.streak_divider, "setBackgroundColor", dividerColor)

        return isDark
    }
}
