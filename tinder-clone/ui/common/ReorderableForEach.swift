//
//  ReorderableForEach.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 12/1/22.
//
import UniformTypeIdentifiers
import SwiftUI

struct ReorderableForEach<Content: View, Item: Identifiable & Equatable & Draggable>: View {
    let items: [Item]
    let content: (Item) -> Content
    let moveAction: (IndexSet, Int) -> Void
    
    // A little hack that is needed in order to make view back opaque
    // if the drag and drop hasn't ever changed the position
    // Without this hack the item remains semi-transparent
    @State private var hasChangedLocation: Bool = false

    init(
        droppedOutside: Binding<Bool>,
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        moveAction: @escaping (IndexSet, Int) -> Void
    ) {
        self.items = items
        self._droppedOutside = droppedOutside
        self.content = content
        self.moveAction = moveAction
    }
    
    @State private var draggingItem: Item?
    @Binding var droppedOutside: Bool
    
    var body: some View {
        ForEach(items) { item in
            content(item)
                //.overlay(draggingItem == item && hasChangedLocation ? Color.white.opacity(0.8) : Color.clear)
                .onOptionalDrag(item.isDraggable, {
                    draggingItem = item
                    return NSItemProvider(object: "\(item.id)" as NSString)
                })
                .onOptionalDrop(item.isDraggable,
                    of: [UTType.text],
                    delegate: DragRelocateDelegate(
                        item: item,
                        listData: items,
                        current: $draggingItem,
                        hasChangedLocation: $hasChangedLocation
                    ) { from, to in
                        withAnimation {
                            moveAction(from, to)
                        }
                    }
                )
        }
        .onChange(of: droppedOutside, perform: { newValue in
            if(newValue){
                draggingItem = nil
                droppedOutside = false
            }
        })
    }
}

extension View{
    @ViewBuilder
    public func onOptionalDrag(_ value: Bool,_ data: @escaping () -> NSItemProvider) -> some View{
        if(value){
            self.onDrag(data)
        } else{
            self
        }
    }
    
    @ViewBuilder
    public func onOptionalDrop(_ value: Bool, of supportedContentTypes: [UTType], delegate: DropDelegate) -> some View{
        if(value){
            self.onDrop(of: supportedContentTypes, delegate: delegate)
        } else{
            self
        }
    }
}
