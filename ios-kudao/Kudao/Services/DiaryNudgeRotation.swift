//
//  DiaryNudgeRotation.swift
//  Kudao
//

import Foundation

/// Decides which people each diary invitation talks about.
///
/// Naming every profile in every reminder turns the diary into a backlog: the
/// user reads a list of five people to write about and writes about none of
/// them. So an invitation mentions one or two people at most, chosen by who
/// Kudao knows the least about and whose date is closest, and the next slot
/// moves on to somebody else.
///
/// The rotation is a pure function of the fire date, not of when the reminders
/// happened to be rebuilt. Kudao reschedules its notifications on every app
/// launch, so a cursor that advanced per rebuild would reshuffle the queue all
/// day long and could name the same person twice in a row. Anchoring the
/// position to the calendar keeps a given slot stable no matter how often it is
/// recomputed.
nonisolated enum DiaryNudgeRotation {
    /// Most people a single invitation may mention.
    static let maxPerSlot: Int = 2

    /// Below this many candidates a slot names one person, so an invitation can
    /// never list everybody at once: with two profiles the pair format would be
    /// exactly the roll call this rotation exists to avoid.
    private static let pairThreshold: Int = 3

    /// Day the slots are counted from, so a date always maps to the same position.
    private static let epoch = Date(timeIntervalSince1970: 0)

    /// The people to mention at each of `dates`, in the same order.
    ///
    /// Returns an entry per date; an entry holds one or two people, never zero
    /// and never the whole roster.
    static func selections(
        for dates: [Date],
        among people: [DiaryNudgePerson],
        cadence: DiaryReminderCadence,
        calendar: Calendar = .current
    ) -> [[DiaryNudgePerson]] {
        guard !dates.isEmpty, !people.isEmpty else { return [] }

        let ranked = people.sorted(by: isHigherPriority)

        // A single candidate is the one case where repeating is right: the
        // alternative would be inviting the user to write about nobody.
        guard ranked.count > 1 else { return dates.map { _ in ranked } }

        let interval = max(1, cadence.intervalDays ?? 1)
        let perSlot = ranked.count >= pairThreshold ? maxPerSlot : 1

        // Seeded with the slot that precedes the first date, so the very first
        // invitation of a rebuild does not repeat the one already delivered.
        let firstSlot = slotNumber(for: dates[0], interval: interval, calendar: calendar)
        var previous = Set(
            pick(
                cursor: cursor(forSlot: firstSlot - 1, perSlot: perSlot, count: ranked.count),
                limit: perSlot,
                from: ranked,
                excluding: []
            ).map(\.id)
        )

        return dates.map { date in
            let slot = slotNumber(for: date, interval: interval, calendar: calendar)
            let chosen = pick(
                cursor: cursor(forSlot: slot, perSlot: perSlot, count: ranked.count),
                limit: perSlot,
                from: ranked,
                excluding: previous
            )
            previous = Set(chosen.map(\.id))
            return chosen
        }
    }

    /// Walks the ranked list from `cursor`, skipping whoever was just mentioned.
    ///
    /// A slot may come back with a single person rather than the full `limit`:
    /// staying quiet about someone is always better than nagging about them two
    /// invitations running.
    private static func pick(
        cursor: Int,
        limit: Int,
        from ranked: [DiaryNudgePerson],
        excluding previous: Set<UUID>
    ) -> [DiaryNudgePerson] {
        var picked: [DiaryNudgePerson] = []

        for offset in 0..<ranked.count where picked.count < limit {
            let person = ranked[(cursor + offset) % ranked.count]
            guard !previous.contains(person.id) else { continue }
            picked.append(person)
        }

        // Everyone was named last time, which only happens with very few
        // candidates. Rather than skip the invitation, fall back to whoever
        // needs a note most.
        if picked.isEmpty, let first = ranked.first {
            picked = [first]
        }

        return picked
    }

    /// Where in the ranked list a slot starts reading.
    private static func cursor(forSlot slot: Int, perSlot: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        let raw = slot * perSlot
        // Slot numbers are calendar-derived and stay positive in practice, but a
        // negative seed slot must still land inside the array.
        return ((raw % count) + count) % count
    }

    /// How many cadence intervals separate `date` from the epoch.
    private static func slotNumber(for date: Date, interval: Int, calendar: Calendar) -> Int {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: epoch),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        return Int((Double(days) / Double(interval)).rounded(.down))
    }

    /// Ranks by need first, falling back to the id so the order never wobbles
    /// between two rebuilds that see identical data.
    private static func isHigherPriority(_ lhs: DiaryNudgePerson, _ rhs: DiaryNudgePerson) -> Bool {
        if lhs.priorityScore != rhs.priorityScore {
            return lhs.priorityScore > rhs.priorityScore
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}
