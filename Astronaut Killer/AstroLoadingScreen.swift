import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol AstroProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol AstroBackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct AstroLoadingOverlay<Background: View>: View, AstroProgressDisplayable {
    let progress: Double
    let backgroundView: Background

    var progressPercentage: Int { Int(progress * 100) }

    init(progress: Double, @ViewBuilder background: () -> Background) {
        self.progress = progress
        self.backgroundView = background()
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundView
                content(in: geo)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func content(in geometry: GeometryProxy) -> some View {
        let isLandscape = geometry.size.width > geometry.size.height

        return Group {
            if isLandscape {
                horizontalLayout(in: geometry)
            } else {
                verticalLayout(in: geometry)
            }
        }
    }

    private func verticalLayout(in geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            // --- Космическая сцена ---
            ZStack {
                // Планета
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "#2E335A"), Color(hex: "#1B1E3C")]), startPoint: .top, endPoint: .bottom))
                    .frame(width: geometry.size.width * 0.45, height: geometry.size.width * 0.45)
                    .shadow(color: Color.blue.opacity(0.5), radius: 30, x: 0, y: 20)
                // Кольцо-орбита (прогресс)
                AstroOrbitProgress(progress: progress)
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                // Маленькая летающая комета
                AstroComet(progress: progress)
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                // Звезды
                AstroStars()
            }
            .frame(height: geometry.size.width * 0.7)
            .padding(.top, 30)

            // Текст прогресса
            Text("Astro Launching... \(progressPercentage)%")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [.yellow, .white], startPoint: .leading, endPoint: .trailing))
                .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                .padding(.top, 16)

            Spacer()
        }
    }

    private func horizontalLayout(in geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            ZStack {
                // Планета
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "#2E335A"), Color(hex: "#1B1E3C")]), startPoint: .top, endPoint: .bottom))
                    .frame(width: geometry.size.height * 0.45, height: geometry.size.height * 0.45)
                    .shadow(color: Color.blue.opacity(0.5), radius: 30, x: 0, y: 20)
                // Кольцо-орбита (прогресс)
                AstroOrbitProgress(progress: progress)
                    .frame(width: geometry.size.height * 0.6, height: geometry.size.height * 0.6)
                // Маленькая летающая комета
                AstroComet(progress: progress)
                    .frame(width: geometry.size.height * 0.6, height: geometry.size.height * 0.6)
                // Звезды
                AstroStars()
            }
            .frame(width: geometry.size.height * 0.7, height: geometry.size.height * 0.7)

            VStack(alignment: .leading) {
                Text("Astro Launching...")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.yellow, .white], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                Text("\(progressPercentage)%")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(radius: 1)
            }
            .padding(.leading, 24)
            Spacer()
        }
    }
}

// MARK: - Фоновые представления

extension AstroLoadingOverlay where Background == AstroBackground {
    init(progress: Double) {
        self.init(progress: progress) { AstroBackground() }
    }
}

struct AstroBackground: View, AstroBackgroundProviding {
    func makeBackground() -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#0B0E2C"), Color(hex: "#1B1E3C"), Color(hex: "#23244D")]),
                startPoint: .top,
                endPoint: .bottom
            )
            AstroStars(count: 60, twinkle: true)
        }
        .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Космические элементы

struct AstroStars: View {
    var count: Int = 30
    var twinkle: Bool = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<count, id: \.self) { i in
                let x = CGFloat.random(in: 0...geo.size.width)
                let y = CGFloat.random(in: 0...geo.size.height)
                let size = CGFloat.random(in: 1.5...3.5)
                let opacity = Double.random(in: 0.5...1.0)
                Circle()
                    .fill(Color.white.opacity(opacity))
                    .frame(width: size, height: size)
                    .position(x: x, y: y)
                    .opacity(twinkle ? Double.random(in: 0.5...1.0) : 1)
                    .animation(
                        twinkle ? Animation.easeInOut(duration: Double.random(in: 1.0...2.5)).repeatForever().delay(Double(i) * 0.1) : .none,
                        value: UUID()
                    )
            }
        }
    }
}

struct AstroOrbitProgress: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.18), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color(hex: "#F3D614"), .white, Color(hex: "#F3D614")]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

struct AstroComet: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            let angle = Angle(degrees: 360 * progress - 90)
            let radius = geo.size.width * 0.3
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let cometX = center.x + cos(angle.radians) * radius
            let cometY = center.y + sin(angle.radians) * radius

            ZStack {
                // Хвост кометы
                Capsule()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.5)]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: 40, height: 6)
                    .rotationEffect(angle)
                    .position(x: cometX - 20 * cos(angle.radians), y: cometY - 20 * sin(angle.radians))
                // Голова кометы
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color(hex: "#F3D614")]), startPoint: .top, endPoint: .bottom))
                    .frame(width: 16, height: 16)
                    .shadow(color: Color.yellow.opacity(0.7), radius: 8)
                    .position(x: cometX, y: cometY)
            }
        }
    }
}

// MARK: - Индикатор прогресса (не используется, но оставлен для совместимости)

struct AstroProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
        }
    }

    private func backgroundTrack(height: CGFloat) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(height: height)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color(hex: "#F3D614"))
            .frame(width: CGFloat(value) * geometry.size.width, height: geometry.size.height)
            .animation(.linear(duration: 0.2), value: value)
    }
}

// MARK: - Превью

#Preview("Vertical") {
    AstroLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    AstroLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}

