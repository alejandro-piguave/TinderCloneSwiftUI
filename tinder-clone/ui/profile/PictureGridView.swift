//
//  PictureGridView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 4/1/22.
//

import SwiftUI

protocol Draggable{
    var isDraggable: Bool { get }
}

struct ImageWrapper: Draggable, Identifiable, Equatable{
    var isDraggable: Bool
    var id: UUID
    let image: UIImage?
    init(_ image: UIImage? = nil){
        self.image = image
        isDraggable = image != nil
        id = UUID()
    }
}

struct PictureGridView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @Binding var pictures: [UIImage]
    @Binding var picturesChanged: Bool
    @Binding var droppedOutside: Bool
    @State var imageWrapper: [ImageWrapper] = (0...8).map{  _ in ImageWrapper()}

    let onAddedImageClick: (Int) -> ()
    let onAddImageClick: () -> ()
    
    init( pictures: Binding< [UIImage] >,  picturesChanged: Binding<Bool> = .constant(false), droppedOutside: Binding<Bool> = .constant(false), onAddedImageClick: @escaping (Int) -> () = {value in}, onAddImageClick: @escaping () -> () = {}){
        self._pictures = pictures
        self._picturesChanged = picturesChanged
        self._droppedOutside = droppedOutside
        self.onAddImageClick = onAddImageClick
        self.onAddedImageClick = onAddedImageClick
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ReorderableForEach(droppedOutside: $droppedOutside, items: imageWrapper) { item in
                if let image = item.image, let index = pictures.firstIndex(of: image){
                    AddedImageView(image: image, action:{
                        onAddedImageClick(index)
                    })
                } else {
                    AddImageView(action: onAddImageClick)
                }
            } moveAction: { from, to in
                picturesChanged = true
                imageWrapper.move(fromOffsets: from, toOffset: to)
            }
        }
        .onChange(of: pictures, perform: { newValue in
            imageWrapper = (0...8).map{ ImageWrapper( $0 < newValue.count ? newValue[$0] :  nil)  }
        })
    }
}

struct PictureGridView_Previews: PreviewProvider {
    static var previews: some View {
        PictureGridView(pictures: .constant([]), droppedOutside: .constant(false), onAddedImageClick: {index in}, onAddImageClick: {})
    }
}
