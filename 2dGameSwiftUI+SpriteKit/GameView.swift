import SwiftUI
import SpriteKit

struct GameView: View {
    
    @State var gameScene = GameScene(size: screenSize)
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameScene)
                .ignoresSafeArea()
        }
        
    }
    
}

#Preview {
    GameView()
}
