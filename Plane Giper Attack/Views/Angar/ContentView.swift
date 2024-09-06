import SwiftUI

struct ContentView: View {
    
    @State var tutorialSaw = UserDefaults.standard.bool(forKey: "tutorial_saw")
    
    @State var settingsItemsVisible = false
    
    @State var soundsApp = UserDefaults.standard.bool(forKey: "sounds")
    @State var volumeApp = UserDefaults.standard.bool(forKey: "volume")
    
    var body: some View {
        VStack {
            if tutorialSaw {
                angarContentView
            } else {
                TutorialView(showedTutorial: $tutorialSaw)
            }
        }
        .onChange(of: tutorialSaw) { _ in
            UserDefaults.standard.set(true, forKey: "tutorial_saw")
        }
    }
    
    @StateObject var user = User()
    
    @State var currentLevel = 1
    @State var levelImage = "level_1_attacking"
    
    private var angarContentView: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Button {
                                withAnimation {
                                    settingsItemsVisible = !settingsItemsVisible
                                }
                            } label: {
                                Image("settings_btn")
                            }
                            if settingsItemsVisible {
                                Button {
                                    withAnimation {
                                        soundsApp = !soundsApp
                                    }
                                } label: {
                                    if soundsApp {
                                        Image("sounds_on")
                                    } else {
                                        Image("sounds_off")
                                    }
                                }
                                .padding(.leading)
                                
                                Button {
                                    withAnimation {
                                        volumeApp = !volumeApp
                                    }
                                } label: {
                                    if volumeApp {
                                        Image("volume_on")
                                    } else {
                                        Image("volume_off")
                                    }
                                }
                                .padding(.leading)
                            }
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        NavigationLink(destination: UpgradeView()
                            .environmentObject(user)
                            .navigationBarBackButtonHidden(true)) {
                            Image("upgrade")
                        }
                        
                        Spacer()
                        
                        Image("attacking_btn_off")
                    }
                    .edgesIgnoringSafeArea(.leading)
                    
                    Spacer()
                    
                    Button {
                        if currentLevel > 1 {
                            currentLevel -= 1
                        }
                    } label: {
                        Image("arrow_back")
                    }
                    
                    Spacer()
                    
                    VStack {
                        if currentLevel == 1 {
                            NavigationLink(destination: GameView(level: currentLevel)
                                .environmentObject(user)
                                .navigationBarBackButtonHidden(true)) {
                                Image(levelImage)
                                    .offset(y: 20)
                            }
                        } else {
                            Image(levelImage)
                                .offset(y: 20)
                            playLevelPrice
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        if currentLevel < 6 {
                            currentLevel += 1
                        }
                    } label: {
                        Image("arrow_next")
                    }
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            Image("balance_bg")
                            Text("\(user.credits)")
                                .font(.custom("Philosopher-Bold", size: 18))
                                .foregroundColor(Color.init(red: 254/255, green: 210/255, blue: 63/255))
                                .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 1, x: 0, y: 0)
                                .offset(x: -10, y: -2)
                        }
                        ZStack {
                            Image("energy_background")
                            Text("\(user.energy)")
                                .font(.custom("Philosopher-Bold", size: 18))
                                .foregroundColor(Color.init(red: 252/255, green: 159/255, blue: 0))
                                .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 1, x: 0, y: 0)
                                .offset(x: -10, y: -2)
                        }
                        
                        Spacer()
                        
//                        Button {
//                            dailyReward()
//                        } label: {
//                            Image("daily")
//                        }
                        
//                        Spacer()
                        
                        Image("levels")
                        
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                }
            }
            .background(
                Image("tutorial_bg")
                    .resizable()
                    .frame(minWidth: UIScreen.main.bounds.width,
                           minHeight: UIScreen.main.bounds.height + 50)
                    .ignoresSafeArea()
            )
            .onChange(of: currentLevel) { _ in
                withAnimation {
                    levelImage = "level_\(currentLevel)_attacking"
                }
            }
            .alert(isPresented: $showEnergyAlert) {
                Alert(title: Text("Energy error"), message: Text("NOT ENOUGHT ENERGY TO PLAY"), dismissButton: .cancel(Text("OK")))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var playLevelPrice: some View {
        VStack {
            if currentLevel > 1 {
                Button {
                    if user.energy >= 30 {
                        user.energy -= 30
                        goToGame = true
                    } else {
                        showEnergyAlert = true
                    }
                } label: {
                    ZStack {
                        Image("btn_back_2")
                        HStack(spacing: 0) {
                            Text("PLAY")
                                .font(.custom("Philosopher-Bold", size: 24))
                                .foregroundColor(.white)
                                .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 2, x: 0, y: 0)
                                .offset(x: -10, y: -2)
                            Text("30")
                                .font(.custom("Philosopher-Bold", size: 24))
                                .foregroundColor(Color.init(red: 254/255, green: 210/255, blue: 63/255))
                                .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 2, x: 0, y: 0)
                                .offset(x: -10, y: -2)
                            Image("ic_energy")
                        }
                    }
                }
                .offset(y: -20)
            }
            if goToGame {
                NavigationLink(destination: GameView(level: currentLevel)
                    .environmentObject(user)
                    .navigationBarBackButtonHidden(true), isActive: $goToGame) {
                                
                }
            }
        }
    }
    
    @State private var goToGame = false
    @State private var showEnergyAlert = false
    
    private func dailyReward() {
        
    }
    
}

#Preview {
    ContentView()
}
