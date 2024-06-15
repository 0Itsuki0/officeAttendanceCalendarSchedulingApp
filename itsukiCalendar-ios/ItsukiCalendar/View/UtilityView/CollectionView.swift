//
//  LazyVGridDemo.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/04/20.
//

import SwiftUI

struct CollectionView: View {
    var items: [EventRecord]
    var selectedItemIndex: Int?
    var containerWidth: CGFloat
    var mainColor: Color
    
    var horizontalSpacing: CGFloat = 16
    var verticalSpacing: CGFloat = 16
    var imageSize: CGSize = CGSize(width: 12, height: 12)
    
    var horizontalPadding: CGFloat = 16
    var font: UIFont = UIFont.systemFont(ofSize: 18)
    
    var body: some View {
        let (itemsArranged, selectedItemRowCol) = arrangeItems(items, containerWidth: containerWidth, font: font, horizontalSpacing: horizontalSpacing, horizontalPadding: horizontalPadding)
        
        LazyVStack(alignment: .leading, spacing: verticalSpacing) {
            
            ForEach(0..<itemsArranged.count, id: \.self) { row in
                
                let itemsInRow = itemsArranged[row]
                
                HStack(spacing: horizontalSpacing) {
                    ForEach(0..<itemsInRow.count, id: \.self) { column in
                        let colorReversed = (row == selectedItemRowCol?.0 && column == selectedItemRowCol?.1)
                        let imageName = (itemsInRow[column].status == .went ? "checkmark" : "questionmark")
                        
                        RoundBorderText(
                            text: itemsInRow[column].userName,
                            font: Font(font),
                            horizontalPadding: horizontalPadding,
                            mainColor: mainColor,
                            colorReversed: colorReversed,
                            trailingImage: Image(systemName: imageName),
                            imageSize: imageSize
                        )
         
                    }

                }
                
            }

        }
        .scrollTargetLayout()

    }
    
    
    func arrangeItems(_ items: [EventRecord], containerWidth: CGFloat, font: UIFont, horizontalSpacing: CGFloat, horizontalPadding: CGFloat) -> ([[EventRecord]], (Int, Int)?) {
        
        var arrangeItems: [[EventRecord]] = []
        var selectedItemRowCol: (Int, Int)? = nil
        
        var currentRowWidth: CGFloat = 0
        
        for i in 0..<items.count {
            let item = items[i]
            let itemWidth = item.userName.width(font: font) + horizontalPadding * 2 + imageSize.width
            
            // first item
            if i == 0 {
                arrangeItems.append([item])
                currentRowWidth = itemWidth
                if i == selectedItemIndex {
                    selectedItemRowCol = (0, 0)
                }
                continue
            }
            
            if currentRowWidth + horizontalSpacing + itemWidth > containerWidth {
                // start new row
                arrangeItems.append([item])
                currentRowWidth = itemWidth
            } else {
                // add to current row
                arrangeItems[arrangeItems.count - 1].append(item)
                currentRowWidth = currentRowWidth + horizontalSpacing + itemWidth
            }
            
            if i == selectedItemIndex {
                selectedItemRowCol = (arrangeItems.count - 1, arrangeItems[arrangeItems.count - 1].count - 1)
            }

        }

        return (arrangeItems, selectedItemRowCol)
    }
}


#Preview {
    let events: [EventRecord] = Array(1..<10).map({EventRecord(id: "\($0)", location: .tokyo, status: $0%2 == 0 ? .going : .went, timestamp: "\($0)", userId: "\($0)", userName: "\($0) \($0%3 == 0 ? "long-----------long" : "")")})
    
    return CollectionView(items: events,selectedItemIndex: 4, containerWidth: 300, mainColor: .red)
        .padding(.all, 20)
        .background(Color(UIColor.lightGray))
        .padding(.all, 20)
}
