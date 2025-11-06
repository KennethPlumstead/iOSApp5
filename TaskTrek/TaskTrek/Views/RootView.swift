
import SwiftUI
import Combine

struct RootView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\._appPrefs) private var prefs

    @State private var showingNewItem = false
    @State private var draft = TodoItem(title: "New Task", notes: "Tap to edit details")
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            List {
                if store.query.isEmpty {
                    ForEach(store.items) { item in row(item) }
                        .onMove(perform: store.move)
                } else {
                    ForEach(store.filteredItems) { item in row(item) }
                }
            }
            .navigationTitle("TaskTrek")
            .environment(\.editMode, $editMode)
            .searchable(text: $store.query, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(editMode == .active ? "Done" : "Reorder") {
                        withAnimation { editMode = (editMode == .active ? .inactive : .active) }
                    }
                    .disabled(!store.query.isEmpty)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ShareLink(item: exportText()) { Label("Share List", systemImage: "square.and.arrow.up") }
                        NavigationLink { SettingsView() } label: { Label("Settings", systemImage: "gearshape") }
                    } label: { Image(systemName: "ellipsis.circle") }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button {
                        draft = TodoItem(title: "", notes: "")
                        showingNewItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 54))
                            .shadow(radius: 3)
                            .padding(.trailing, 16)
                            .padding(.top, 6)
                    }
                }
            }
            .sheet(isPresented: $showingNewItem) {
                NavigationStack {
                    EditableDetailView(item: draft, isNew: true) { result in
                        switch result {
                        case .save(let newItem): store.add(newItem)
                        case .cancel: break
                        }
                        showingNewItem = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func row(_ item: TodoItem) -> some View {
        NavigationLink {
            EditableDetailView(item: item, isNew: false) { result in
                if case .save(let updated) = result { store.update(updated) }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? .secondary : .tertiary)
                    .symbolEffect(.bounce, value: item.isDone)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title.isEmpty ? "Untitled" : item.title)
                        .font(.headline)
                    if !item.notes.isEmpty {
                        Text(item.notes).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                    }
                    if let due = item.due {
                        Text(due, style: .date).font(.caption2).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if item.isFavorite { Image(systemName: "star.fill").foregroundStyle(.yellow) }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) { delete(item) } label: { Label("Delete", systemImage: "trash") }
        }
        .swipeActions(edge: .leading) {
            Button {
                var copy = item; copy.isFavorite.toggle(); store.update(copy)
            } label: { Label("Fav", systemImage: item.isFavorite ? "star.slash" : "star") }
            .tint(.yellow)

            Button {
                var copy = item; copy.isDone.toggle(); store.update(copy)
            } label: { Label("Done", systemImage: "checkmark") }
            .tint(.green)
        }
    }

    private func delete(_ item: TodoItem) {
        if let idx = store.items.firstIndex(of: item) {
            store.delete(at: IndexSet(integer: idx))
        }
    }

    private func exportText() -> String {
        var lines: [String] = ["TaskTrek export — \(Date.now.formatted(.dateTime))\n"]
        for t in store.items {
            let mark = t.isDone ? "[x]" : "[ ]"
            let star = t.isFavorite ? "★" : ""
            lines.append("\(mark) \(t.title.isEmpty ? "Untitled" : t.title) \(star)")
            if !t.notes.isEmpty { lines.append("  - \(t.notes)") }
        }
        return lines.joined(separator: "\n")
    }
}
