# Abracard

## Project Description
Abracard is an iOS application designed for live magic performances, developed as a team project. The app allows a magician to predict and reveal the exact card a spectator is thinking of by interacting with the smartphone in a completely invisible manner.

The technical core of the application is based on the implementation of advanced and unconventional user interactions: asynchronous management of triggers linked to the physical volume buttons for value input and the processing of accelerometer data to detect device tilt.

## Presentation
You can download and view the detailed presentation of the project and the app's mechanics at the following link: [https://afp.unipa.it/PAL126/](https://afp.unipa.it/PAL126/)

## Main Features
* **Secret Input via Volume Buttons**: The magician can set the value of the card to be revealed by discreetly pressing the device's volume buttons. The system volume HUD is specifically hidden to avoid suspicion.
* **Tilt Detection (CoreMotion)**: Leveraging the device's gyroscope and accelerometer, the app reads the pitch to detect slight tilts of the phone. This is used to modify the selected card values (e.g., for cards with a value higher than 6) without any on-screen touch.
* **Interactive 2D/3D Carousel**: The game scene features a fluid card carousel managed via SpriteKit, using directional swipe logic to determine the suit of the chosen card.
* **Animations and Reveal**: The card reveal is triggered by a double tap, initiating an animated flip sequence managed through SpriteKit interpolations.
* **Integrated Tutorial**: A sliding interface built in SwiftUI guides the user through the decoding tables for volume clicks and movements to perform the trick perfectly.

## Technologies and Frameworks
* **SwiftUI**: Used for user interface management, menus, and tutorials.
* **SpriteKit**: Used for rendering the card engine, the carousel, and animation physics.
* **CoreMotion**: Used for real-time device movement tracking and tilt calculation.
* **AVFoundation / MediaPlayer**: Used for asynchronous monitoring of physical volume buttons via Key-Value Observing (KVO) and for overriding the standard system UI.

## Repository Note
Due to GitHub's upload size limits, the `Assets.xcassets` folder has been split into two compressed files: **assets1.zip** and **assets2.zip**. Please extract both and merge them into the original folder structure before building the project.
