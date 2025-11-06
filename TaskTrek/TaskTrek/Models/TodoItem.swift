
import Foundation

struct TodoItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var notes: String
    var isFavorite: Bool
    var isDone: Bool
    var createdAt: Date
    var due: Date?

    init(id: UUID = UUID(),
         title: String,
         notes: String = "",
         isFavorite: Bool = false,
         isDone: Bool = false,
         createdAt: Date = .now,
         due: Date? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isFavorite = isFavorite
        self.isDone = isDone
        self.createdAt = createdAt
        self.due = due
    }
}
