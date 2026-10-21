import AVFoundation

enum AudioFeedback {
    private static let playbackQueue = DispatchQueue(
        label: "com.habittracker.audio-feedback",
        qos: .userInitiated
    )

    static func playCompletionSound() {
        playbackQueue.async {
            do {
                let player = try AVAudioPlayer(data: completionSoundData())
                player.prepareToPlay()
                guard player.play() else {
                    NSLog("Не удалось запустить звук выполнения привычки.")
                    return
                }

                playbackQueue.asyncAfter(deadline: .now() + 0.5) {
                    withExtendedLifetime(player) {}
                }
            } catch {
                NSLog("Не удалось создать звук выполнения привычки: \(error)")
            }
        }
    }

    private static func completionSoundData() -> Data {
        let sampleRate = 44_100
        let sampleCount = sampleRate / 5
        let bytesPerSample = MemoryLayout<Int16>.size
        let audioDataSize = sampleCount * bytesPerSample
        var data = Data()

        data.append(contentsOf: Array("RIFF".utf8))
        data.appendLittleEndian(UInt32(36 + audioDataSize))
        data.append(contentsOf: Array("WAVEfmt ".utf8))
        data.appendLittleEndian(UInt32(16))
        data.appendLittleEndian(UInt16(1))
        data.appendLittleEndian(UInt16(1))
        data.appendLittleEndian(UInt32(sampleRate))
        data.appendLittleEndian(UInt32(sampleRate * bytesPerSample))
        data.appendLittleEndian(UInt16(bytesPerSample))
        data.appendLittleEndian(UInt16(16))
        data.append(contentsOf: Array("data".utf8))
        data.appendLittleEndian(UInt32(audioDataSize))

        for index in 0..<sampleCount {
            let progress = Double(index) / Double(sampleCount)
            let frequency = 660 + 440 * progress
            let fadeIn = min(Double(index) / 500, 1)
            let fadeOut = min(Double(sampleCount - index) / 1_500, 1)
            let envelope = min(fadeIn, fadeOut) * 0.2
            let sample = sin(2 * Double.pi * frequency * Double(index) / Double(sampleRate))
                * envelope
            let pcmSample = Int16(sample * Double(Int16.max))
            data.appendLittleEndian(UInt16(bitPattern: pcmSample))
        }

        return data
    }
}

private extension Data {
    mutating func appendLittleEndian<T: FixedWidthInteger>(_ value: T) {
        var littleEndianValue = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndianValue) { bytes in
            append(contentsOf: bytes)
        }
    }
}
