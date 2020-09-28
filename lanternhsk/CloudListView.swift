//
//  CloudVocabList.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 3/25/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

extension View {
    func conditional(closure: (Self) -> AnyView) -> AnyView {
        return closure(self)
    }
}


struct CloudListView: View {
    var request : NSFetchRequest<CloudListEntity> =  CloudListEntity.fetchRequest()
    @State var lists: [CloudListEntity] = []
    
    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
    
    @State private var isShowingAlert = false
    @State private var trigger: Bool = false
    @State private var alertInput = ""
    
    init() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CloudListEntity.objectID, ascending: true)]
        
        let lists = try! context.fetch(request)
        self._lists = State(initialValue: lists)
    }
    
    #if os(iOS)

    private func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .compactMap {$0 as? UIWindowScene}
            .first?.windows.filter {$0.isKeyWindow}.first
    }
    
    private func topMostViewController() -> UIViewController? {
        guard let rootController = keyWindow()?.rootViewController else {
            return nil
        }
        return topMostViewController(for: rootController)
    }
    
    private func topMostViewController(for controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return topMostViewController(for: presentedController)
        } else if let navigationController = controller as? UINavigationController {
            guard let topController = navigationController.topViewController else {
                return navigationController
            }
            return topMostViewController(for: topController)
        } else if let tabController = controller as? UITabBarController {
            guard let topController = tabController.selectedViewController else {
                return tabController
            }
            return topMostViewController(for: topController)
        }
        return controller
    }
    
    private func alert() {
        let alert = UIAlertController(title: "Enter Name", message: "...or pseudo", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter something"
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            let textField = alert.textFields![0] as UITextField
            alertInput = textField.text ?? "Name"
            
            let context = CoreDataStack.shared.persistentContainer.viewContext

            let list1 = CloudListEntity(context: context)
            list1.id = UUID()
            list1.name = alertInput
            list1.wordCount = 0
            
            try! context.save()
            
            self.reload()
            
            print("Name \(alertInput)")
            
        })
        let textField = alert.textFields![0] as UITextField
        alertInput = textField.text ?? "Name"
        showAlert(alert: alert)
    }
    
    func showAlert(alert: UIAlertController) {
        if let controller = topMostViewController() {
            controller.present(alert, animated: true)
        }
    }
    #endif
    
    func buildItem(_ list:CloudListEntity) -> some View {
        let view = LazyView(CloudSectionView(list))
        
        return NavigationLink(destination: view) {
            VStack(alignment: .leading) {
                Text((list as CloudListEntity).name!).font(.headline)
                Text("Words: " + String((list as CloudListEntity).wordCount)).font(.subheadline)
            }.padding()
        }
    }
    
    func reload() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        self.lists = try! context.fetch(self.request)
        self.trigger.toggle()
    }
    
    var body: some View {
        print("build \(trigger)")
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        var content: AnyView
        
        if lists.count == 0 {
            content = AnyView(Text("No lists")
                                .multilineTextAlignment(.center))
            
        } else {
            content = AnyView(List {
                ForEach(lists, id: \.id)  { list in
                    self.buildItem(list)
                    
                }
                .onDelete { offsets in
                    for index in offsets {
                        context.delete(self.lists[index])
                        self.lists.remove(at: index)
                    }
                    try! context.save()
                }
                
            }.onReceive(self.didSave) { _ in
                self.reload()
                
            }.onAppear(perform: {
                self.reload()
            })
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        #if os(iOS)
                        self.alert()
                        #endif
                        
                        withAnimation {
                            self.isShowingAlert.toggle()
                        }
                    }, label: {
                        Text("Add")
                    })
                }
            })
            
        }
        
        return content
    }
    
}

