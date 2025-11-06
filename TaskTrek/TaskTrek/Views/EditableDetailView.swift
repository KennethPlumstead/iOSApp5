
import SwiftUI

enum EditorResult { case save(TodoItem), cancel }

struct EditableDetailView: View {
    @Environment(\._appPrefs) private var prefs

    @State var item: TodoItem
    let isNew: Bool
    var onFinish: (EditorResult) -> Void

    @FocusState private var focusTitle: Bool

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Title", text: $item.title)
                    .focused($focusTitle)
                TextField("Notes", text: $item.notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                Toggle("Favorite", isOn: $item.isFavorite)
                Toggle("Completed", isOn: $item.isDone)
            }
            Section("Due Date") {
                DatePicker("Due",
                           selection: Binding($item.due, replacingNilWith: Date()),
                           displayedComponents: [.date])
            }
            Section("Meta") {
                LabeledContent("Created") { Text(item.createdAt, style: .date) }
                if let due = item.due {
                    LabeledContent("Due") { Text(due, style: .date) }
                }
            }
        }
        .navigationTitle(isNew ? "New Task" : "Details")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { onFinish(.cancel) }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { onFinish(.save(item)) }
                    .disabled(item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            if isNew { DispatchQueue.main.async { focusTitle = true } }
        }
    }
}
