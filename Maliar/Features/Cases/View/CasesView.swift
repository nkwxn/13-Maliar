//
//  CasesView.swift
//  Maliar
//
//  Created by Nicholas on 28/07/21.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct CasesView: View {
    @StateObject var viewModel = CasesViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 24) {
                Text("Cases")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                Spacer()
                DateSelectorView(startDate: $viewModel.filterStartDate, endDate: $viewModel.filterEndDate)
                    .onChange(of: viewModel.filterStartDate) { value in
                        viewModel.dateFilter()
                    }
                    .onChange(of: viewModel.filterEndDate) { value in
                        viewModel.dateFilter()
                    }
                RetrieveDataButton {
                    // TODO: Input action to retreive new data
                }
            }
            GroupBox {
                if isLoading{
                    VStack(alignment: .trailing){
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .accentColor)).scaleEffect(2)
                    }
                    .frame(
                          minWidth: 0,
                          maxWidth: .infinity,
                          minHeight: 0,
                          maxHeight: .infinity,
                          alignment: .center
                        )
                   
                }
                else {
                    VStack(alignment: .leading) {
                        VStack {
                            Text("\(viewModel.filtered.count)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("Total Cases")
                        }
                        .padding()
                        
                        // Start of the Data Table
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVGrid(columns: viewModel.gridItem, alignment: .center, spacing: 0) {
                                // Header in the first place
                                TableHeaderView(TableHeader.number)
                                TableHeaderView(TableHeader.rowDate)
                                TableHeaderView(TableHeader.newsTitle)
                                TableHeaderView(TableHeader.animalName)
                                TableHeaderView(TableHeader.numOfAnimal)
                                TableHeaderView(TableHeader.province)
                                TableHeaderView(TableHeader.district)
                                TableHeaderView(TableHeader.caseTime)
                                TableHeaderView(TableHeader.link)
                                
                                // Show the Data
                                ForEach(Array(viewModel.filtered.enumerated()), id: \.0) { index, data in
                                    TableCellView(text: "\(index + 1)")
                                    TableCellView(text: .constant(data.getFormattedDate(date: data.newsTime)), isEditing: $viewModel.isTableEditing)
                                    TableCellView(text: $viewModel.filtered[index].newsTitle, isEditing: $viewModel.isTableEditing)
                                    TableCellView(text: $viewModel.filtered[index].animalName, isEditing: $viewModel.isTableEditing)
                                    TableCellView(text: $viewModel.filtered[index].numberOfAnimal, isEditing: $viewModel.isTableEditing)
                                    TableCellView(text: $viewModel.filtered[index].province, isEditing: $viewModel.isTableEditing)
                                    TableCellView(text: $viewModel.filtered[index].district, isEditing: $viewModel.isTableEditing)
                                    TableCellView(text: .constant(data.getFormattedDate(date: data.newsTime)), isEditing: $viewModel.isTableEditing)
                                    TableCellView(text: $viewModel.filtered[index].link, isEditing: $viewModel.isTableEditing)
                                }
                            }
                        }
                    }
                }
                
            }
            .background(colorScheme == .light ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .cornerRadius(10)
        }
        .navigationTitle("Cases")
        .padding(.horizontal, 24.0)
        .padding(.vertical, 27.0)
        .toolbar {
            // The header toolbar content
            Menu {
                Button("None") {
                    // "Action when none clicked"
                    viewModel.dateFilter()
                }
                Divider()
                Button("Date Added") {
                    viewModel.sortTable(.rowDate)
                }
                Button("Case Time") {
                    viewModel.sortTable(.caseTime)
                }
                Button("Number of Animal") {
                    viewModel.sortTable(.numOfAnimal)
                }
            } label: {
                Image(systemName: "line.horizontal.3.decrease.circle")
            }
            .help("Sort Table")
            
            // Edit button
            Button {
                print("Edit button pressed")
                
                viewModel.editTable()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .help("Edit Data")
            
            // Download and Share Button
            DownloadShareButtonView(textItem: $viewModel.csvContent)
            
            // Search bar
            TextField("Search", text: $viewModel.searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 200)
                .onChange(of: viewModel.searchQuery) { value in
                    viewModel.searchOnTable(keyword: value)
                }
        }
        .onAppear {
            APIRequest.fetchNewsCase { (result) in
                isLoading.toggle()
                viewModel.fullData = result
                viewModel.dateFilter()
            }
        }
    }
}

struct CasesView_Previews: PreviewProvider {
    static var previews: some View {
        CasesView()
            .preferredColorScheme(.light)
        CasesView()
            .preferredColorScheme(.dark)
    }
}
