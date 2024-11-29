import FirebaseFirestore

struct Drink: Identifiable, Codable {
    @DocumentID var id: String?
    let userUID: String
    let type: DrinkType
    let name: String
    let price: Double
    let timestamp: Date
    
    enum DrinkType: String, Codable {
        case beer, wine, cocktail, shot, other
    }
} 
