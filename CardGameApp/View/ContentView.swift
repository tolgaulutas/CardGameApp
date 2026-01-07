
import SwiftUI
import Combine
import GoogleMobileAds

struct ContentView: View {
    @StateObject var vm = GameViewModel()
    var body: some View {
        ZStack {
            AuraBackgroundView()
                .ignoresSafeArea()
            VStack(spacing: 14) {
                header
                
                Text("Seviye \(vm.currentLevel)")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 1)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                
                LazyVGrid(columns: vm.columns, spacing: 8) {
                    ForEach(vm.tiles) { tile in
                        TileView(tile: tile)
                            .onTapGesture { vm.handleTap(on: tile) }
                            .modifier(Shake(animates: vm.shakeWrong))
                    }
                }
               // BannerAdView()
                    //.frame(width: 320, height: 40)
                    //.animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.tiles)
            }
            .padding()
            .padding(.top,24)
            
            if vm.showWin {
                winOverlay
            }
        }
        .frame(maxWidth:.infinity, maxHeight:.infinity)
        .background(
            Color.black
                .opacity(vm.hedefBuyukMu ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        vm.hedefBuyukMu = false
                    }
                }
            
                .ignoresSafeArea()
        )
        
        .onAppear { vm.resetGame(animated: false) }
    }
    
    private var header: some View {
        VStack(spacing: 4) {
            Text("CardGame")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.titleText)
            
            if !vm.showWin {
                if let imageName = vm.safeTargetImageName {
                    VStack {
                        HStack(spacing: 8) {
                            Text("Lütfen bu resmi bul!")
                                .font(.headline)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    Text("Sıradaki: \(vm.currentTargetIndex + 1)/\(vm.levelData.targetImages.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Image(imageName)
                        .resizable()
                        .frame(
                            width: vm.hedefBuyukMu ? 210 : 190,
                            height: vm.hedefBuyukMu ? 210 : 190
                        )
                        .scaledToFit()
                        .cornerRadius(10)
                        .shadow(radius: vm.hedefBuyukMu ? 20 : 5)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                vm.hedefBuyukMu.toggle()
                            }
                        }
                } else {
                    Text("")
                        .font(.headline)
                }
            }
            
            
        }
        
    }
    
    private var winOverlay: some View {
        VStack(spacing: 16) {
            let isLastLevel = vm.currentLevel >= vm.levels.count
            
            Text(isLastLevel ? "OYUN BİTTİ!" : "Tebrikler!")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)
            
            Text(isLastLevel ? "Tüm seviyeleri tamamladın!" : "Seviye \(vm.currentLevel) tamamlandı.")
                .font(.headline)
            
            Button(action: {
                if isLastLevel {
                    vm.currentLevel = 1
                    vm.resetGame(animated: true)
                    
                    
                } else {
                    vm.currentLevel += 1
                    vm.resetGame(animated: true)
                }
            }) {
                Text(isLastLevel ? "Baştan Oyna" : "Sonraki Seviye")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.accentColor))
                    .foregroundStyle(.white)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .opacity(0.9)
        .transition(.scale.combined(with: .opacity))
    }
    
}

struct TileView: View {
    
    let tile: Tile
    
    var body: some View {
        FlipCard(isFlipped: tile.isFlipped) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [.blue.opacity(0.2), .gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    Image(systemName: "questionmark")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                )
        } back: {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    Image(tile.imageName)
                        .resizable()
                        .frame(width: 110, height: 110)
                        .scaledToFit()
                        .cornerRadius(8)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(width: 110, height: 110)
        
    }
}



struct FlipCard<Front: View, Back: View>: View {
    var isFlipped: Bool
    var front: () -> Front
    var back: () -> Back
    
    init(isFlipped: Bool, @ViewBuilder front: @escaping () -> Front, @ViewBuilder back: @escaping () -> Back) {
        self.isFlipped = isFlipped
        self.front = front
        self.back = back
    }
    
    var body: some View {
        ZStack {
            front()
                .opacity(isFlipped ? 0.0 : 1.0)
            
            back()
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1.0 : 0.0)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.35), value: isFlipped)
    }
    
}

struct Shake: ViewModifier {
    var animates: Bool
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: animates) { _, newValue in
                guard newValue else { return }
                performShake()
            }
    }
    
    private func performShake() {
        let base: CGFloat = 10
        let timings: [CGFloat] = [0, -1, 1, -1, 1, 0]
        for (i, t) in timings.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02 * Double(i)) {
                withAnimation(.easeInOut(duration: 0.02)) { offset = t * base }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02 * Double(timings.count)) {
            offset = 0
        }
    }
}

#Preview {
    ContentView()
}
