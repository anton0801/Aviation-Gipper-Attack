import Foundation

class User: ObservableObject {
    
    @Published var credits: Int = UserDefaults.standard.integer(forKey: "credits") {
        didSet {
            UserDefaults.standard.set(credits, forKey: "credits")
        }
    }
    
    @Published var energy: Int = UserDefaults.standard.integer(forKey: "energy") {
        didSet {
            UserDefaults.standard.set(energy, forKey: "energy")
        }
    }
    
    init() {
        if !UserDefaults.standard.bool(forKey: "is_not_first_launch") {
            energy = 60
            UserDefaults.standard.set(true, forKey: "is_not_first_launch")
        }
    }
    
}
