//
//  DiaryExportRenderer.swift
//  Kudao
//

import Foundation
import UIKit

/// Turns a diary snapshot into shareable JSON or a paginated PDF.
nonisolated enum DiaryExportRenderer {

    // MARK: - JSON

    private struct Payload: Encodable {
        struct Profile: Encodable {
            let id: String
            let name: String
            let birth_date: Date
            let relationship: String
            let surprise_mode: Bool
            let created_at: Date
            let next_birthday: Date
            let turning_age: Int
        }

        struct Note: Encodable {
            let id: String
            let text: String
            let created_at: Date
            let extraction_status: String
            let category: String?
            let keywords: [String]
            let summary: String
            let gift_relevant: Bool
        }

        struct Keywords: Encodable {
            let category: String
            let values: [String]
        }

        struct Plan: Encodable {
            let regalo: String
            let fascia_prezzo: String
            let motivazione_regalo: String
            let torta: String
            let motivazione_torta: String
            let locale_tipo: String
            let motivazione_locale: String
            let numero_invitati: Int
            let confidenza: String
            let generated_at: Date
            let confermato_at: Date?
        }

        let app = "Kudao"
        let schema_version = 1
        let exported_at: Date
        let profile: Profile
        let diary_notes: [Note]
        let diary_tags: [Keywords]
        let party_plan: Plan?
    }

    static func json(_ snapshot: DiaryExportSnapshot) throws -> Data {
        let payload = Payload(
            exported_at: snapshot.exportedAt,
            profile: Payload.Profile(
                id: snapshot.profileID.uuidString,
                name: snapshot.name,
                birth_date: snapshot.birthDate,
                relationship: snapshot.relationship.rawValue,
                surprise_mode: snapshot.isSurpriseMode,
                created_at: snapshot.createdAt,
                next_birthday: snapshot.nextBirthday,
                turning_age: snapshot.turningAge
            ),
            diary_notes: snapshot.notes.map { note in
                Payload.Note(
                    id: note.id.uuidString,
                    text: note.text,
                    created_at: note.createdAt,
                    extraction_status: note.status,
                    category: note.category,
                    keywords: note.keywords,
                    summary: note.summary,
                    gift_relevant: note.isGiftRelevant
                )
            },
            diary_tags: snapshot.keywords.map {
                Payload.Keywords(category: $0.category.rawValue, values: $0.values)
            },
            party_plan: snapshot.plan.map { plan in
                Payload.Plan(
                    regalo: plan.giftIdea,
                    fascia_prezzo: plan.giftPriceBand.rawValue,
                    motivazione_regalo: plan.giftReason,
                    torta: plan.cakeType,
                    motivazione_torta: plan.cakeReason,
                    locale_tipo: plan.venueIdea,
                    motivazione_locale: plan.venueReason,
                    numero_invitati: plan.guestCount,
                    confidenza: plan.confidence.rawValue,
                    generated_at: plan.generatedAt,
                    confermato_at: plan.confirmedAt
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601

        do {
            return try encoder.encode(payload)
        } catch {
            throw DiaryExportError.encodingFailed
        }
    }

    // MARK: - PDF

    private static let pageSize = CGSize(width: 595.2, height: 841.8) // A4 at 72 dpi
    private static let margin: CGFloat = 48

    static func pdf(_ snapshot: DiaryExportSnapshot, strings: Strings, locale: Locale) -> Data {
        let text = attributedDocument(snapshot, strings: strings, locale: locale)
        let bounds = CGRect(origin: .zero, size: pageSize)
        let textRect = bounds.insetBy(dx: margin, dy: margin)

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle as String: String(format: strings.exportDocumentTitleFormat, snapshot.name),
            kCGPDFContextCreator as String: "Kudao",
        ]

        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)
        let framesetter = CTFramesetterCreateWithAttributedString(text)
        let path = CGPath(rect: textRect, transform: nil)

        return renderer.pdfData { context in
            var cursor = 0
            var pageIndex = 0

            repeat {
                context.beginPage()
                let cgContext = context.cgContext
                cgContext.textMatrix = .identity
                cgContext.translateBy(x: 0, y: bounds.height)
                cgContext.scaleBy(x: 1, y: -1)

                let frame = CTFramesetterCreateFrame(
                    framesetter,
                    CFRange(location: cursor, length: 0),
                    path,
                    nil
                )
                CTFrameDraw(frame, cgContext)

                let visible = CTFrameGetVisibleStringRange(frame)
                if visible.length <= 0 { break }
                cursor += visible.length
                pageIndex += 1
            } while cursor < text.length && pageIndex < 200
        }
    }

    // MARK: - Document composition

    private static func attributedDocument(
        _ snapshot: DiaryExportSnapshot,
        strings: Strings,
        locale: Locale
    ) -> NSAttributedString {
        let document = NSMutableAttributedString()

        document.append(
            line(
                String(format: strings.exportDocumentTitleFormat, snapshot.name),
                font: rounded(26, .heavy),
                color: UIColor(red: 0.949, green: 0.329, blue: 0.176, alpha: 1),
                spacingAfter: 4
            )
        )
        document.append(
            line(
                String(format: strings.exportGeneratedAtFormat, longDate(snapshot.exportedAt, locale: locale)),
                font: rounded(10.5, .medium),
                color: .secondaryLabel,
                spacingAfter: 20
            )
        )

        // Profile
        document.append(heading(strings.exportProfileSection))
        document.append(
            field(strings.birthDateLabel, longDate(snapshot.birthDate, locale: locale))
        )
        document.append(
            field(strings.relationshipLabel, snapshot.relationship.title(strings))
        )
        document.append(
            field(
                strings.nextBirthdayLabel,
                "\(longDate(snapshot.nextBirthday, locale: locale)) · \(String(format: strings.turnsFormat, snapshot.turningAge))"
            )
        )
        document.append(spacer(14))

        // Party plan
        document.append(heading(strings.exportPlanSection))
        if let plan = snapshot.plan {
            document.append(
                field(
                    strings.giftCardTitle,
                    "\(plan.giftIdea) (\(plan.giftPriceBand.title(strings)))",
                    detail: plan.giftReason
                )
            )
            document.append(field(strings.cakeCardTitle, plan.cakeType, detail: plan.cakeReason))
            document.append(field(strings.venueCardTitle, plan.venueIdea, detail: plan.venueReason))
            document.append(
                field(strings.guestsCardTitle, String(format: strings.guestsUnitFormat, plan.guestCount))
            )
            document.append(
                field(strings.confidenceLabel, plan.confidence.title(strings))
            )
            if let confirmedAt = plan.confirmedAt {
                document.append(
                    field(
                        "",
                        String(format: strings.confirmedAtFormat, longDate(confirmedAt, locale: locale))
                    )
                )
            }
        } else {
            document.append(
                line(strings.exportNoPlan, font: rounded(11, .regular), color: .secondaryLabel, spacingAfter: 6)
            )
        }
        document.append(spacer(14))

        // Keywords
        document.append(heading(strings.tagsSection))
        if snapshot.keywords.isEmpty {
            document.append(
                line(
                    strings.preferencesEmptyMessage,
                    font: rounded(11, .regular),
                    color: .secondaryLabel,
                    spacingAfter: 6
                )
            )
        } else {
            for bucket in snapshot.keywords {
                document.append(
                    field(bucket.category.title(strings), bucket.values.joined(separator: ", "))
                )
            }
        }
        document.append(spacer(14))

        // Notes
        document.append(
            heading("\(strings.exportNotesSection) (\(snapshot.notes.count))")
        )
        if snapshot.notes.isEmpty {
            document.append(
                line(strings.exportNoNotes, font: rounded(11, .regular), color: .secondaryLabel, spacingAfter: 6)
            )
        } else {
            for note in snapshot.notes {
                document.append(
                    line(
                        dateTime(note.createdAt, locale: locale),
                        font: rounded(9.5, .bold),
                        color: .tertiaryLabel,
                        spacingAfter: 2
                    )
                )
                document.append(
                    line(note.text, font: rounded(12, .regular), color: .label, spacingAfter: 3)
                )

                var meta: [String] = []
                if let category = note.category {
                    meta.append(DiaryCategory.parse(category).title(strings))
                }
                if !note.keywords.isEmpty {
                    meta.append(note.keywords.joined(separator: ", "))
                }
                if note.isGiftRelevant {
                    meta.append(strings.giftIdeaBadge)
                }
                if !meta.isEmpty {
                    document.append(
                        line(
                            meta.joined(separator: " · "),
                            font: rounded(9.5, .medium),
                            color: .secondaryLabel,
                            spacingAfter: 12
                        )
                    )
                } else {
                    document.append(spacer(12))
                }
            }
        }

        return document
    }

    // MARK: - Building blocks

    private static func heading(_ title: String) -> NSAttributedString {
        line(
            title.uppercased(),
            font: rounded(11, .heavy),
            color: UIColor(red: 0.627, green: 0.337, blue: 0.231, alpha: 1),
            spacingAfter: 8,
            kern: 1.1
        )
    }

    private static func field(_ label: String, _ value: String, detail: String = "") -> NSAttributedString {
        let block = NSMutableAttributedString()
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let headline = label.isEmpty ? cleanValue : "\(label): \(cleanValue)"

        block.append(
            line(
                headline,
                font: rounded(12, .semibold),
                color: .label,
                spacingAfter: detail.isEmpty ? 6 : 2
            )
        )
        if !detail.isEmpty {
            block.append(
                line(detail, font: rounded(10.5, .regular), color: .secondaryLabel, spacingAfter: 8)
            )
        }
        return block
    }

    private static func spacer(_ height: CGFloat) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = height
        return NSAttributedString(
            string: "\n",
            attributes: [.font: rounded(1, .regular), .paragraphStyle: style]
        )
    }

    private static func line(
        _ text: String,
        font: UIFont,
        color: UIColor,
        spacingAfter: CGFloat,
        kern: CGFloat = 0
    ) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = spacingAfter
        style.lineSpacing = 2
        style.lineBreakMode = .byWordWrapping

        return NSAttributedString(
            string: text.isEmpty ? " \n" : "\(text)\n",
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: style,
                .kern: kern,
            ]
        )
    }

    private static func rounded(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }

    private static func longDate(_ date: Date, locale: Locale) -> String {
        date.formatted(
            Date.FormatStyle(locale: locale)
                .day(.defaultDigits)
                .month(.wide)
                .year()
        )
    }

    private static func dateTime(_ date: Date, locale: Locale) -> String {
        date.formatted(
            Date.FormatStyle(locale: locale)
                .day(.defaultDigits)
                .month(.wide)
                .year()
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.twoDigits)
        )
    }
}
