//
//  ContentView.swift
//  BlackJackGame
//
//  Created by Aidan O'Hara on 6/11/24.
//

import SwiftUI


//struct User: Identifiable, Codable {
//    var id = UUID()
//    let userName: String
//    let money: Double
//}

//@Observable
//class Username {
//    var username = [User]() {
//        didSet {
//            if let encoded = try? JSONEncoder().encode(items) {
//                UserDefaults.standard.set(encoded, forKey: "Username")
//            }
//        }
//    }
//    init() {
//        if let savedItems = UserDefaults.standard.data(forKey: "Username") {
//            if let decodedItems = try? JSONDecoder().decode([User].self, from: savedItems) {
//                username = decodedItems
//                return
//            }
//        }
//    }
//}

struct Card {
    let name: String
    let value: Int
}



struct ContentView: View {
    @State private var userName = ""
    @State private var signedIn = false
    @State private var showingSignIn = false
    
    @State private var isDealt = false
    @State private var isStood = false
    
    @State private var userTotal = 0
    @State private var dealerTotal = 0;
    
    let suits = ["C", "D", "S", "H"]
    let cardNumbers = [1,2,3,4,5,6,7,8,9,10,11,12,13]
    
    @State private var deck = [Card]()
    
    @State private var dealerCards = [String]()
    @State private var userCards = [String]()
    
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError =  false
    
    @State private var streak = 0
    
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text("Dealers Cards")
                        .font(.largeTitle)
                        .bold()
//                    Text("\(dealerTotal)")
//                        .font(.subheadline)
                    HStack {
                        if !isStood {
                            Image("\(dealerCards.first ?? "bicycle_blue")")
                                .resizable()
                                .frame(width: 75, height: 150)
                            Image("bicycle_blue")
                                .resizable()
                                .frame(width: 75, height: 150)
                        }
                        else {
                            ForEach(dealerCards, id: \.self) { num in
                                Image("\(num)")
                                    .resizable()
                                    .frame(width: 75, height: 150)
                            }
                        }
                    }
                    Spacer()
                    
                    Text("User Cards")
                        .font(.largeTitle)
                        .bold()
//                    Text("\(userTotal)")
//                        .font(.subheadline)
                    HStack {
                        ForEach(userCards, id: \.self) { num in
                            Image("\(num)")
                                .resizable()
                                .frame(width: 75, height: 150)
                        }
                    }
                    Spacer()
                    
                    Text("Current Streak: \(streak)")
                }
                HStack {
                    Button("Deal Cards") {
                        dealCards()
                    }
                    .padding()
                    .background(.black)
                    .clipShape(.capsule)
                    .padding()
                    Button("Stand") {
                        isStood = true
                        stand()
                    }
                    .padding()
                    .background(.black)
                    .clipShape(.capsule)
                    .padding()
                    Button("Hit") {
                        hit()
                    }
                    .padding()
                    .background(.black)
                    .clipShape(.capsule)
                    .padding()
                }
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 4)
            }
            .onAppear(perform: createDeck)
            .navigationTitle("BlackJackGo")
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Image("9999520"))
            .toolbar {
//                if !signedIn {
//                    Button("Sign In") {
//                        showingSignIn = true
//                    }
//                }
                Button("Restart Game") {
                    restartGame()
                }
                
            }
            .sheet(isPresented: $showingSignIn) {
                SignIn()
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") {
                    
                }
            } message: {
                Text(errorMessage)
            }
            
        }
    }
    
    func restartGame() {
        userCards.removeAll()
        dealerCards.removeAll()
        userTotal = 0
        dealerTotal = 0
        isDealt = false
        isStood = false
        
        dealCards()
    }
    
    func createDeck() {
        for suit in suits {
            for num in cardNumbers {
                let card = Card(name: "\(num)\(suit)", value: num)
                deck.append(card)
            }
        }
    }
    
    func dealCards() {
        if !isDealt {
            isDealt = true
            let card1 = deck.randomElement()
            withAnimation {
                userCards.append(card1?.name ?? "2C")
            }
            if (card1?.value ?? 2) >= 10 {
                userTotal += 10
            }
            else{
                userTotal += card1?.value ?? 2
            }
            
            
            let card2 = deck.randomElement()
            withAnimation {
                dealerCards.append(card2?.name ?? "2C")
            }
            if (card2?.value ?? 2) >= 10 {
                dealerTotal += 10
            }
            else{
                dealerTotal += card2?.value ?? 2
            }
            
            
            let card3 = deck.randomElement()
            withAnimation {
                dealerCards.append(card3?.name ?? "2C")
            }
            if (card3?.value ?? 2) >= 10 {
                dealerTotal += 10
            }
            else{
                dealerTotal += card3?.value ?? 2
            }
        }
    }
    
    func stand() {
        
        while dealerTotal < 16 && !(dealerTotal > 21) {
            
            let card2 = deck.randomElement()
            withAnimation {
                dealerCards.append(card2?.name ?? "2C")
            }
            if (card2?.value ?? 2) >= 10 {
                dealerTotal += 10
            }
            else{
                dealerTotal += card2?.value ?? 2
            }
        }
        
        guard dealerBlackjack() else {
                gameError(title: "You Lose!", messgage: "The dealer has blackjack!")
                streak = 0
                return
        }
        
        guard overDealer() else {
            gameError(title: "You win!", messgage: "The dealer busted!")
            streak += 1
            return
        }
        
        guard userWins() else {
            gameError(title: "You win!", messgage: "Your total is higher than the dealers!")
            streak += 1
            return
        }
        guard userLose() else {
            gameError(title: "You lose!", messgage: "Your total is lower than the dealers!")
            streak = 0
            return
        }
        guard push() else {
            gameError(title: "Push!", messgage: "Your total is equal than the dealers!")
            return
        }
        
    }
    
    func hit() {
        let card1 = deck.randomElement()
        withAnimation {
            userCards.append(card1?.name ?? "2C")
        }
        if (card1?.value ?? 2) >= 10 {
            userTotal += 10
        }
        else{
            userTotal += card1?.value ?? 2
        }
        
        guard equal21() else {
            gameError(title: "BlackJack!!", messgage: "Congrats you win!")
            streak += 1
            return
        }
        guard over21() else {
            gameError(title: "Bust!", messgage: "You have gone over 21!")
            streak = 0
            return
        }
    }
    
    func dealerBlackjack() -> Bool {
        return dealerTotal != 21
    }
    
    func equal21() -> Bool {
        return userTotal != 21
    }
    
    func over21() -> Bool {
        return userTotal < 21
    }
    
    func overDealer() -> Bool {
        return !(userTotal < 21 && dealerTotal > 21)
    }
    
    
    func userWins() -> Bool {
        return userTotal <= dealerTotal
    }
    
    func userLose() -> Bool {
        return userTotal >= dealerTotal
    }
    func push() -> Bool {
        return userTotal != dealerTotal
    }
    
    
    func gameError(title: String, messgage: String) {
        errorTitle = title
        errorMessage = messgage
        showingError = true
    }
}
    
    
    
#Preview {
    ContentView()
}
