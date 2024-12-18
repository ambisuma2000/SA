//
//  NewTabView.swift
//  Hi Bunny2
//
//  Created by suma Ambadipudi on 17/12/24.
//
import SwiftUI
import Speech
import AVFoundation
class AudioManager {
    private let audioEngine = AVAudioEngine()

    func startRecording() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Remove any existing tap first
        inputNode.removeTap(onBus: 0)

        // Install a new tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            // Handle the audio buffer here
            print("Audio buffer received")
        }

        do {
            try audioEngine.start()
            print("Audio engine started successfully")
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        _ = audioEngine.inputNode

        // Stop the audio engine and clean up the tap
        audioEngine.stop()
//        inputNode.removeTap(onBus: 0)
        print("Audio engine stopped and tap removed")
    }
}


func setupAudioSession() {
    do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
        print("Audio session configured successfully")
    } catch let error as NSError {
        print("Failed to configure audio session: \(error.localizedDescription)")
    }
}

private let audioEngine = AVAudioEngine()

struct NewTabView: View {
    @State private var recognizedText = "Ask me anything!"
    @State private var isListening = false
    @State private var isListeningText = "Start Listening"
    @State private var isDancing = false
    private let synthesizer = AVSpeechSynthesizer()
    
    // SFSpeechRecognizer
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    var body: some View {
        VStack {
            Image("bunny")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 535)
                .rotationEffect(.degrees(isDancing ? 15 : 0))
                .offset(y: isDancing ? -10 : 0)
                .animation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true), value: isDancing)
                .padding()
            
            Text(recognizedText)
                .font(.title)
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(10)
                .padding()
            
            Button(action: {
                if isListening {
                    stopListening()
                } else {
                    startListening()
                }
            }) {
                Text(isListeningText)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(isListening ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.mint.opacity(0.3).ignoresSafeArea())
        .navigationTitle("Ask Bunny")
        .onAppear {
            requestPermission()
            setupAudioSession()  // Ensure the audio session is set up when the view appears
        }
    }
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    
    private func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            default:
                print("Speech recognition authorization failed")
            }
        }
    }
    
    private func startListening() {
        isListening = true
        isListeningText = "Stop Listening"
        
        recognizedText = "Listening... Speak to me!"
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.inputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            request.append(buffer)
            print("Audio buffer received")
        }
        
        do {
            try audioEngine.start()
            print("Audio engine started successfully")
        } catch {
            print("Audio engine couldn't start: \(error.localizedDescription)")
        }
        
        speechRecognizer?.recognitionTask(with: request) { result, error in
            if let error = error {
                print("Recognition task error: \(error.localizedDescription)")
                return
            }
            
            if let result = result {
                // Ensure UI updates happen on the main thread
                       DispatchQueue.main.async {
                           recognizedText = result.bestTranscription.formattedString
                       }
                       
                       // You can also handle the command here if necessary
                       handleCommand(result.bestTranscription.formattedString)

            }
        }
    }
    
    private func stopListening() {
        isListening = false
        isListeningText = "Start Listening"
        recognizedText = "Stopped listening."
        audioEngine.stop()  // Stop the audio engine when listening is stopped
        
        let inputNode = audioEngine.inputNode
            inputNode.removeTap(onBus: 0) // Remove the tap from the input node
            audioEngine.stop()
            print("Audio engine stopped and tap removed")
    }
    
    private func handleCommand(_ command: String) {
        let lowercasedCommand = command.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if lowercasedCommand.contains("weather") {
            respondWith("The weather is sunny!")
        } else if lowercasedCommand.contains("youtube") {
            respondWith("Opening YouTube!")
            if let url = URL(string: "https://www.youtube.com") {
                UIApplication.shared.open(url)
            }
        } else if lowercasedCommand.contains("google") {
            respondWith("Let's search on Google!")
            if let url = URL(string: "https://www.google.com") {
                UIApplication.shared.open(url)
            }
        } else if lowercasedCommand.contains("music") {
            respondWith("Playing Apple Music!")
            isDancing = true
            if let url = URL(string: "https://music.apple.com") {
                UIApplication.shared.open(url)
            }
        } else if lowercasedCommand.contains("how are you") {
            respondWith("I'm doing great, thank you for asking!")
        } else if lowercasedCommand.contains("tell me a joke") {
            respondWith("Why don't skeletons fight each other? They don't have the guts!")
        } else if lowercasedCommand.contains("bye") {
            respondWith("Goodbye! See you soon!")
            stopListening()
            isDancing = false
        } else {
            respondWith("I don't understand that command.")
        }
    }

    
    private func respondWith(_ text: String) {
        if let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) {
            if !speechRecognizer.isAvailable {
                print("Speech recognizer is not available.")
            } else {
                print(text)
            }
        }
        
    }
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Choose voice and language
        utterance.rate = 0.5 // Adjust speech rate (0.0 - 1.0)
        
        synthesizer.speak(utterance) // Speak the text
    }

    
    struct NewTabView_Previews: PreviewProvider {
        static var previews: some View {
            NewTabView()
        }
    }
}
