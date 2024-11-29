import SwiftUI
import FirebaseFirestore

struct AddDrinkView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var drinkType: Drink.DrinkType = .beer
    @State private var name: String = ""
    @State private var price: Double = 0.0
    @AppStorage("user_UID") private var userUID: String = ""
    var refreshDrinks: () async -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $drinkType) {
                    Text("Beer").tag(Drink.DrinkType.beer)
                    Text("Wine").tag(Drink.DrinkType.wine)
                    Text("Cocktail").tag(Drink.DrinkType.cocktail)
                    Text("Shot").tag(Drink.DrinkType.shot)
                    Text("Other").tag(Drink.DrinkType.other)
                }
                
                TextField("Drink Name", text: $name)
                TextField("Price", value: $price, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                
                Button("Log Drink") {
                    Task {
                        await logDrink()
                    }
                }
            }
            .navigationTitle("Add Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func logDrink() async {
        let drink = Drink(
            userUID: userUID,
            type: drinkType,
            name: name,
            price: price,
            timestamp: Date()
        )
        
        do {
            try await Firestore.firestore().collection("Drinks")
                .document()
                .setData(from: drink)
            await refreshDrinks()
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
}
