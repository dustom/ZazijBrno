//
//  ClickableDetailItem.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 19.04.2025.
//

import SwiftUI


// an expandable view that shows just a snippet of a text that is expanded on tapping
struct ClickableDetailItemView: View {
    @Binding var isSelectionPresented: Bool
    var itemName: String
    var itemData: String
    var body: some View {
        VStack {
            // the whole VStack is basically a button to provide a better user experience
            // when the button is tapped it toggles the isSelectionPresented which then decides what should be shown
            Button {
                withAnimation(.smooth) {
                    isSelectionPresented.toggle()
                }
            } label: {
                HStack {
                    VStack {
                        HStack {
                            
                            //MARK: headline
                            Text(itemName)
                                .font(.headline)
                            Spacer()
                            withAnimation {
                                
                                //MARK: contextual clue
                                if !isSelectionPresented {
                                    Text("Zjistit více")
                                        .foregroundStyle(Constants.brnoColor)
                                        .font(.footnote)
                                } else {
                                    Text("Skrýt")
                                        .foregroundStyle(Constants.brnoColor)
                                        .font(.footnote)
                                }
                            }
                            
                            //MARK: animated chevron
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(isSelectionPresented ? 90 : 0))
                                .animation(.smooth, value: isSelectionPresented)
                                .foregroundStyle(Constants.brnoColor)
                                .font(.footnote)
                        }
                        
                        //MARK: tex body
                        HStack {
                            Text(itemData)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(isSelectionPresented ? 1000 : 2)
                        }
                    }
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    @Previewable @State var showSheet = false
    ClickableDetailItemView(
        isSelectionPresented: $showSheet,
        itemName: "Informace od poradatele",
        itemData: "Do ČR se vrací renomovaná hardrocková kapela Nazareth! V únoru 2026 potěší fanoušky v brněnském Sonu a&nbsp;o&nbsp;den později v Aule Gong Ostrava.Nazareth je skotská rocková skupina, známá mnoha rockovými hity, stejně jako skvělou cover verzí balady Love Hurts z&nbsp;poloviny 70.&nbsp;let. Skupina byla založena ve městě Dunfermline ze zbytků poloprofesionální místní kapely The Shadettes (původně Mark V&nbsp;a&nbsp;The Red Hawks) zpěvákem Danem McCaffertym, kytaristou Mannym Charltonem, basákem Petem Agnewem a&nbsp;bubeníkem Darrellem Sweetem. Jméno získali ze skladby The Weight od skupiny The Band. V&nbsp;roce 1970 se skupina přesunula do Londýna, kde roku 1971 vydala své první, stejnojmenné album. Po získání pozornosti díky albu Exercises z&nbsp;roku 1972, Nazreth vydali další album Razamanaz na začátku roku 1973.Skladby jako Broken Down Angel a&nbsp;Bad Bad Boy se umístily v&nbsp;britském žebříčku Top 10 list. Poté následovalo album Loud N Proud na konci roku 1973, které obsahovalo hit This Flight Tonight, původně od Joni Mitchell. Roku 1974 vydali album Rampant, které bylo neméně úspěšné, třebaže neobsahovalo žádný singl. Další skladba (neobjevuje se na žádném albu), opět cover verze, tentokrát skladby My White Bicycle, se na začátku roku 1975 umístila v&nbsp;UK Top 20. Album Hair of the Dog bylo vydáno roku 1975. Titulní skladba (populárně, i&nbsp;když nesprávně známá jako „Now You`re Messing With a&nbsp;Son of a&nbsp;Bitch“) se stala základem rockových rádií 70.&nbsp;let. Americké vydání alba obsahuje skladbu Love Hurts, původně od The Everly Brothers a&nbsp;také nahranou Royem Orbisonem. Tato skladba byla ve Spojeném království a&nbsp;USA vydána jako singl. V&nbsp;USA byla oceněna jako platinová. Je to jediná skladba od Nazareth, která se umístila v&nbsp;americkém Top Ten.V létě 2013 Dan McCafferty oznámil, že ze zdravotních důvodů opouští kapelu. V&nbsp;únoru 2014 jej nahradil Linton Osborne, avšak v&nbsp;prosinci 2014 byla kapela kvůli Osbornově nemoci nucena zrušit několik koncertů a&nbsp;odložit turné po Spojeném království. V&nbsp;lednu Osborne na svém Facebooku oznámil odchod z&nbsp;Nazareth a&nbsp;o&nbsp;měsíc později kapela, kterou aktuálně tvoří její spoluzakladatel Pete Agnew (baskytara), jeho syn Lee Agnew (bicí) a&nbsp;Jimmy Murrison (kytara, v&nbsp;kapele působí již od 1994) na webu ohlásila nového zpěváka, kterým je Carl Sentance. Sentance spolupracoval s mnoha slavnými formacemi a&nbsp;hudebníky, a&nbsp;to například s&nbsp; Foreigner, Dio a&nbsp;Black Sabbath a&nbsp;byl frontmanem známé švýcarské skupiny Krokus.")
}
