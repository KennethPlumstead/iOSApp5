
import Foundation
import SwiftUI
import Combine

@MainActor
final class TodoStore: ObservableObject {
    @Published private(set) var items: [TodoItem] = []
    @Published var query: String = ""

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("todos.json")
    }

    init() { Task { await load() } }

    func add(_ item: TodoItem) {
        items.insert(item, at: 0)
        Haptics.impact(.light)
        Task { await persist() }
    }

    func update(_ item: TodoItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        Task { await persist() }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        Haptics.impact(.soft)
        Task { await persist() }
    }

    func move(from: IndexSet, to: Int) {
        items.move(fromOffsets: from, toOffset: to)
        Task { await persist() }
    }

    private func loadSeedIfEmpty() {
        if items.isEmpty {
            items = [
                TodoItem(title: "Ship Assignment 8", notes: "Clean comments, hit 6+ features, push to GitHub."),
                TodoItem(title: "Polish portfolio site", notes: "Accessibility + perf + SEO basics.", isFavorite: true)
            ]
        }
    }

    func load() async {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([TodoItem].self, from: data)
            self.items = decoded
        } catch {
            loadSeedIfEmpty()
            await persist()
        }
    }

    func persist() async {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("⚠️ Persist error:", error)
        }
    }

    var filteredItems: [TodoItem] {
        guard !query.isEmpty else { return items }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.notes.localizedCaseInsensitiveContains(query)
        }
    }
}
