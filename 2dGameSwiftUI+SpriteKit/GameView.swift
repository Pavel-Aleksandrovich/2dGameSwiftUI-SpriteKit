import SwiftUI
import SpriteKit

struct GameView: View {
    
    @StateObject var viewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.gameScene)
                .ignoresSafeArea()
                .blur(radius: viewModel.isStartGame ? 0 : 2)
                .allowsHitTesting(viewModel.isStartGame)
                .contrast(viewModel.isStartGame ? 1 : 0.5)
            
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text("Down")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .onTapGesture {
                        viewModel.downDidTap()
                    }
                
                Spacer()
                
                Circle()
                    .fill(.green)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text("Jump")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .onTapGesture {
                        viewModel.jumpDidTap()
                    }
            }
            .frame(maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
            .blur(radius: viewModel.isStartGame ? 0 : 2)
            .allowsHitTesting(viewModel.isStartGame)
            .contrast(viewModel.isStartGame ? 1 : 0.5)
            
            if !viewModel.isStartGame {
                Circle()
                    .fill(.green)
                    .frame(width: 120, height: 120)
                    .overlay {
                        Text("Start")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .onTapGesture {
                        viewModel.startGame()
                    }
            }
            
        }
        .onAppear() {
            viewModel.setupGameHandlers()
        }
        
    }
    
}

#Preview {
    GameView()
}
