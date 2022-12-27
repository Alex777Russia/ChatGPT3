//
//  ContentView.swift
//  GhatGPT3
//
//  Created by Алексей Шевченко on 27.12.2022.
//

import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "sk-EskHrCcstpTFQpn61cCT3BlbkFJD2ny5KKmsNyzW3vyV6XI")
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text,
                               maxTokens: 500,
                               completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()

    var body: some View {
        VStack(alignment: .leading){
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            
            Spacer()
            
            HStack {
                TextField("Type here...", text: $text)
                Button("Send") {
                    send()
                }
            }
        }
        .onAppear() {
            viewModel.setup()
        }
        .padding()

    }

    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        models.append("Me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                self.models.append("ChatGPT3: " + response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
