//
//  CardCounter.swift
//  MLSC_CardShark
//
//  Created by Joshua Sylvester on 12/9/21.
//

import Foundation



protocol CardCounterDelegate {
    // Classes that adopt this protocol MUST define
    // this method -- and hopefully do something in
    // that definition.
    func updateCardCountingUI(_ sender:CardCounter)
}


class CardCounter {
    
    var count: Int = 0;
    private var playedCards: [String: Int] = [:]
    
    var delegate: CardCounterDelegate?
    
    
    init() {
        
    }
    
    func reset(){
        count = 0
        playedCards = [:]
    }
    
    func changeCount(card: String) {
        // https://www.tutorialkart.com/swift-tutorial/check-if-key-is-present-in-dictionary-swift/
        let keyExists = playedCards[card] != nil
        
        // if card has been seen and it hasn't been counted
        if keyExists && playedCards[card] != -1 {
            playedCards[card]? += 1
            if playedCards[card]! > 30 { // have to have seen the card for 2 seconds
                countCard(card: card)
                playedCards[card] = -1
            }
            return;
        } else if playedCards[card] != -1 { // first time we see card
            playedCards[card] = 1
        }
        
    }
    
    func getPlayedCards()->[String: Int]{
        return self.playedCards
    }
    
    func getCount()->Int{
        return self.count
    }
        
        private func countCard(card: String){
            // Hi-Lo system
            switch(card){
            case "1h", "1d", "1c", "1s",
                 "2h", "2d", "2c", "2s",
                 "3h", "3d", "3c", "3s",
                 "4h", "4d", "4c", "4s",
                 "5h", "5d", "5c", "5s",
                 "6h", "6d", "6c", "6s":
                count += 1
            case "10h", "10d", "10c", "10s",
                "Jh", "Jd", "Jc", "Js",
                "Qh", "Qd", "Qc", "Qs",
                "Kh", "Kd", "Kc", "Ks",
                "Ah", "Ad", "Ac", "As":
                count -= 1
            default:
                print("we got a 0 count card", card)
            }
            
            print("card counted: ", card)
            print("New Count: ", count)
            self.updateUI()
                
        }
    
    func updateUI(){
        delegate?.updateCardCountingUI(self)
    }
    
}
