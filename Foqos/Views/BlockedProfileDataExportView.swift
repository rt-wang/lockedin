import SwiftData
import SwiftUI

struct BlockedProfileDataExportView: View {
  @Environment(\.foqosPalette) private var palette

  @Environment(\.modelContext) private var context

  @Query(sort: [
    SortDescriptor(\BlockedProfiles.order, order: .forward),
    SortDescriptor(\BlockedProfiles.createdAt, order: .reverse),
  ]) private
    var profiles: [BlockedProfiles]

  @State private var selectedProfileIDs: Set<UUID> = []
  @State private var sortDirection: DataExportSortDirection = .ascending
  @State private var timeZone: DataExportTimeZone = .utc

  @State private var isExportPresented: Bool = false
  @State private var exportDocument: CSVDocument = .init(text: "")
  @State private var isGenerating: Bool = false
  @State private var errorMessage: String? = nil

  private var isExportDisabled: Bool {
    isGenerating || selectedProfileIDs.isEmpty
  }

  private var defaultFilename: String {
    let timestamp = Int(Date().timeIntervalSince1970)
    return "lockedin_sessions_\(timestamp)"
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          VStack(alignment: .leading, spacing: 8) {
            Text("Export data")
              .foqosDisplay(size: 40)
              .accessibilityAddTraits(.isHeader)
            Text("Download completed sessions as a CSV file.")
              .foqosText(.caption)
              .foregroundStyle(palette.mute)
          }
          .padding(.vertical, 4)
        }
        .foqosFormRows()
        .listRowSeparator(.hidden)

        Section {
          if profiles.isEmpty {
            Text("No profiles yet")
              .foqosText(.body)
              .foregroundStyle(palette.mute)
          } else {
            ForEach(profiles) { profile in
              let isSelected = selectedProfileIDs.contains(profile.id)
              HStack(alignment: .firstTextBaseline) {
                Text(profile.name)
                  .foqosText(.body)
                  .foregroundStyle(palette.foreground)
                Spacer()
                Text(isSelected ? "Selected" : "Select")
                  .foqosText(.mark)
                  .foregroundStyle(isSelected ? palette.foreground : palette.mute)
                  .padding(.bottom, 3)
                  .overlay(alignment: .bottom) {
                    Rectangle()
                      .fill(isSelected ? palette.foreground : .clear)
                      .frame(height: 1)
                  }
              }
              .frame(minHeight: 32)
              .contentShape(Rectangle())
              .onTapGesture { toggleSelection(for: profile.id) }
              .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
          }
        } header: {
          FoqosSectionHeader("Profiles")
        }
        .foqosFormRows()

        Section {
          Picker(selection: $sortDirection) {
            Text("Ascending (oldest first)").tag(DataExportSortDirection.ascending)
            Text("Descending (newest first)").tag(DataExportSortDirection.descending)
          } label: {
            Text("Sort order").foqosText(.body)
          }
          .pickerStyle(.menu)
        } header: {
          FoqosSectionHeader("Sorting")
        } footer: {
          Text("Controls the order of sessions in the CSV based on their start time.")
            .foqosText(.caption)
            .foregroundStyle(palette.mute)
        }
        .foqosFormRows()

        Section {
          Picker(selection: $timeZone) {
            Text("UTC").tag(DataExportTimeZone.utc)
            Text("Local").tag(DataExportTimeZone.local)
          } label: {
            Text("Time zone").foqosText(.body)
          }
          .pickerStyle(.menu)
        } header: {
          FoqosSectionHeader("Date & time")
        } footer: {
          Text(
            "Choose how timestamps are exported. UTC is portable across tools. Local uses your device's time zone. All timestamps use ISO 8601."
          )
          .foqosText(.caption)
          .foregroundStyle(palette.mute)
        }
        .foqosFormRows()

        Section {
          ActionButton(
            title: "Export as CSV",
            isLoading: isGenerating,
            isDisabled: isExportDisabled
          ) {
            generateAndExport()
          }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
      }
      .foqosForm(.cream)
      .toolbarBackground(FoqosColors.cream, for: .navigationBar)
      .navigationTitle("Export")
      .navigationBarTitleDisplayMode(.inline)
      .fileExporter(
        isPresented: $isExportPresented,
        document: exportDocument,
        contentType: .commaSeparatedText,
        defaultFilename: defaultFilename,
        onCompletion: { result in
          if case .failure(let error) = result {
            errorMessage = error.localizedDescription
          }
        }
      )
      .alert(
        "Export Error",
        isPresented: Binding(
          get: { errorMessage != nil },
          set: { if !$0 { errorMessage = nil } }
        )
      ) {
        Button("OK", role: .cancel) { errorMessage = nil }
      } message: {
        Text(errorMessage ?? "Unknown error")
      }
    }
  }

  private func toggleSelection(for id: UUID) {
    if selectedProfileIDs.contains(id) {
      selectedProfileIDs.remove(id)
    } else {
      selectedProfileIDs.insert(id)
    }
  }

  private func generateAndExport() {
    isGenerating = true
    do {
      let csv = try DataExporter.exportSessionsCSV(
        forProfileIDs: Array(selectedProfileIDs),
        in: context,
        sortDirection: sortDirection,
        timeZone: timeZone
      )
      exportDocument = CSVDocument(text: csv)
      isExportPresented = true
    } catch {
      errorMessage = error.localizedDescription
    }
    isGenerating = false
  }
}

#Preview {
  BlockedProfileDataExportView()
    .modelContainer(for: [BlockedProfiles.self, BlockedProfileSession.self], inMemory: true)
}
