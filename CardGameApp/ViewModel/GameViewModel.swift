//
//  GameViewModel.swift
//  CardGameApp
//
//  Created by Tolga Ulutaş on 3.01.2026.
//

import Foundation
import Combine
import SwiftUI

final class GameViewModel: ObservableObject {
    @Published var currentLevel: Int = 1
    @Published var tiles: [Tile] = []
    @Published var currentTargetIndex: Int = 0
    @Published var showWin: Bool = false
    @Published var shakeWrong: Bool = false
    @Published var hedefBuyukMu: Bool = false
    
    let levels: [Int: LevelData] = [
        1: LevelData(
            targetImages: ["dt1","dt2","dt3","dt4","dt5","dt6","dt7","dt8","dt9"],
            allImages: ["dt1","dt2","dt3","dt4","dt5","dt6","dt7","dt8","dt9"],
            colum: 3, row: 3
        ),
        2: LevelData(
            targetImages: ["s1","s2","s3","s4","s5","s6","s7","s8","s9"],
            allImages: ["s1","s2","s3","s4","s5","s6","s7","s8","s9"],
            colum: 3, row: 3
        ),
        3: LevelData(
            targetImages: ["got1","got2","got3","got4","got5","got6","got7","got8","got9"],
            allImages: ["got1","got2","got3","got4","got5","got6","got7","got8","got9"],
            colum: 3, row: 3
        ),
        4: LevelData(
            targetImages: ["pocemon1","pocemon2","pocemon3","pocemon4","pocemon5","pocemon6","pocemon7","pocemon8","pocemon9","pocemon10","pocemon11","pocemon12"],
            allImages: ["pocemon1","pocemon2","pocemon3","pocemon4","pocemon5","pocemon6","pocemon7","pocemon8","pocemon9","pocemon10","pocemon11","pocemon12"],
            colum: 4, row: 3
        ),
        5: LevelData(
            targetImages: ["st1","st2","st3","st4","st5","st6","st7","st8","st9","st10","st11","st12"],
            allImages: ["st1","st2","st3","st4","st5","st6","st7","st8","st9","st10","st11","st12"],
            colum: 4, row: 3
        ),
        6: LevelData(
            targetImages: ["harry1","harry2","harry3","harry4","harry5","harry6","harry7","harry8","harry9","harry10","harry11","harry12"],
            allImages: ["harry1","harry2","harry3","harry4","harry5","harry6","harry7","harry8","harry9","harry10","harry11","harry12"],
            colum: 4, row: 3
        ),
        7: LevelData(
            targetImages: ["image1","image2","image3","image4","image5","image6","image7","image8","image9","image10","image11","image12"],
            allImages: ["image1","image2","image3","image4","image5","image6","image7","image8","image9","image10","image11","image12"],
            colum: 4, row: 3
        )
    ]
    var levelData: LevelData {
        levels[currentLevel] ?? levels[1]!
    }
    
    var safeTargetImageName: String? {
        guard currentTargetIndex >= 0 && currentTargetIndex < levelData.targetImages.count else { return nil }
        return levelData.targetImages[currentTargetIndex]
    }
    
    var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 2),
            count: levelData.row
        )
    }
    
    func resetGame(animated: Bool) {
        let newTiles = generateTiles()
        hedefBuyukMu = false
        if animated {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                tiles = newTiles
                currentTargetIndex = 0
                showWin = false
            }
        } else {
            tiles = newTiles
            currentTargetIndex = 0
            showWin = false
        }
    }
    func generateTiles() -> [Tile] {
        var chosen: [String] = levelData.targetImages
        let pool = levelData.allImages.shuffled()
        var idx = 0
        
        let toplamKare = levelData.colum * levelData.row
        
        while chosen.count < toplamKare {
            let symbol = pool[idx % pool.count]
            chosen.append(symbol)
            idx += 1
        }
        
        return chosen.shuffled().map {
            Tile(imageName: $0, isFlipped: false)
        }
    }
    func handleTap(on tile: Tile) {
        guard !showWin else { return }
        guard let index = tiles.firstIndex(of: tile) else { return }
        if tiles[index].isFlipped { return }
        
        guard currentTargetIndex >= 0 &&
                currentTargetIndex < levelData.targetImages.count else { return }
        
        let expected = levelData.targetImages[currentTargetIndex]
        
        if tiles[index].imageName == expected {
            withAnimation(.easeInOut(duration: 0.4)) {
                tiles[index].isFlipped = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                    self.currentTargetIndex += 1
                }
                
                if self.currentTargetIndex >= self.levelData.targetImages.count {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        self.showWin = true
                    }
                }
            }
        } else {
            triggerErrorReset()
        }
    }
    
    func triggerHapticError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func triggerErrorReset() {
        triggerHapticError()
        
        withAnimation(.default) {
            shakeWrong = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.shakeWrong = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.4)) {
                for i in self.tiles.indices {
                    self.tiles[i].isFlipped = false
                }
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.currentTargetIndex = 0
                self.showWin = false
            }
        }
    }
    
}



