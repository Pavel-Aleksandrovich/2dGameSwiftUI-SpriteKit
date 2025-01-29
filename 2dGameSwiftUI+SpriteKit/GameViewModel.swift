import Foundation

final class GameViewModel: ObservableObject {
    
    @Published var gameScene = GameScene(size: screenSize)
    @Published var isStartGame = false
    
    func jumpDidTap() {
        gameScene.jumpDidTap()
    }
    
    func downDidTap() {
        gameScene.downDidTap()
    }
    
    func startGame() {
        isStartGame = true
        gameScene.startGame()
    }
    
    func setupGameHandlers() {
        gameScene.loseHandler = { [weak self] in
            print("lose")
            guard let self else {return}
            self.gameScene = GameScene(size: screenSize)
            self.isStartGame = false
            self.setupGameHandlers()
        }
    }
    
}
