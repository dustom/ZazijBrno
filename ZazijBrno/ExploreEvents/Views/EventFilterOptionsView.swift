//
//  EventFilterOptionsView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 19.04.2025.
//

import SwiftUI

// a view that allows to filter events based on their primary category
struct EventFilterOptionsView: View {
    let k = Constants()
    @Environment(\.dismiss) var dismiss
    @Binding var selectedOptions: Set<EventCategory>
    private var selectAllOptions: Bool {
        selectedOptions == Set(EventCategory.allCases)
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                //MARK: ALL events row
                HStack {
                    Image(systemName:"line.3.horizontal.circle")
                        .frame(width: 40)
                        .foregroundStyle(k.brnoColor)
                    Text("Všechny")
                    Spacer()
                    Image(systemName: selectAllOptions ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectAllOptions ? k.brnoColor : .gray)
                    
                }
                .frame(height: 40)
                .font(.title3)
                .contentShape(Rectangle())
                
                
                // after tapping the all events row all events are either selected or deselected
                .onTapGesture {
                    if selectAllOptions {
                        selectedOptions = []
                    } else {
                        selectedOptions = Set(EventCategory.allCases)
                    }
                }
                
                //MARK: all selectable categories
                ForEach(EventCategory.allCases) { option in
                    HStack{
                        Image(systemName: option.symbolName)
                            .frame(width: 40)
                            .foregroundStyle(k.brnoColor)
                        Text(option.rawValue)
                        Spacer()
                        Image(systemName: selectedOptions.contains(option) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedOptions.contains(option) ? k.brnoColor : .gray)
                    }
                    .frame(height: 40)
                    .font(.title3)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            if selectedOptions.contains(option) {
                                selectedOptions.remove(option)
                            } else {
                                selectedOptions.insert(option)
                            }
                        }
                    }
                }
            }
            
            //MARK: toolbar item
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss", systemImage: "xmark.circle.fill") {
                        dismiss()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundStyle(k.brnoColor)
                    .font(.title2)
                }
            }
            .navigationTitle("Zvolte typ akce")
        }
    }
}
#Preview {
    @Previewable @State var selectedOptions: Set<EventCategory> = Set(EventCategory.allCases)
    EventFilterOptionsView(selectedOptions: $selectedOptions)
}
