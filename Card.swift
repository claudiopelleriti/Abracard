import SpriteKit

class Card: SKNode {
    let backNode: SKSpriteNode
    let faceNode: SKSpriteNode

    var isFaceUp = false

    init(backNode: SKSpriteNode, faceNode: SKSpriteNode, size: CGSize) {
        self.backNode = backNode
        self.faceNode = faceNode

        super.init()

        backNode.size = size
        faceNode.size = size

        backNode.zPosition = 1
        faceNode.zPosition = 0
        faceNode.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func flip(duration: TimeInterval = 0.4) {
        let shrink = SKAction.scaleX(to: 0.0, duration: duration / 2)
        let expand = SKAction.scaleX(to: 1.0, duration: duration / 2)

        let flipSequence = SKAction.sequence([
            shrink,
            SKAction.run {
                self.isFaceUp.toggle()
                self.backNode.isHidden = self.isFaceUp
                self.faceNode.isHidden = !self.isFaceUp
            },
            expand
        ])

        self.run(flipSequence)
    }
}
