import AVFoundation
import Combine

class SoundGeneration: ObservableObject {
    static let shared = SoundGeneration()

    var isDownloading = false
    var filePath: String?
    var midiPlayer: AVMIDIPlayer?
    private var playCount = 0
    private var maxPlayCount = 4 // Default to 4, can be adjusted

    init() {
        // Configure the audio session for background audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func requestAndDownloadMelody(completion: @escaping () -> Void) {
        guard !isDownloading else {
            print("Already downloading...")
            return
        }

        isDownloading = true

        generateMelody { [weak self] fileUrl in
            guard let self = self else { return }
            guard let fileUrl = fileUrl else {
                print("Failed to generate melody")
                self.isDownloading = false
                completion()
                return
            }

            self.downloadFile(from: fileUrl) { localFileUrl in
                guard let localFileUrl = localFileUrl else {
                    print("Failed to download file")
                    self.isDownloading = false
                    completion()
                    return
                }

                DispatchQueue.main.async {
                    self.filePath = localFileUrl.path
                    self.isDownloading = false
                    completion()
                }
            }
        }
    }

    // Allow the caller to specify how many times to repeat the playback
    func playMIDI(from path: String, repeatCount: Int, completion: @escaping () -> Void) {
        guard FileManager.default.fileExists(atPath: path) else {
            print("File does not exist at path: \(path)")
            return
        }

        // Set the max play count based on repeatCount parameter
        self.maxPlayCount = repeatCount

        // Release previous MIDI player instance
        midiPlayer?.stop()
        midiPlayer = nil

        do {
            let fileUrl = URL(fileURLWithPath: path)
            let soundBankURL = Bundle.main.url(forResource: "old house alarm soundfont V2", withExtension: "sf2")
            midiPlayer = try AVMIDIPlayer(contentsOf: fileUrl, soundBankURL: soundBankURL)
            midiPlayer?.prepareToPlay()
            startPlayback(completion: completion)
        } catch {
            print("Error initializing MIDI player: \(error)")
        }
    }

    private func startPlayback(completion: @escaping () -> Void) {
        playCount = 0 // Reset the play count
        playNext(completion: completion)
    }

    private func playNext(completion: @escaping () -> Void) {
        guard playCount < maxPlayCount else {
            stopPlayback()
            completion()
            return
        }

        midiPlayer?.play { [weak self] in
            guard let self = self else { return }
            self.playCount += 1
            print("Playback count: \(self.playCount)")

            if self.playCount < self.maxPlayCount {
                // Restart the playback after the previous one finishes
                self.midiPlayer?.currentPosition = 0
                self.playNext(completion: completion)
            } else {
                self.stopPlayback()
                completion()
            }
        }
    }

    private func stopPlayback() {
        midiPlayer?.stop()
        
        // Notify that playback has ended
        NotificationCenter.default.post(name: .audioPlaybackFinished, object: nil)
    }

    // This function stops audio immediately when called
    func stopAudio() {
        midiPlayer?.stop()
        playCount = 5
        print("Audio stopped")
    }

    func generateMelody(completion: @escaping (URL?) -> Void) {
        // Assuming QLearningAgent is a singleton or accessible instance
        let qLearningAgent = QLearningAgent(stateSize: 10, actionSize: 5)
        qLearningAgent.trainAndUpdatePrimerMelody()

        // Wait for the Q-Learning agent to update the primer melody
        DispatchQueue.global().async {
            // Fetch the updated primer melody from AlarmStateManager
            let primerMelody = AlarmStateManager.shared.latestPrimerMelody ?? "[66, 67, 67, 71, 71, 72, 64, 66]"

            guard let url = URL(string: "http://34.145.113.143:8080/generate") else {
                print("Invalid URL")
                completion(nil)
                return
            }

            let parameters: [String: Any] = [
                "primer_melody": primerMelody,
                "num_steps": 128,
                "num_outputs": 1
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                print("Failed to serialize JSON")
                completion(nil)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(nil)
                    return
                }

                guard let data = data else {
                    print("No data received")
                    completion(nil)
                    return
                }

                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = jsonResponse["status"] as? String, status == "success",
                   let fileUrlString = jsonResponse["file_url"] as? String,
                   let fileUrl = URL(string: fileUrlString) {
                    completion(fileUrl)
                } else {
                    print("Failed to decode JSON or file not generated")
                    completion(nil)
                }
            }

            task.resume()
        }
    }
    
    func downloadFile(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localUrl, response, error in
            if let error = error {
                print("Download error: \(error)")
                completion(nil)
                return
            }

            guard let localUrl = localUrl else {
                print("No local URL")
                completion(nil)
                return
            }

            let fileManager = FileManager.default
            let destinationUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(url.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: destinationUrl.path) {
                    try fileManager.removeItem(at: destinationUrl)
                }
                try fileManager.moveItem(at: localUrl, to: destinationUrl)
                completion(destinationUrl)
            } catch {
                print("Error moving file: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }
}

extension Notification.Name {
    static let audioPlaybackFinished = Notification.Name("audioPlaybackFinished")
}
