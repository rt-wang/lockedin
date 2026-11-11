import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

struct QRCodeView: View {
  @Environment(\.foqosPalette) private var palette
  @Environment(\.dismiss) private var dismiss

  let url: String
  let profileName: String
  @State private var qrCodeImage: UIImage? = nil

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 10) {
          Text("Profile QR code")
            .foqosText(.eyebrow)
            .foregroundStyle(palette.mute)

          Text(profileName)
            .foqosDisplay(size: 34)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)

          Text("Scan this code without the app running to start or stop this profile.")
            .font(FoqosFont.ui(.subheadline, size: 15, bold: false))
            .foregroundStyle(palette.mute)
            .fixedSize(horizontal: false, vertical: true)
        }

        FoqosHairline()

        Group {
          if let qrCodeImage {
            Image(uiImage: qrCodeImage)
              .interpolation(.none)
              .resizable()
              .scaledToFit()
              .frame(width: 240, height: 240)
              .padding(12)
              .background(Color.white)
          } else {
            ProgressView()
              .frame(width: 264, height: 264)
          }
        }
        .frame(maxWidth: .infinity)

        Spacer(minLength: 0)

        if let qrCodeImage {
          ShareLink(
            item: Image(uiImage: qrCodeImage),
            preview: SharePreview(
              profileName,
              image: Image(uiImage: qrCodeImage)
            )
          ) {
            VStack(spacing: 0) {
              FoqosHairline(isStrong: true)
              HStack(alignment: .firstTextBaseline) {
                Text("Share QR code")
                  .foqosText(.cta)
                Spacer()
                Text("↗")
                  .foqosText(.cta)
                  .accessibilityHidden(true)
              }
              .padding(.top, 18)
              .padding(.bottom, 4)
              .frame(minHeight: 44)
            }
            .contentShape(Rectangle())
          }
          .buttonStyle(FoqosPressStyle())
        }
      }
      .padding(24)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(palette.background, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Close")
        }
      }
      .foqosTheme(palette)
      .onAppear {
        generateQRCode(from: url)
      }
    }
  }

  private func generateQRCode(from string: String) {
    // Create the QR code filter
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    // Set the input message
    let data = Data(string.utf8)
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")

    // Get the output image
    if let outputImage = filter.outputImage {
      // Scale the image
      let transform = CGAffineTransform(scaleX: 10, y: 10)
      let scaledImage = outputImage.transformed(by: transform)

      // Convert to UIImage
      if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
        self.qrCodeImage = UIImage(cgImage: cgImage)
      }
    }
  }
}
