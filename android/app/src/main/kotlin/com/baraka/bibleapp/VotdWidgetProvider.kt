package com.baraka.bibleapp

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class VotdWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_votd).apply {
                val votdText = widgetData.getString("votd_text", "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.") ?: ""
                val votdRef = widgetData.getString("votd_reference", "John 3:16") ?: "John 3:16"
                val bgStyle = widgetData.getString("widget_bg_style", "gradient_dusk") ?: "gradient_dusk"
                val textMode = widgetData.getString("widget_text_mode", "auto") ?: "auto"

                setTextViewText(R.id.votd_text, votdText)
                setTextViewText(R.id.votd_reference, votdRef)

                applyWidgetTheme(context, this, bgStyle, textMode)

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

    private fun applyWidgetTheme(context: Context, views: RemoteViews, style: String, textMode: String) {
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

        views.setTextColor(R.id.votd_title, labelColor)
        views.setTextColor(R.id.votd_text, primaryTextColor)
        views.setTextColor(R.id.votd_reference, secondaryTextColor)
        views.setInt(R.id.votd_divider, "setBackgroundColor", dividerColor)
    }
}
