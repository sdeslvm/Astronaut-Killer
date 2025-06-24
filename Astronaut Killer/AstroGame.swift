import SwiftUI
import Foundation

struct AstroEntryScreen: View {
    @StateObject private var loader: AstroWebLoader

    init(loader: AstroWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            AstroWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                AstroProgressIndicator(value: percent)
            case .failure(let err):
                AstroErrorIndicator(err: err)
            case .noConnection:
                AstroOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct AstroProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            AstroLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct AstroErrorIndicator: View {
    let err: String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct AstroOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
