import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            votdText: "Loading verse...",
            votdReference: "...",
            streakCount: 0,
            streakIsLit: false,
            wotdWord: "Grace (Charis)",
            wotdSnippet: "The unmerited favor and divine love of God bestowed upon humanity.",
            bgStyle: "gradient_dusk"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            votdText: "In the beginning, God created the heavens and the earth.",
            votdReference: "Genesis 1:1",
            streakCount: 5,
            streakIsLit: true,
            wotdWord: "Grace (Charis)",
            wotdSnippet: "The unmerited favor and divine love of God bestowed upon humanity.",
            bgStyle: "gradient_dusk"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.yourdomain.blessedbible")
        
        let votdText = userDefaults?.string(forKey: "votd_text") ?? "Open app to sync verse"
        let votdReference = userDefaults?.string(forKey: "votd_reference") ?? ""
        let streakCount = userDefaults?.integer(forKey: "streak_count") ?? 0
        let streakIsLit = userDefaults?.bool(forKey: "streak_is_lit") ?? false
        let wotdWord = userDefaults?.string(forKey: "wotd_word") ?? "Grace (Charis)"
        let wotdSnippet = userDefaults?.string(forKey: "wotd_snippet") ?? "The unmerited favor and divine love of God bestowed upon humanity."
        let bgStyle = userDefaults?.string(forKey: "widget_bg_style") ?? "gradient_dusk"
        
        let entry = SimpleEntry(
            date: Date(),
            votdText: votdText,
            votdReference: votdReference,
            streakCount: streakCount,
            streakIsLit: streakIsLit,
            wotdWord: wotdWord,
            wotdSnippet: wotdSnippet,
            bgStyle: bgStyle
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let votdText: String
    let votdReference: String
    let streakCount: Int
    let streakIsLit: Bool
    let wotdWord: String
    let wotdSnippet: String
    let bgStyle: String
}

struct VotdWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("VERSE OF THE DAY")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.yellow)
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            Text("\"\(entry.votdText)\"")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(4)
            
            Spacer(minLength: 0)
            
            HStack {
                Spacer()
                Text("— \(entry.votdReference)")
                    .font(.system(size: 11, weight: .bold))
                    .italic()
                    .foregroundColor(Color.white.opacity(0.8))
            }
        }
        .padding()
    }
}

struct StreakWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("🔥")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(entry.streakCount) Days")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(entry.streakIsLit ? "Active Streak!" : "Read Today")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(entry.streakIsLit ? .green : .gray)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            Text("WORD OF THE DAY")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.yellow)
            
            Text(entry.wotdWord)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            Text(entry.wotdSnippet)
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.8))
                .lineLimit(2)
        }
        .padding()
    }
}

@main
struct BlessedBibleWidgets: WidgetBundle {
    var body: some Widget {
        VotdWidget()
        StreakWidget()
    }
}

struct VotdWidget: Widget {
    let kind: String = "VotdWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                VotdWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetBackgroundView(style: entry.bgStyle)
                    }
            } else {
                VotdWidgetEntryView(entry: entry)
                    .background(WidgetBackgroundView(style: entry.bgStyle))
            }
        }
        .configurationDisplayName("Verse of the Day")
        .description("Daily verse for reflection.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                StreakWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetBackgroundView(style: entry.bgStyle)
                    }
            } else {
                StreakWidgetEntryView(entry: entry)
                    .background(WidgetBackgroundView(style: entry.bgStyle))
            }
        }
        .configurationDisplayName("Streak & Word of the Day")
        .description("Track reading streak & daily scripture dictionary term.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetBackgroundView: View {
    let style: String

    var body: some View {
        switch style {
        case "gradient_dawn":
            LinearGradient(colors: [Color(hex: 0xFF6B6B), Color(hex: 0xFF6C5B7B)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "gradient_emerald":
            LinearGradient(colors: [Color(hex: 0xFF064E3B), Color(hex: 0xFF0F766E)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "gradient_golden":
            LinearGradient(colors: [Color(hex: 0xFF78350F), Color(hex: 0xFFD97706)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "gradient_royal":
            LinearGradient(colors: [Color(hex: 0xFF0F172A), Color(hex: 0xFF1E3A8A)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "glass_light", "solid_light":
            Color.white
        case "glass_dark", "solid_dark":
            Color(hex: 0xFF18181B)
        case "transparent":
            Color.clear
        default: // gradient_dusk
            LinearGradient(colors: [Color(hex: 0xFF1A102F), Color(hex: 0xFF4A154B)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
