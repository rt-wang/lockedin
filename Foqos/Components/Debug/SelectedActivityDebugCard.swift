import FamilyControls
import SwiftUI

struct SelectedActivityDebugCard: View {
  let selection: FamilyActivitySelection

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Counts
      Group {
        DebugRow(label: "Applications Count", value: "\(selection.applications.count)")
        DebugRow(label: "Categories Count", value: "\(selection.categories.count)")
        DebugRow(label: "Web Domains Count", value: "\(selection.webDomains.count)")
      }

      // Applications Detail
      if !selection.applications.isEmpty {
        FoqosHairline()
        VStack(alignment: .leading, spacing: 4) {
          Text("Applications:")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("\(selection.applications.count) app(s) selected")
            .font(.caption)
            .foregroundStyle(.primary)
        }
      }

      // Categories Detail
      if !selection.categories.isEmpty {
        FoqosHairline()
        VStack(alignment: .leading, spacing: 4) {
          Text("Categories:")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("\(selection.categories.count) category(ies) selected")
            .font(.caption)
            .foregroundStyle(.primary)
        }
      }

      // Web Domains Detail
      if !selection.webDomains.isEmpty {
        FoqosHairline()
        VStack(alignment: .leading, spacing: 4) {
          Text("Web Domains:")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("\(selection.webDomains.count) domain(s) selected")
            .font(.caption)
            .foregroundStyle(.primary)
        }
      }
    }
  }
}

#Preview {
  SelectedActivityDebugCard(selection: FamilyActivitySelection())
    .padding()
}
