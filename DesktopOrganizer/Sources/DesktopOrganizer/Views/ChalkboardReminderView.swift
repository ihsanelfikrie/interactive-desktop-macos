import SwiftUI
import AppKit

// MARK: - Minimalist Chalkboard Theme Tokens
public struct ChalkColors {
    public static let primary = Color(white: 0.94)       // Clean off-white
    public static let secondary = Color(white: 0.80)     // Subtle header white
    public static let muted = Color(white: 0.58)         // Clean muted grey
    public static let subtle = Color(white: 0.38)
    public static let border = Color.white.opacity(0.15)
    public static let cardBg = Color.white.opacity(0.04)
    public static let cardBorder = Color.white.opacity(0.10)
    
    // Compatibility aliases
    public static let white = Color(white: 0.94)
    public static let yellow = Color(white: 0.94)
    public static let mint = Color(white: 0.80)
    public static let pink = Color(white: 0.80)
}

// MARK: - Hoss Round Typography
public struct ChalkboardTypography {
    public static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let postscriptName: String
        switch weight {
        case .bold, .heavy, .black:
            postscriptName = "HossRound-Bold"
        case .semibold, .medium:
            postscriptName = "HossRound-Medium"
        case .light, .ultraLight, .thin:
            postscriptName = "HossRound-Light"
        default:
            postscriptName = "HossRound-Regular"
        }
        
        if NSFont(name: postscriptName, size: size) != nil {
            return .custom(postscriptName, size: size)
        } else if NSFont(name: "Hoss Round", size: size) != nil {
            return .custom("Hoss Round", size: size).weight(weight)
        } else {
            return .system(size: size, weight: weight, design: .rounded)
        }
    }
}

// MARK: - Chalk Dust Text Halo Modifier
extension View {
    public func chalkGlow(opacity: Double = 0.16) -> some View {
        self.shadow(color: Color.white.opacity(opacity), radius: 0.6, x: 0, y: 0)
    }
}

// MARK: - Chalkboard Daily Reminder View
public struct ChalkboardReminderView: View {
    @ObservedObject var reminderManager = DailyReminderManager.shared
    let boardW: CGFloat
    let boardH: CGFloat
    
    public init(boardW: CGFloat, boardH: CGFloat) {
        self.boardW = boardW
        self.boardH = boardH
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar: Day & Date
            chalkHeaderBar
                .padding(.horizontal, 14)
                .padding(.top, 42) // Below top-center Bismillah ligature
                .padding(.bottom, 4)
            
            // Subtle chalk divider line
            chalkDashedDivider
                .padding(.horizontal, 14)
                .padding(.bottom, 6)
            
            // Content Body
            if reminderManager.data.isEmpty {
                emptyChalkState
            } else {
                taskContentScrollView
            }
            
            Spacer(minLength: 28) // Space for bottom rail toolbar
        }
        .frame(width: boardW, height: boardH)
    }
    
    // MARK: - Header Bar (Clean & Emoji-Free)
    private var chalkHeaderBar: some View {
        HStack(alignment: .center, spacing: 6) {
            let displayDay = reminderManager.data.day.isEmpty ? formattedCurrentDate : reminderManager.data.day
            Text(displayDay.uppercased())
                .font(ChalkboardTypography.font(size: 10, weight: .bold))
                .foregroundColor(ChalkColors.primary)
                .chalkGlow(opacity: 0.25)
                .lineLimit(1)
            
            Spacer()
        }
    }
    
    // MARK: - Chalk Dashed Divider
    private var chalkDashedDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(height: 1)
            .overlay(
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundColor(Color.white.opacity(0.16))
            )
    }
    
    // MARK: - Empty State (Clean & Simple)
    private var emptyChalkState: some View {
        VStack(spacing: 6) {
            Spacer()
            
            Text("Belum ada tugas hari ini.")
                .font(ChalkboardTypography.font(size: 11, weight: .bold))
                .foregroundColor(ChalkColors.primary)
                .chalkGlow(opacity: 0.2)
            
            Text("Selamat berkarya!")
                .font(ChalkboardTypography.font(size: 9.5, weight: .regular))
                .foregroundColor(ChalkColors.muted)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Task Content ScrollView
    private var taskContentScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                // Section 1: Ritme & Fokus Hari Ini
                if !reminderManager.data.schedules.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RITME & FOKUS")
                            .font(ChalkboardTypography.font(size: 8.5, weight: .bold))
                            .foregroundColor(ChalkColors.secondary)
                            .chalkGlow(opacity: 0.18)
                        
                        ForEach(reminderManager.data.schedules, id: \.self) { schedule in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(ChalkboardTypography.font(size: 9, weight: .bold))
                                    .foregroundColor(ChalkColors.muted)
                                Text(schedule)
                                    .font(ChalkboardTypography.font(size: 9))
                                    .foregroundColor(ChalkColors.primary)
                                    .chalkGlow(opacity: 0.10)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                
                // Section 2: Tugas Aktif (Command Center)
                if !reminderManager.data.masterTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TUGAS AKTIF HARI INI")
                            .font(ChalkboardTypography.font(size: 8.5, weight: .bold))
                            .foregroundColor(ChalkColors.secondary)
                            .chalkGlow(opacity: 0.18)
                        
                        ForEach(reminderManager.data.masterTasks, id: \.self) { task in
                            let cleaned = cleanTaskBullet(task)
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(ChalkboardTypography.font(size: 9, weight: .bold))
                                    .foregroundColor(ChalkColors.muted)
                                Text(cleaned)
                                    .font(ChalkboardTypography.font(size: 9))
                                    .foregroundColor(ChalkColors.primary)
                                    .chalkGlow(opacity: 0.10)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                
                // Section 3: Custom Frame Prioritas (H-3 s.d H-1)
                if !reminderManager.data.urgentFrames.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CUSTOM FRAME PRIORITAS")
                            .font(ChalkboardTypography.font(size: 8.5, weight: .bold))
                            .foregroundColor(ChalkColors.secondary)
                            .chalkGlow(opacity: 0.18)
                        
                        ForEach(reminderManager.data.urgentFrames) { frame in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 5) {
                                    Text(frame.reminder)
                                        .font(ChalkboardTypography.font(size: 7.5, weight: .bold))
                                        .foregroundColor(ChalkColors.primary)
                                        .padding(.horizontal, 3.5)
                                        .padding(.vertical, 1)
                                        .background(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(ChalkColors.border, lineWidth: 0.8)
                                        )
                                    
                                    Text(frame.nama)
                                        .font(ChalkboardTypography.font(size: 8.5, weight: .bold))
                                        .foregroundColor(ChalkColors.primary)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text("DL: \(frame.deadline)")
                                        .font(ChalkboardTypography.font(size: 7.5, weight: .medium))
                                        .foregroundColor(ChalkColors.muted)
                                }
                                
                                if !frame.brief.isEmpty {
                                    let cleanBrief = frame.brief.replacingOccurrences(of: "\n", with: " ")
                                    Text(cleanBrief)
                                        .font(ChalkboardTypography.font(size: 7.5))
                                        .foregroundColor(ChalkColors.muted)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(ChalkColors.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(ChalkColors.cardBorder, lineWidth: 0.6)
                                    )
                            )
                        }
                    }
                }
                
                // Fallback: If only rawText was present without structured arrays
                if reminderManager.data.schedules.isEmpty &&
                   reminderManager.data.masterTasks.isEmpty &&
                   reminderManager.data.urgentFrames.isEmpty &&
                   !reminderManager.data.rawText.isEmpty {
                    Text(reminderManager.data.rawText)
                        .font(ChalkboardTypography.font(size: 8.5))
                        .foregroundColor(ChalkColors.primary)
                        .chalkGlow(opacity: 0.10)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 2)
        }
    }
    
    // MARK: - Helpers
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMM yyyy"
        return formatter.string(from: Date())
    }
    
    private func cleanTaskBullet(_ task: String) -> String {
        var str = task
        if str.hasPrefix("• ") {
            str = String(str.dropFirst(2))
        } else if str.hasPrefix("- ") {
            str = String(str.dropFirst(2))
        }
        return str
    }
}
