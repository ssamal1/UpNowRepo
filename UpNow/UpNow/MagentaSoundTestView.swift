//
//  SoundTestView.swift
//  UpNow
//
//  Created by Sanat Samal on 8/6/24.
//

//
//  SoundTestView.swift
//  UpNow
//
//  Created by Sanat Samal on 8/6/24.
//

//
//  SoundTestView.swift
//  UpNow
//
//  Created by Sanat Samal on 8/6/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct MagentaSoundTestView: View {
    @State private var isDownloading = false
    @State private var filePath: String?
    @State private var midiPlayer: AVMIDIPlayer?

    var body: some View {
        VStack {
            Button(action: {
                requestAndDownloadMelody()
            }) {
                Text(isDownloading ? "Downloading..." : "Generate and Download Melody")
                    .padding()
                    .background(isDownloading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isDownloading)

            if let filePath = filePath {
                VStack {
                    Text("File Path: \(filePath)")
                        .padding()
                        .foregroundColor(.black)

                    Button(action: {
                        playMIDI(from: filePath)
                    }) {
                        Text("Play MIDI")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }

    func requestAndDownloadMelody() {
        isDownloading = true

        generateMelody { fileUrl in
            guard let fileUrl = fileUrl else {
                print("Failed to generate melody")
                isDownloading = false
                return
            }

            downloadFile(from: fileUrl) { localFileUrl in
                guard let localFileUrl = localFileUrl else {
                    print("Failed to download file")
                    isDownloading = false
                    return
                }

                DispatchQueue.main.async {
                    filePath = localFileUrl.path
                    isDownloading = false
                }
            }
        }
    }

    func playMIDI(from path: String) {
        guard FileManager.default.fileExists(atPath: path) else {
            print("File does not exist at path: \(path)")
            return
        }

        // Release previous MIDI player instance
        midiPlayer?.stop()
        midiPlayer = nil

        do {
            let fileUrl = URL(fileURLWithPath: path)
            let soundBankURL = Bundle.main.url(forResource: "old house alarm soundfont V2", withExtension: "sf2")
            midiPlayer = try AVMIDIPlayer(contentsOf: fileUrl, soundBankURL: soundBankURL)
            midiPlayer?.prepareToPlay()
            midiPlayer?.play()
        } catch {
            print("Error initializing MIDI player: \(error)")
        }
    }

    func generateMelody(completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: "http://34.145.113.143:8080/generate") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        let parameters: [String: Any] = [
            "primer_melody": "[66, 67, 67, 71, 71, 72, 64, 66]",
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

struct MagentaSoundTestView_Previews: PreviewProvider {
    static var previews: some View {
        MagentaSoundTestView()
    }
}
