import AVFoundation

class VolumeButtonObserver {
    private var initialVolume: Float = 0.5
    private var volumeUpCount = 0
    private var volumeDownCount = 0
    private var volumeObservation: NSKeyValueObservation?

    func startMonitoring() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(true)
        initialVolume = audioSession.outputVolume

        volumeObservation = audioSession.observe(\.outputVolume, options: [.new]) { [weak self] session, change in
            guard let newVolume = change.newValue else { return }
            guard let self = self else { return }

            if newVolume > self.initialVolume {
                self.volumeUpCount += 1
            } else if newVolume < self.initialVolume {
                self.volumeDownCount += 1
            }

            self.initialVolume = newVolume
        }
    }

    func stopMonitoring() {
        volumeObservation?.invalidate()
    }

    func getCounts() -> (up: Int, down: Int) {
        return (volumeUpCount, volumeDownCount)
    }
}
