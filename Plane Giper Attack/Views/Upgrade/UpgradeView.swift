import SwiftUI

struct UpgradeView: View {
    
    @EnvironmentObject var user: User
    @Environment(\.presentationMode) var presMode
    @State var protection = UserDefaults.standard.integer(forKey: "protection")
    @State var healt = UserDefaults.standard.integer(forKey: "healt")
    @State var speed = UserDefaults.standard.integer(forKey: "speed")
    @State var upgradeError = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("close_btn")
                }
                
                Spacer()
                
                HStack {
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
                }
            }
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                ZStack {
                    Image("bonus_card")
                        .resizable()
                        .frame(width: 200, height: 190)
                    VStack(spacing: 0) {
                        ZStack {
                            Text("PROTECTION")
                                .font(.custom("Philosopher-Bold", size: 20))
                                .foregroundColor(.white)
                        }
                        .background(Image("header_bg"))
                        Spacer()
                        Image("protection")
                        Spacer()
                        HStack {
                            ForEach(1...4, id: \.self) { index in
                                if protection >= index {
                                    Image("upgrade_green")
                                } else {
                                    Image("upgrade_black")
                                }
                            }
                        }
                        Spacer()
                        
                    }
                    .frame(width: 200, height: 175)
                    
                    if protection < 4 {
                        Button {
                            if user.credits >= 30 * protection {
                                user.credits -= 30 * protection
                                withAnimation {
                                    protection += 1
                                }
                            } else {
                                upgradeError = true
                            }
                        } label: {
                            ZStack {
                                Image("btn_back_2")
                                HStack(spacing: 4) {
                                    Text("BUY")
                                        .font(.custom("Philosopher-Bold", size: 20))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 2, x: 0, y: 0)
                                        .offset(x: -10, y: -2)
                                    Text("\(30 * protection)")
                                        .font(.custom("Philosopher-Bold", size: 24))
                                        .foregroundColor(Color.init(red: 254/255, green: 210/255, blue: 63/255))
                                        .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 2, x: 0, y: 0)
                                        .offset(x: -10, y: -2)
                                    Image("coin")
                                }
                            }
                        }
                        .offset(y: 100)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Image("bonus_card")
                        .resizable()
                        .frame(width: 200, height: 190)
                    VStack(spacing: 0) {
                        ZStack {
                            Text("IMPROVING HEALT")
                                .font(.custom("Philosopher-Bold", size: 20))
                                .foregroundColor(.white)
                        }
                        .background(Image("header_bg"))
                        Spacer()
                        Image("healt")
                        Spacer()
                        HStack {
                            ForEach(1...4, id: \.self) { index in
                                if healt >= index {
                                    Image("upgrade_green")
                                } else {
                                    Image("upgrade_black")
                                }
                            }
                        }
                        Spacer()
                        
                    }
                    .frame(width: 200, height: 175)
                    
                    if healt < 4 {
                        Button {
                            if user.credits >= 30 * healt {
                                user.credits -= 30 * healt
                                withAnimation {
                                    healt += 1
                                }
                            } else {
                                upgradeError = true
                            }
                        } label: {
                            ZStack {
                                Image("btn_back_2")
                                HStack(spacing: 4) {
                                    Text("BUY")
                                        .font(.custom("Philosopher-Bold", size: 20))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 2, x: 0, y: 0)
                                        .offset(x: -10, y: -2)
                                    Text("\(30 * healt)")
                                        .font(.custom("Philosopher-Bold", size: 24))
                                        .foregroundColor(Color.init(red: 254/255, green: 210/255, blue: 63/255))
                                        .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 2, x: 0, y: 0)
                                        .offset(x: -10, y: -2)
                                    Image("coin")
                                }
                            }
                        }
                        .offset(y: 100)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Image("bonus_card")
                        .resizable()
                        .frame(width: 200, height: 190)
                    VStack(spacing: 0) {
                        ZStack {
                            Text("SPEED BOOST")
                                .font(.custom("Philosopher-Bold", size: 20))
                                .foregroundColor(.white)
                        }
                        .background(Image("header_bg"))
                        Spacer()
                        Image("speed")
                        Spacer()
                        HStack {
                            ForEach(1...4, id: \.self) { index in
                                if speed >= index {
                                    Image("upgrade_green")
                                } else {
                                    Image("upgrade_black")
                                }
                            }
                        }
                        Spacer()
                        
                    }
                    .frame(width: 200, height: 175)
                    
                    if speed < 4 {
                        Button {
                            if user.credits >= 30 * speed {
                                user.credits -= 30 * speed
                                withAnimation {
                                    speed += 1
                                }
                            } else {
                                upgradeError = true
                            }
                        } label: {
                            ZStack {
                                Image("btn_back_2")
                                HStack(spacing: 4) {
                                    Text("BUY")
                                        .font(.custom("Philosopher-Bold", size: 20))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 2, x: 0, y: 0)
                                        .offset(x: -10, y: -2)
                                    Text("\(30 * speed)")
                                        .font(.custom("Philosopher-Bold", size: 24))
                                        .foregroundColor(Color.init(red: 254/255, green: 210/255, blue: 63/255))
                                        .shadow(color: Color.init(red: 70/255, green: 60/255, blue: 60/255), radius: 2, x: 0, y: 0)
                                        .offset(x: -10, y: -2)
                                    Image("coin")
                                }
                            }
                        }
                        .offset(y: 100)
                    }
                }
                
                Spacer()
                
            }
            
            Spacer()
            
        }
        .onAppear {
            if protection == 0 {
                protection = 1
            }
            if healt == 0 {
                healt = 1
            }
            if speed == 0 {
                speed = 1
            }
        }
        .onChange(of: protection) { newValue in
            UserDefaults.standard.set(newValue, forKey: "protection")
        }
        .onChange(of: healt) { newValue in
            UserDefaults.standard.set(newValue, forKey: "healt")
        }
        .onChange(of: speed) { newValue in
            UserDefaults.standard.set(newValue, forKey: "speed")
        }
        .background(
            Image("tutorial_bg")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height + 50)
                .ignoresSafeArea()
        )
        .alert(isPresented: $upgradeError) {
            Alert(title: Text("Upgrade error"),
            message: Text("Upgrade error because you don't have enought credits to upgrade."),
                  dismissButton: .cancel(Text("GOT IT!")))
        }
    }
}

#Preview {
    UpgradeView()
        .environmentObject(User())
}
