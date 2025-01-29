import Foundation

final class GameViewModel: ObservableObject {
    
    @Published var gameScene = GameScene(size: screenSize)
    
    func jumpDidTap() {
        gameScene.jumpDidTap()
    }
    
    func downDidTap() {
        gameScene.downDidTap()
    }
}
