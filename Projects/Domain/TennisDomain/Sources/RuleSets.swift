import Foundation

public protocol SwingRuleSet: Sendable {
    func analyze(metrics: SwingMetrics) -> [DetectedError]
}

public struct ForehandRuleSet: SwingRuleSet {
    public init() {}

    public func analyze(metrics: SwingMetrics) -> [DetectedError] {
        [
            error(
                when: metrics.shoulderTurnRange < 35,
                type: .shoulderTurnLack,
                severity: normalized(35 - metrics.shoulderTurnRange, scale: 35),
                cue: CoachingCueCatalog.cue(id: "fh-shoulder-turn"),
                phase: .backswing
            ),
            error(
                when: metrics.wristRelativeX < -0.08,
                type: .lateContact,
                severity: normalized(abs(metrics.wristRelativeX), scale: 0.3),
                cue: CoachingCueCatalog.cue(id: "fh-contact-front"),
                phase: .contact
            ),
            error(
                when: metrics.followThroughHeight < 0.58,
                type: .poorFollowThrough,
                severity: normalized(0.58 - metrics.followThroughHeight, scale: 0.58),
                cue: CoachingCueCatalog.cue(id: "fh-follow-high"),
                phase: .followThrough
            ),
            error(
                when: metrics.kneeFlexion < 0.18,
                type: .lowerBodyInactive,
                severity: normalized(0.18 - metrics.kneeFlexion, scale: 0.18),
                cue: CoachingCueCatalog.cue(id: "fh-knee-low"),
                phase: .preparation
            ),
            error(
                when: metrics.hipTurnRange < 18,
                type: .insufficientBodyRotation,
                severity: normalized(18 - metrics.hipTurnRange, scale: 18),
                cue: CoachingCueCatalog.cue(id: "fh-body-rotation"),
                phase: .forwardSwing
            )
        ].compactMap { $0 }
    }
}

public struct BackhandRuleSet: SwingRuleSet {
    public init() {}

    public func analyze(metrics: SwingMetrics) -> [DetectedError] {
        [
            error(
                when: metrics.shoulderTurnRange < 40,
                type: .shoulderTurnLack,
                severity: normalized(40 - metrics.shoulderTurnRange, scale: 40),
                cue: CoachingCueCatalog.cue(id: "bh-shoulder-more"),
                phase: .backswing
            ),
            error(
                when: metrics.hipTurnRange < 20,
                type: .insufficientBodyRotation,
                severity: normalized(20 - metrics.hipTurnRange, scale: 20),
                cue: CoachingCueCatalog.cue(id: "bh-body-first"),
                phase: .forwardSwing
            ),
            error(
                when: metrics.wristRelativeX < 0.18,
                type: .poorSpacing,
                severity: normalized(0.18 - metrics.wristRelativeX, scale: 0.18),
                cue: CoachingCueCatalog.cue(id: "bh-spacing"),
                phase: .contact
            ),
            error(
                when: metrics.wristRelativeX < -0.04,
                type: .lateContact,
                severity: normalized(abs(metrics.wristRelativeX), scale: 0.3),
                cue: CoachingCueCatalog.cue(id: "bh-contact-front"),
                phase: .contact
            ),
            error(
                when: metrics.followThroughHeight < 0.52,
                type: .poorFollowThrough,
                severity: normalized(0.52 - metrics.followThroughHeight, scale: 0.52),
                cue: CoachingCueCatalog.cue(id: "bh-finish"),
                phase: .followThrough
            )
        ].compactMap { $0 }
    }
}

private func error(
    when condition: Bool,
    type: CoachingErrorType,
    severity: Double,
    cue: CoachingCue,
    phase: SwingPhase
) -> DetectedError? {
    guard condition else { return nil }
    return DetectedError(type: type, severity: severity, cue: cue, phase: phase)
}

private func normalized(_ value: Double, scale: Double) -> Double {
    guard scale > 0 else { return 0 }
    return min(1, max(0, value / scale))
}
