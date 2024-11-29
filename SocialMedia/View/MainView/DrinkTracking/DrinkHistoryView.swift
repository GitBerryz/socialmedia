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
