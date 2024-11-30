import SwiftUI
import FirebaseFirestore

struct DrinkHistoryView: View {
    @State private var drinks: [Drink] = []
    @State private var totalSpent: Double = 0
    @State private var showAddDrink: Bool = false
    @AppStorage("user_UID") private var userUID: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    HStack {
                        Text("Total Spent")
                        Spacer()
                        Text(totalSpent, format: .currency(code: "USD"))
                    }
                }
                
                Section("History") {
                    ForEach(drinks) { drink in
                        DrinkRowView(drink: drink)
                    }
                    .onDelete(perform: deleteDrinks)
                }
            }
            .navigationTitle("Drink History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddDrink = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddDrink) {
                AddDrinkView(refreshDrinks: refreshDrinks)
            }
            .task {
                await fetchDrinks()
            }
        }
    }
    
    func refreshDrinks() async {
        await fetchDrinks()
    }
    
    func fetchDrinks() async {
        do {
            let snapshot = try await Firestore.firestore().collection("Drinks")
                .whereField("userUID", isEqualTo: userUID)
                .order(by: "timestamp", descending: true)
                .getDocuments()
            
            await MainActor.run {
                drinks = snapshot.documents.compactMap { try? $0.data(as: Drink.self) }
                totalSpent = drinks.reduce(0) { $0 + $1.price }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteDrinks(at offsets: IndexSet) {
        Task {
            do {
                // Get the drinks to delete
                let drinksToDelete = offsets.map { drinks[$0] }
                
                // Delete each drink from Firestore
                for drink in drinksToDelete {
                    if let drinkID = drink.id {
                        try await Firestore.firestore().collection("Drinks")
                            .document(drinkID)
                            .delete()
                    }
                }
                
                // Update local state
                await MainActor.run {
                    drinks.remove(atOffsets: offsets)
                    totalSpent = drinks.reduce(0) { $0 + $1.price }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct DrinkRowView: View {
    let drink: Drink
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(drink.name)
                    .font(.headline)
                Text(drink.type.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(drink.price, format: .currency(code: "USD"))
                Text(drink.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
