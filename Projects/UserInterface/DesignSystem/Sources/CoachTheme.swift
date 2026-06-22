import SwiftUI

public enum CoachTheme {
    public static let canvas = Color(.systemGroupedBackground)
    public static let surface = Color(.secondarySystemGroupedBackground)
    public static let primaryText = Color.primary
    public static let secondaryText = Color.secondary
    public static let accent = Color.accentColor
    public static let tennisTint = Color(red: 0.34, green: 0.74, blue: 0.46)
    public static let courtBlue = Color(red: 0.24, green: 0.48, blue: 0.92)
    public static let glassStroke = Color.white.opacity(0.32)
    public static let glassShadow = Color.black.opacity(0.12)
}

public struct LiquidGlassBackground: View {
    public init() {}

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    CoachTheme.courtBlue.opacity(0.12),
                    CoachTheme.tennisTint.opacity(0.16),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.62)
        }
        .ignoresSafeArea()
    }
}

public struct CoachCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)

        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: shape)
        .overlay(alignment: .topLeading) {
            shape
                .strokeBorder(CoachTheme.glassStroke, lineWidth: 1)
                .blendMode(.plusLighter)
        }
        .shadow(color: CoachTheme.glassShadow, radius: 24, x: 0, y: 14)
        .shadow(color: Color.white.opacity(0.18), radius: 1, x: 0, y: 1)
    }
}

public struct PrimaryCoachButton: View {
    private let title: String
    private let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundStyle(Color.white)
                .background {
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.92),
                                    Color.black.opacity(0.76)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(Color.white.opacity(0.26), lineWidth: 1)
                                .blendMode(.plusLighter)
                        }
                        .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 10)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

public struct GlassIconButton: View {
    private let systemName: String
    private let action: () -> Void

    public init(systemName: String, action: @escaping () -> Void) {
        self.systemName = systemName
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline.weight(.bold))
                .frame(width: 44, height: 44)
                .foregroundStyle(CoachTheme.primaryText)
                .background(.thinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(CoachTheme.glassStroke, lineWidth: 1)
                }
                .shadow(color: CoachTheme.glassShadow, radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

public struct MetricPill: View {
    private let title: String
    private let value: String

    public init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)

        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(CoachTheme.secondaryText)
            Text(value)
                .font(.title3.weight(.heavy))
                .foregroundStyle(CoachTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: shape)
        .overlay {
            shape
                .strokeBorder(CoachTheme.glassStroke, lineWidth: 1)
        }
    }
}

public struct StatusCapsule: View {
    private let title: String
    private let tone: Tone

    public enum Tone {
        case neutral
        case active
        case warning
        case destructive

        var color: Color {
            switch self {
            case .neutral:
                Color.secondary
            case .active:
                CoachTheme.tennisTint
            case .warning:
                Color.orange
            case .destructive:
                Color.red
            }
        }
    }

    public init(_ title: String, tone: Tone = .neutral) {
        self.title = title
        self.tone = tone
    }

    public var body: some View {
        Text(title)
            .font(.caption.weight(.heavy))
            .foregroundStyle(tone.color)
            .padding(.horizontal, 12)
            .frame(minHeight: 30)
            .background(.thinMaterial, in: Capsule(style: .continuous))
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(tone.color.opacity(0.22), lineWidth: 1)
            }
    }
}

public struct CameraGlassPlaceholder: View {
    private let title: String
    private let subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                ZStack {
                    LinearGradient(
                        colors: [
                            CoachTheme.courtBlue.opacity(0.36),
                            CoachTheme.tennisTint.opacity(0.24),
                            Color.black.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 46, weight: .bold))
                        Text(title)
                            .font(.headline.weight(.heavy))
                        Text(subtitle)
                            .font(.caption.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                }
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.36), lineWidth: 1)
            }
            .shadow(color: CoachTheme.glassShadow, radius: 20, x: 0, y: 12)
    }
}
