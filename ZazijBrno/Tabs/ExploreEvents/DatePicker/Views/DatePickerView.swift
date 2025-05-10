//
//  DatePickerView.swift
//  ZazijBrno
//
//  Created by Tomáš Dušek on 21.04.2025.
//

import SwiftUI


// a simple date picker view that is used to pick a time period based on two dates

struct DatePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var dateFrom: Date
    @Binding var dateTo: Date
    
    @Binding var isDateFilterActive: Bool
    
    @State private var dateFromInternal: Date = Date()
    @State private var dateToInternal: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack{
                
                //MARK: headline
                HStack{
                    Text("Vyhledat akci v termínu")
                        .font(.title2)
                    Spacer()
                }

                Spacer()
                
                //MARK: datepicker dateFrom
                HStack{
                    DatePicker("Datum od", selection: $dateFromInternal, in: Date()..., displayedComponents: .date)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.bottom)
                
                //MARK: datepicker dateTo
                HStack{
                    DatePicker("Datum do", selection: $dateToInternal, in: Date()..., displayedComponents: .date)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 12))
                Spacer()
                
                //MARK: confirmation button
                //when the button is tapped, the Binding variables are set to chosen dates and filter is activated
                Button {
                    dateFrom = dateFromInternal
                    dateTo = dateToInternal
                    isDateFilterActive = true
                    dismiss()
                } label: {
                    Text("Potvrdit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 100, maxHeight: 45)
                        .background(Constants.brnoColor)
                        .cornerRadius(8)
                }
                Spacer()
            }
            
            .padding()
            
            
            // when the view is presented and the filter is active, it load the previously seleceted dates
            .onAppear(){
                if isDateFilterActive {
                    dateFromInternal = dateFrom
                    dateToInternal = dateTo
                }
            }
            
            // a simple check to make sure that the time interval is valid to prevent any collisions
            // the dateTo can never be before the dateFrom, the source of truth is always the user changed variable
            .onChange(of: dateFromInternal) {
                if dateToInternal < dateFromInternal {
                    dateToInternal = dateFromInternal
                }
            }
            .onChange(of: dateToInternal) {
                if dateFromInternal > dateToInternal {
                        dateFromInternal = dateToInternal
                }
            }
        
        
            
            //MARK: toolbar items
            .toolbar {
            
                // after the filter is activated an additional ToolbarItem is presented
                // this sets isDateFilterActive to false and effectively resets this view
                if isDateFilterActive {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Vymazat filtr") {
                            isDateFilterActive = false
                            dismiss()
                        }
                        .foregroundStyle(Constants.brnoColor)
                    }
                }
                
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss", systemImage: "xmark.circle.fill") {
                        dismiss()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .font(.title2)
                    .foregroundStyle(Constants.brnoColor)
                }
            }
        }
        
    }
}

#Preview {
    
    @Previewable @State var dateFrom: Date = Date()
    @Previewable @State var dateTo: Date = Date()
    @Previewable @State var isDateFilterActive: Bool = true
    
    DatePickerView(dateFrom: $dateFrom, dateTo: $dateTo, isDateFilterActive: $isDateFilterActive)
}
