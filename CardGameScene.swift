//
//  CardGameScene.swift
//  Abracard
//
//  Created by Michelangelo Bonura on 16/09/25.
//
import AVFoundation
import SpriteKit
import CoreMotion

class CardGameScene: SKScene {
    var screenSize: CGSize!
    var cardWidth: CGFloat!
    var cardHeight: CGFloat!
    var cardSpacingW: CGFloat!
    var cardSpacingH: CGFloat!
    var Cards : [SKSpriteNode] = []
    var cards: [String] = []
    let suits : [String] = ["cuori", "quadri", "fiori", "picche"]
    var initialTouchPoint: CGPoint?
    var directionSelected: Directions?
    var firstFlip: Bool = true
    var selectedSuitIndex: Int? = nil
    var cardValue: Int? = nil
    var cardSuit: String? = nil
    var cardName: String? = nil
    var cardFlipped: [Bool] = []
    var carouselOffset: CGFloat = 0.0
    var isCarouselActive: Bool = false
    // Indici delle carte già rivelate (aggiunte alla scena)
    var revealedIndices: Set<Int> = []
    var lastTouchTime: TimeInterval = 0
    var touchVelocity: CGPoint = CGPoint.zero
    var velocityHistory: [CGPoint] = []  // Storico per smoothing
    var lastTouchPosition: CGPoint = CGPoint.zero
    var isAnimating: Bool = false
    var decelerationRate: CGFloat = 0.94  // Fattore di attrito naturale
    var volumeObserver: VolumeButtonObserver?
    let motionManager = CMMotionManager()
    var isDeviceFlat: Bool = false
    var hasBeenTilted: Bool = false
    var motionMonitoringActive: Bool = false


    enum Directions {
        case left
        case right
        case up
        case down
    }
    
    override func didMove(to view: SKView) {
        // Imposta il centro dello schermo come origine (0,0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        screenSize = self.size
        //dimensioniamo le carte
        cardWidth = screenSize.width / 1.7
        cardHeight = screenSize.height / 2.2
        cardSpacingW = 2.5 * ((screenSize.width - cardWidth) / 2)  // Aumentato da 1.5 a 2.5 per più spazio orizzontale tra le carte
        cardSpacingH = 1.5 * ((screenSize.height - cardHeight) / 2)
        
        //set sfondo con immagine
        let background = SKSpriteNode(imageNamed: "close_up_purple")
        background.position = CGPoint(x: 0.5 , y : 0.5)
        background.zPosition = -100
        background.size = size
        addChild(background)
        
        
        //Popolo l'array cards
        for suit in suits {
            for value in ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"] {
                cards.append("\(suit)_\(value)")
            }
        }
        
        // Creo le carte
        let blackCard = SKSpriteNode(imageNamed: "black_back")
        let redCard = SKSpriteNode(imageNamed: "red_back")
        let orangeCard = SKSpriteNode(imageNamed: "orange_back")
        let purpleCard = SKSpriteNode(imageNamed: "purple_back")
        let greenCard = SKSpriteNode(imageNamed: "green_back")
        
        //carte visualizzate a schermo
        Cards = [ redCard, orangeCard, purpleCard, blackCard, greenCard]

        // Dimensioni carte
        for card in Cards {
            card.size = CGSize(width: cardWidth, height: cardHeight)
            card.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }

        // Inizializza tutte le carte nella posizione centrale, inizialmente si vedrà solo la prima
        for card in Cards {
            card.position = CGPoint(x: 0.5, y: 0.5)
            card.alpha = 0.0  // Inizialmente invisibili tranne quella centrale
            card.setScale(1.0)
            card.zPosition = 50  // Dietro la carta centrale
        }
        
        // Mostra solo la prima carta centrale inizialmente
        let startCard = Cards[0]
        startCard.alpha = 1.0
        startCard.zPosition = 100  // In primo piano
        addChild(startCard)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapRecognizer)
        
        //Impedisci che il telefono vada in standby
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Avvia il monitoraggio dei pulsanti volume
        try? AVAudioSession.sharedInstance().setActive(true)
        volumeObserver = VolumeButtonObserver()
        volumeObserver?.startMonitoring()
        
        // Avvia monitoraggio movimento (accellerometro)
        startMotionMonitoring()
    }
    
    func startMotionMonitoring() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 0.2
        var stableStartTime: TimeInterval? = nil

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            let gravity = motion.gravity
            let acc = motion.userAcceleration

            let x = gravity.x
            let y = gravity.y
            let z = gravity.z

            let linearMovement = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)
            let pitch = motion.attitude.pitch * 180 / .pi  // In gradi
            let currentTime = CACurrentMediaTime()

            // Fase 1: rileva se il telefono è piatto e stabile
            if !self.motionMonitoringActive {
                if abs(x) < 0.05 && abs(y) < 0.05 && abs(z) > 0.98 && linearMovement < 0.02 {
                    if stableStartTime == nil {
                        stableStartTime = currentTime
                    } else if currentTime - stableStartTime! > 2.0 {
                        self.isDeviceFlat = true
                        self.motionMonitoringActive = true
                    }
                } else {
                    stableStartTime = nil
                }
            }

            // Fase 2: rileva inclinazione solo dopo stabilità
            if self.motionMonitoringActive && self.isDeviceFlat && !self.hasBeenTilted {
                let pitchThreshold: Double = 10.0

                if abs(pitch) > pitchThreshold {//|| abs(roll) > rollThreshold {
                    self.hasBeenTilted = true
                    self.motionManager.stopDeviceMotionUpdates()
                }
            }

        }
    }


    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            initialTouchPoint = touch.location(in: self)
            lastTouchPosition = touch.location(in: self)
            lastTouchTime = CACurrentMediaTime()
            touchVelocity = CGPoint.zero
            velocityHistory.removeAll()
            
            // Ferma animazioni in corso per responsiveness immediata
            if isAnimating {
                removeAllActions()
                isAnimating = false
            }
            
            // Interrompi il conteggio volume
            volumeObserver?.stopMonitoring()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let start = initialTouchPoint else { return }
        let current = touch.location(in: self)
        let currentTime = CACurrentMediaTime()
        
        // Calcolo movimento incrementale per fluidità
        let incrementalDelta = CGPoint(
            x: current.x - lastTouchPosition.x,
            y: current.y - lastTouchPosition.y
        )
        
        let totalDelta = CGPoint(x: current.x - start.x, y: current.y - start.y)
        
        // Determina direzione e attiva carosello con pre-attivazione
        if directionSelected == nil {
            // Pre-attivazione del carosello anche con soglia più bassa
            let preActivationThreshold: CGFloat = 10.0
            
            if abs(totalDelta.x) > preActivationThreshold && abs(totalDelta.x) > abs(totalDelta.y) {
                directionSelected = current.x > start.x ? .right : .left
                activateCarousel(isHorizontal: true)
                
                // Applica immediatamente il movimento accumulato
                let accumulatedMovement = totalDelta.x
                carouselOffset = accumulatedMovement * 1.2 // Boost iniziale
                updateCarouselPositions(cards: Cards, isHorizontal: true)
                
            } else if abs(totalDelta.y) > preActivationThreshold && abs(totalDelta.y) > abs(totalDelta.x) {
                directionSelected = current.y > start.y ? .up : .down
                activateCarousel(isHorizontal: false)
                
                // Applica immediatamente il movimento accumulato
                let accumulatedMovement = totalDelta.y
                carouselOffset = accumulatedMovement * 1.2 // Boost iniziale
                updateCarouselPositions(cards: Cards,isHorizontal: false)
            }
            
            // Anche se non abbiamo ancora determinato la direzione,
            // forniamo feedback visivo immediato per piccoli movimenti
            if abs(totalDelta.x) > 2.0 || abs(totalDelta.y) > 2.0 {
                // Feedback visivo leggero durante la fase di riconoscimento
                provideImmediateFeedback(delta: totalDelta)
            }
            
        } else {
            // Sensibilità adattiva migliorata
            let deltaTime = currentTime - lastTouchTime
            let instantVelocity = CGPoint(
                x: incrementalDelta.x / CGFloat(deltaTime),
                y: incrementalDelta.y / CGFloat(deltaTime)
            )
            
            let baseSensitivity: CGFloat = 1.8 // Aumentata da 1.5
            let velocityMagnitude = abs(instantVelocity.x) + abs(instantVelocity.y)
            let velocityBoost = min(velocityMagnitude * 0.001, 1.0) // Migliorato il boost
            let adaptiveSensitivity = baseSensitivity + velocityBoost
            
            if directionSelected == .right || directionSelected == .left {
                carouselOffset += incrementalDelta.x * adaptiveSensitivity
                updateCarouselPositions(cards: Cards, isHorizontal: true)
            } else {
                carouselOffset += incrementalDelta.y * adaptiveSensitivity
                updateCarouselPositions(cards: Cards, isHorizontal: false)
            }
        }
        
        // Aggiorna riferimenti per prossimo frame (NON modificare initialTouchPoint)
        lastTouchPosition = current
        lastTouchTime = currentTime
    }

    // Nuovo metodo per feedback immediato in SpriteKit
    private func provideImmediateFeedback(delta: CGPoint) {
        // Feedback visivo leggero durante il riconoscimento della direzione
        let feedbackIntensity: CGFloat = 0.3
        let horizontalBias = abs(delta.x) > abs(delta.y)
        
        if horizontalBias {
            // Leggero movimento orizzontale delle carte usando position
            Cards.forEach { card in
                let originalX = card.userData?["originalX"] as? CGFloat ?? card.position.x
                card.position.x = originalX + (delta.x * feedbackIntensity)
            }
        } else {
            // Leggero movimento verticale delle carte usando position
            Cards.forEach { card in
                let originalY = card.userData?["originalY"] as? CGFloat ?? card.position.y
                card.position.y = originalY + (delta.y * feedbackIntensity)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard directionSelected != nil && isCarouselActive && !isAnimating else { return }
        
        let velocityThreshold: CGFloat = 120.0  // Soglia più bassa per maggiore responsivenes
        let currentVelocity = (directionSelected == .right || directionSelected == .left) ? touchVelocity.x : touchVelocity.y
        
        if abs(currentVelocity) > velocityThreshold {
            
        } else {
            snapToNearestCardSmooth()
        }
        
        velocityHistory.removeAll()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func snapToNearestCardSmooth() {
        guard isCarouselActive else {
            isAnimating = false
            return
        }
        
        let cards = Cards
        let cardSpacing = (directionSelected == .right || directionSelected == .left) ?
                         (cardWidth + cardSpacingW) : (cardHeight + cardSpacingH)
        
        // Calcola la posizione di snap più vicina con maggiore precisione
        let numberOfCards = CGFloat(cards.count)
        let angleStep = (2.0 * CGFloat.pi) / numberOfCards
        let currentAngle = carouselOffset / cardSpacing
        let nearestCardAngle = round(currentAngle / angleStep) * angleStep
        let targetOffset = nearestCardAngle * cardSpacing
        
        let offsetDifference = targetOffset - carouselOffset
        let snapDistance = abs(offsetDifference)
        
        // Durata adattiva basata sulla distanza
        let baseDuration = 0.2
        let maxDuration = 0.5
        let snapDuration = min(baseDuration + (snapDistance * 0.0008), maxDuration)
        
        // Smooth ease-in-out animation per movimento al centro (nessun bounce)
        let startOffset = carouselOffset
        let endOffset = targetOffset

        let smoothAction = SKAction.customAction(withDuration: snapDuration) { [weak self] _, elapsedTime in
            guard let self = self else { return }

            let t = CGFloat(min(max(elapsedTime / snapDuration, 0.0), 1.0))

            // Cubic ease-in-out
            let eased: CGFloat
            if t < 0.5 {
                eased = 4.0 * t * t * t
            } else {
                let f = (2.0 * t) - 2.0
                eased = 0.5 * f * f * f + 1.0
            }

            self.carouselOffset = startOffset + (endOffset - startOffset) * eased

            if self.directionSelected == .right || self.directionSelected == .left {
                self.updateCarouselPositions(cards: self.Cards, isHorizontal: true)
            } else {
                self.updateCarouselPositions(cards: self.Cards, isHorizontal: false)
            }
        }

        run(smoothAction) {
            // Assicura posizione finale precisa
            self.carouselOffset = targetOffset
            if self.directionSelected == .right || self.directionSelected == .left {
                self.updateCarouselPositions(cards: self.Cards, isHorizontal: true)
            } else {
                self.updateCarouselPositions(cards: self.Cards, isHorizontal: false)
            }
            self.isAnimating = false
        }
    }
    
    func updateCarouselPositions(cards: [SKSpriteNode], isHorizontal: Bool) {
        let cardSpacing = isHorizontal ? (cardWidth + cardSpacingW) : (cardHeight + cardSpacingH)
        let numberOfCards = CGFloat(cards.count)
        
        // Calcola quanto l'utente ha scrollato (normalizzato)
        for (index, card) in cards.enumerated() {
            // Calcola posizione più precisa nel carosello
            let cardIndex = CGFloat(index)
            let angleStep = (2.0 * CGFloat.pi) / numberOfCards
            let currentAngle = (cardIndex * angleStep) + (carouselOffset / cardSpacing)
            
            // Reveal-on-rotation: riveliamo le carte quando il loro angolo si avvicina al fronte
            // Calcola la distanza angolare dal fronte (0 = front)
            let normalized = currentAngle.truncatingRemainder(dividingBy: 2.0 * CGFloat.pi)
            let angDist = min(abs(normalized), 2.0 * CGFloat.pi - abs(normalized))

            // Threshold angolare per rivelare la carta
            let revealAngleThreshold: CGFloat = 0.5

            if angDist <= revealAngleThreshold {
                if !revealedIndices.contains(index) {
                    // Aggiungi e anima comparsa
                    if card.parent == nil {
                        card.alpha = 0.0
                        card.setScale(0.8)
                        addChild(card)
                    }
                    revealedIndices.insert(index)
                    let fade = SKAction.fadeAlpha(to: 1.0, duration: 0.22)
                    fade.timingMode = .easeOut
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.22)
                    scaleUp.timingMode = .easeOut
                    card.run(SKAction.group([fade, scaleUp]))
                }
            }
            
            // Raggio adattivo basato sul numero di carte per aumentare la distanza
            // Più carte ci sono, più grande deve essere il carosello per distanziarle
            let cardCountFactor = CGFloat(cards.count) / 4.0  // Normalizzato su 4 carte base
            let baseRadius = isHorizontal ? cardSpacing * 2.2 : cardSpacing * 1.6  // Aumentato da 1.6 a 2.2 per maggiore distanza orizzontale
            let scaledRadius = baseRadius * (1.0 + cardCountFactor * 0.5)  // Aumenta il 50% per ogni gruppo di 4 carte extra
            let maxScreenRadius = min(screenSize.width, screenSize.height) * 0.6  // Limite schermo più generoso
            let adaptiveRadius = min(scaledRadius, maxScreenRadius)
            
            // Calcola posizioni circolari
            let sinValue = sin(currentAngle)
            let cosValue = cos(currentAngle)
            
            
            if isHorizontal {
                // Posizione X principale dal centro
                card.position.x = sinValue * adaptiveRadius
                
                // Leggero effetto Y per simulare profondità circolare
                let depthY = cosValue * adaptiveRadius * 0.08
                card.position.y = depthY
            } else {
                // Posizione Y principale dal centro
                card.position.y = sinValue * adaptiveRadius
                
                // Leggero effetto X per simulare profondità circolare  
                let depthX = cosValue * adaptiveRadius * 0.08
                card.position.x = depthX
            }
            
            // Applica tutti gli effetti visivi avanzati
            applyCarouselEffects(card: card, angle: currentAngle, isHorizontal: isHorizontal)
        }
    }
    
    func applyCarouselEffects(card: SKSpriteNode, angle: CGFloat, isHorizontal: Bool) {
        // Normalizza l'angolo per calcoli più precisi
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 2 * CGFloat.pi)
        let absAngle = abs(normalizedAngle)
        
        // Distanza dal centro con curva più naturale
        let rawDistance = min(absAngle, 2 * CGFloat.pi - absAngle) / CGFloat.pi
        let smoothDistance = pow(rawDistance, 0.6)  // Curva più graduale per transizioni smooth
        
        // Effetti di scala più naturali
        let minScale: CGFloat = 0.65
        let scaleRange = 1.0 - minScale
        let targetScale = max(1.0 - (smoothDistance * scaleRange), minScale)
        
        // Effetti di trasparenza migliorati per apparizione più naturale
        let visibilityThreshold: CGFloat = 0.7  // Soglia oltre la quale inizia il fade
        
        var targetAlpha: CGFloat = 1.0
        
        if smoothDistance > visibilityThreshold {
            // Calcola fade-out graduale oltre la soglia
            let fadeDistance = smoothDistance - visibilityThreshold
            let maxFadeDistance: CGFloat = 0.3  // Distanza massima per fade completo
            let fadeProgress = min(fadeDistance / maxFadeDistance, 1.0)
            
            // Usa smoothstep per transizione più naturale
            let smoothFade = fadeProgress * fadeProgress * (3.0 - 2.0 * fadeProgress)
            targetAlpha = 1.0 - smoothFade
        }
        
        // Z-position con profondità migliorata
        let maxDepthReduction: CGFloat = 75
        let targetZPos = 100 - (smoothDistance * maxDepthReduction)
        
        // Rotazione rimossa - le carte rimangono sempre dritte
        let targetRotation: CGFloat = 0.0  // Nessuna rotazione
        
        // Effetto prospettiva per maggiore realismo 3D
        let perspectiveOffset = smoothDistance * 25
        let yOffset = isHorizontal ? perspectiveOffset * (normalizedAngle > 0 ? -1 : 1) : 0
        let xOffset = !isHorizontal ? perspectiveOffset * (normalizedAngle > 0 ? -1 : 1) : 0
        
        // Interpolazione smooth per evitare scatti durante animazioni
        if !isAnimating {
            let interpolationFactor: CGFloat = 0.25
            
            let currentScale = card.xScale
            let currentAlpha = card.alpha
            
            let smoothScale = currentScale + (targetScale - currentScale) * interpolationFactor
            let smoothAlpha = currentAlpha + (targetAlpha - currentAlpha) * interpolationFactor
            
            card.setScale(smoothScale)
            card.alpha = smoothAlpha
        } else {
            card.setScale(targetScale)
            card.alpha = targetAlpha
        }
        
        card.zPosition = targetZPos
        card.zRotation = targetRotation
        
        // Applica offset prospettico per depth enhancement
        if isHorizontal {
            card.position.y = yOffset
        } else {
            card.position.x = xOffset
        }
    }
    
    func activateCarousel(isHorizontal: Bool) {
        guard !isCarouselActive else { return }
        isCarouselActive = true
        
        let cards = Cards
        
        
        
        // Mostra SOLO la carta centrale inizialmente - le altre appariranno durante lo scorrimento
        for (index, card) in cards.enumerated() {
            if index == 0 {
                // Aggiungi solo la carta centrale
                if card.parent == nil {
                    addChild(card)
                }
                card.alpha = 1.0
                card.setScale(1.0)
            } else {
                // Tutte le altre carte rimangono nascoste per ora
                if card.parent != nil {
                    card.removeFromParent()
                }
            }
        }
        
        // Inizializza stati se necessario
        if cardFlipped.isEmpty {
            cardFlipped = Array(repeating: false, count: cards.count)
        }
        
        // Aggiorna posizioni con transizione smooth
        updateCarouselPositions(cards: cards, isHorizontal: isHorizontal)
    }

    func getCardImageName() -> String {
        var cardIndex: Int
        if firstFlip {
            cardIndex = (selectedSuitIndex! * 13 + cardValue! - 1)
        }
        else {
            cardIndex = Int.random(in: 0..<cards.count)
        }
        let cardName = cards[cardIndex]
        cards.remove(at: cardIndex)
        return cardName
    }

    
    func calculateCardValue() -> Int {
        var cardValue: Int
        let volumeUpCounter = volumeObserver!.getCounts().up
        let volumeDownCounter = volumeObserver!.getCounts().down
        
        if volumeUpCounter > 0 {
            switch volumeObserver?.getCounts().up {
                case 1:
                    cardValue = 4
                case 2:
                    cardValue = 5
                case 3:
                    cardValue = 6
                default:
                    cardValue = 6
            }
        } else if volumeDownCounter > 0 {
            switch volumeObserver?.getCounts().down {
                case 1:
                    cardValue = 1
                case 2:
                    cardValue = 2
                case 3:
                    cardValue = 13
                default:
                    cardValue = 13
            }
        } else {
            cardValue = 3
        }
        if hasBeenTilted {
            cardValue += 6
        }
        return cardValue
    }

    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if directionSelected != nil {
            let locationInView = sender.location(in: self.view)
            let locationInScene = convertPoint(fromView: locationInView)
            var cardIndex: Int? = nil
            let card: SKSpriteNode!

            // Trova il nodo toccato
            let tappedNode = atPoint(locationInScene)

            
            if let index = Cards.firstIndex(of: tappedNode as! SKSpriteNode) {
                cardIndex = index
            }
             
            
            if cardIndex != nil {
                if !cardFlipped[cardIndex!] {
                    cardFlipped[cardIndex!] = true
                    cardSuit = nil
                    cardValue = nil
                    if firstFlip {
                        switch directionSelected {
                            case .right:
                                selectedSuitIndex = 0
                            case .down:
                                selectedSuitIndex = 1
                            case .left:
                                selectedSuitIndex = 2
                            case .up:
                                selectedSuitIndex = 3
                            case nil:
                                selectedSuitIndex = nil
                        }

                        //Selezione valore carta
                        cardValue = calculateCardValue()
                        cardName = getCardImageName()
                        cards.shuffle()
                        firstFlip = false
                    } else {
                        cardName = getCardImageName()
                    }
                    
                    
                    
                    if selectedSuitIndex != nil {
                        card = Cards[cardIndex!]
                        // Animazione migliorata per evitare stretching
                        let flipHalfDuration = 0.25 // Durata leggermente aumentata per smoothness
                        
                        // Prima metà: riduci scala X a 0 e Y leggermente per effetto 3D realistico
                        let shrinkX = SKAction.scaleX(to: 0.0, duration: flipHalfDuration)
                        let shrinkY = SKAction.scaleY(to: 0.95, duration: flipHalfDuration) // Leggera compressione Y
                        shrinkX.timingMode = .easeIn
                        shrinkY.timingMode = .easeIn
                        
                        // Leggero movimento Y per effetto 3D più realistico
                        let liftUp = SKAction.moveBy(x: 0, y: 5, duration: flipHalfDuration)
                        liftUp.timingMode = .easeOut
                        
                        // Cambio texture al momento giusto (quando la carta è "di lato")
                        let changeTexture = SKAction.run {
                            card.texture = SKTexture(imageNamed: self.cardName!)
                        }
                        
                        // Seconda metà: espandi scala X a 1 e ripristina Y
                        let expandX = SKAction.scaleX(to: 1.0, duration: flipHalfDuration)
                        let expandY = SKAction.scaleY(to: 1.0, duration: flipHalfDuration)
                        expandX.timingMode = .easeOut
                        expandY.timingMode = .easeOut
                        
                        // Ritorna alla posizione originale
                        let settleDown = SKAction.moveBy(x: 0, y: -5, duration: flipHalfDuration)
                        settleDown.timingMode = .easeIn
                        
                        // Leggero bounce finale per maggiore naturalezza (su entrambe le scale)
                        let finalBounceX = SKAction.scaleX(to: 1.02, duration: 0.08)
                        let finalBounceY = SKAction.scaleY(to: 1.02, duration: 0.08)
                        let finalSettleX = SKAction.scaleX(to: 1.0, duration: 0.12)
                        let finalSettleY = SKAction.scaleY(to: 1.0, duration: 0.12)
                        
                        let bounceGroup = SKAction.group([finalBounceX, finalBounceY])
                        let settleGroup = SKAction.group([finalSettleX, finalSettleY])
                        let finalBounce = SKAction.sequence([bounceGroup, settleGroup])
                        finalBounce.timingMode = .easeOut
                        
                        // Sequenza completa migliorata con coordinazione X e Y
                        let flipSequence = SKAction.sequence([
                            SKAction.group([shrinkX, shrinkY, liftUp]),
                            changeTexture,
                            SKAction.group([expandX, expandY, settleDown]),
                            finalBounce
                        ])
                        
                        card.run(flipSequence)
                    }
                }
            }
        }
    }
}
