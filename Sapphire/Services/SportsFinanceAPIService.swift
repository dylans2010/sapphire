import Foundation

@MainActor
final class SportsAPIService {
    static let shared = SportsAPIService()

    private var cachedEvents: [String: LiveSportsEvent] = [:]
    private var cachedComments: [String: SportsComment] = [:]

    private init() {}

    func bootstrapIfNeeded() {}

    func cachedLiveEvent(for teamOrLeague: String) -> LiveSportsEvent? {
        cachedEvents[teamOrLeague]
    }

    func peekLatestCommentary(for event: LiveSportsEvent) -> SportsComment? {
        cachedComments[event.eventId]
    }

    func prefetchLiveScoreboards(for teams: [String]) async {}

    func fetchLiveEvent(for teamOrLeague: String, forceRefresh: Bool = false) async -> LiveSportsEvent? {
        cachedEvents[teamOrLeague]
    }
}

enum SportsFinanceContentProvider {
    static func makeSportsPayload(from event: LiveSportsEvent) -> SportsPayload {
        SportsPayload(
            league: event.leagueRoute.shortName ?? event.leagueRoute.displayName,
            homeTeam: event.homeTeam,
            awayTeam: event.awayTeam,
            homeScore: event.homeScore,
            awayScore: event.awayScore,
            status: event.isLive ? "Live" : event.status,
            time: event.clock,
            homeLogoURL: event.homeLogoURL,
            awayLogoURL: event.awayLogoURL
        )
    }

    static func makeSportsPayload(for teamOrLeague: String, index: Int) -> SportsPayload {
        SportsPayload(
            league: teamOrLeague,
            homeTeam: teamOrLeague,
            awayTeam: "Opponent",
            homeScore: 0,
            awayScore: 0,
            status: "Scheduled",
            time: "--"
        )
    }
}

@MainActor
final class FinanceAPIService {
    static let shared = FinanceAPIService()

    private var cachedQuotes: [String: FinancePayload] = [:]

    private init() {}

    func cachedQuote(symbol: String) -> FinancePayload? {
        cachedQuotes[symbol.uppercased()]
    }

    func fetchQuote(symbol: String) async -> FinancePayload? {
        cachedQuotes[symbol.uppercased()]
    }

    func makePayload(symbol: String, index: Int, quote: FinancePayload?) -> FinancePayload {
        quote ?? FinancePayload(
            symbol: symbol.uppercased(),
            price: "$0.00",
            change: "+0.00",
            changePercent: "+0.00%",
            isPositive: true,
            name: symbol.uppercased(),
            isAfterHours: false,
            closingPrice: nil
        )
    }
}
