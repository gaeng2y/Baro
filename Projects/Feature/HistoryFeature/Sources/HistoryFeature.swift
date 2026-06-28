import ComposableArchitecture
import DesignSystem
import SwiftUI
import TennisDomain

public struct HistoryState: Equatable {
    public var sessions: [TrainingSession]

    public init(sessions: [TrainingSession] = []) {
        self.sessions = sessions
    }
}

public enum HistoryAction: Equatable {
    case delete(UUID)
}

public struct HistoryReducer: Reducer {
    public typealias State = HistoryState
    public typealias Action = HistoryAction

    public init() {}

    public var body: some Reducer<HistoryState, HistoryAction> {
        Reduce { state, action in
            switch action {
            case let .delete(id):
                state.sessions.removeAll { $0.id == id }
                return .none
            }
        }
    }
}

public struct HistoryView: View {
    public let store: StoreOf<HistoryReducer>

    public init(sessions: [TrainingSession]) {
        self.init(
            store: Store(initialState: HistoryState(sessions: sessions)) {
                HistoryReducer()
            }
        )
    }

    public init(store: StoreOf<HistoryReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                LiquidGlassBackground()
                List {
                    if viewStore.sessions.isEmpty {
                        ContentUnavailableView(
                            "세션 기록 없음",
                            systemImage: "tennisball",
                            description: Text("첫 포핸드 또는 백핸드 세션을 시작해보세요.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewStore.sessions) { session in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(session.strokeType.title)
                                    .font(.headline.weight(.bold))
                                Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.thinMaterial)
                                    .padding(.vertical, 4)
                            )
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("히스토리")
    }
}
