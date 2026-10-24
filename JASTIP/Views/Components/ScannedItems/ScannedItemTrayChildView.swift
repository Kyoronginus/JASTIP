import SwiftUI

struct ScannedItemTrayChildView: View {
    let item: RevealedPiece
    var traySize: CGFloat = 135
    
    // Cek piece lurus yang perlu di-tilt
    private var isLinearPiece: Bool {
        switch item.piece.shape {
        case .domino, .triominoI, .tetrominoI:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Background
                Image("tray")
                    .resizable()
                    .scaledToFit()
                    .frame(width: traySize, height: traySize)
                
                if let uiImage = UIImage(named: item.piece.assetName) {
                    let scale = traySize / 700
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(
                            width: uiImage.size.width * scale,
                            height: uiImage.size.height * scale
                        )
                        .rotationEffect(isLinearPiece ? .degrees(-45) : .zero)
                        .offset(y: -traySize * 0.085) // Presisi center mengimbangi shadow bawah baki
                        .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 2)
                } else {
                    Image(item.piece.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: traySize * 0.45, height: traySize * 0.45)
                        .rotationEffect(isLinearPiece ? .degrees(-45) : .zero)
                        .offset(y: -traySize * 0.035)
                }
            }

            VStack {
                Text("\(item.piece.color.categoryName): \(item.weight) kg")
                    .font(.spaceGrotesk(16, .bold))
                    .foregroundStyle(.primary)
                
                if !item.scannedBy.isEmpty {
                    Text(item.scannedBy)
                        .font(.spaceGrotesk(16, .regular))
                        .foregroundStyle(.primary)
                }
            }
            .padding(.top, -30)
        }
        .frame(width: traySize)
    }
}

#Preview {
    HStack() {
        ScannedItemTrayChildView(
            item: RevealedPiece(
                piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP2-9" })!,
                weight: 3,
                scannedBy: "david"
            )
        )

        ScannedItemTrayChildView(
            item: RevealedPiece(
                piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP1-9" })!,
                weight: 3,
                scannedBy: "david"
            )
        )
        ScannedItemTrayChildView(
            item: RevealedPiece(
                piece: PieceCatalog.allPieces.first(where: { $0.id == "JASTIP5-1" })!,
                weight: 4,
                scannedBy: "quincy"
            )
        )
    }
    .padding()
}
