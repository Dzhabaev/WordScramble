//
//  ContentView.swift
//  WordScramble
//
//  Created by Chingiz on 11.07.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Счёт: \(score)")
                        .font(.headline)
                }
                Section {
                    TextField("Введите ваше слово", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .toolbar {
                Button("Новая игра", action: startGame)
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Слово, которое уже использовалось", message: "Будь оригинальнее!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Ошибка в слове", message: "Вы не можете написать это слово '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Слово не распознано", message: "Вы не можете просто так выдумать слова")
            return
        }
        
        guard answer.count >= 3 else {
            wordError(title: "Слово слишком короткое", message: "Используйте слова из трёх и более букв")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Слово не может быть исходным", message: "Придумайте новое слово из букв '\(rootWord)'")
            return
        }
        
        guard !rootWord.contains(answer) else {
            wordError(title: "Слово слишком очевидное", message: "Нельзя использовать часть исходного слова '\(rootWord)' как есть")
            return
        }
        
        score += answer.count + 1
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        usedWords.removeAll()
        newWord = ""
        score = 0
        
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordURL, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: .newlines)
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Не удалось загрузить start.txt из ресурсов")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
