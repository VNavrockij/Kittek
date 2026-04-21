import AVFoundation

@MainActor
final class RoundMusicPlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private var melodyBuffer: AVAudioPCMBuffer?
    private var isConfigured = false

    func start() {
        configureIfNeeded()

        guard !player.isPlaying else { return }

        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif

            if !engine.isRunning {
                engine.prepare()
                try engine.start()
            }

            guard let melodyBuffer else { return }
            player.scheduleBuffer(melodyBuffer, at: nil, options: .loops)
            player.play()
        } catch {
            player.stop()
        }
    }

    func stop() {
        guard player.isPlaying || engine.isRunning else { return }
        player.stop()
        engine.pause()
    }

    private func configureIfNeeded() {
        guard !isConfigured else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        melodyBuffer = makeMelodyBuffer(format: format)

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 1
        player.volume = 0.45
        isConfigured = true
    }

    private func makeMelodyBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let notes: [(frequency: Float, beats: Float)] = [
            (523.25, 1.0),
            (659.25, 1.0),
            (783.99, 1.0),
            (880.00, 1.0),
            (783.99, 1.0),
            (659.25, 1.0),
            (587.33, 1.0),
            (523.25, 1.0)
        ]
        let beatDuration: Float = 0.42
        let frameCount = AVAudioFrameCount(notes.reduce(Float(0)) { total, note in
            total + note.beats * beatDuration * Float(sampleRate)
        })
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        guard let channel = buffer.floatChannelData?[0] else { return buffer }

        var frameOffset = 0
        for note in notes {
            let noteFrames = Int(note.beats * beatDuration * Float(sampleRate))
            for frame in 0..<noteFrames where frameOffset + frame < Int(frameCount) {
                let progress = Float(frame) / Float(max(noteFrames - 1, 1))
                let attack = min(progress / 0.12, 1)
                let release = min((1 - progress) / 0.18, 1)
                let envelope = min(attack, release)
                let time = Float(frame) / Float(sampleRate)
                let tone = sin(2 * Float.pi * note.frequency * time)
                let softOvertone = 0.35 * sin(2 * Float.pi * note.frequency * 2 * time)
                channel[frameOffset + frame] = (tone + softOvertone) * envelope * 0.58
            }
            frameOffset += noteFrames
        }

        return buffer
    }
}
