//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Ping Yun on 10/11/20.
//

import UserNotifications
import CodeScanner
import SwiftUI

struct ProspectsView: View {
    //enum and property to represent each ProspectsView
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
    //finds object from environment, attaches it to property, keeps it up to date over time
    @EnvironmentObject var prospects: Prospects
    
    //stores whether or not QR code scanner is showing
    @State private var isShowingScanner = false
    
    //computed property for navigation bar title of each ProspectsView
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    //computed property that returns array of all people, only contacted people, or only uncontacted people from prospects array
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    var body: some View {
        NavigationView {
            //list that loops over filteredProspects, shows title and email address for each prospect
            List {
                ForEach(filteredProspects) { prospect in
                    VStack(alignment: .leading) {
                        Text(prospect.name)
                            .font(.headline)
                        Text(prospect.emailAddress)
                            .foregroundColor(.secondary)
                    }
                    //context menu for users to switch people between tabs
                    .contextMenu {
                        //ternary operator for setting button's title so it looks correct no matter where it is used
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                            self.prospects.toggle(prospect)
                        }
                        
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
                .navigationBarTitle(title)
                .navigationBarItems(trailing: Button(action: {
                    self.isShowingScanner = true
                }) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                })
            .sheet(isPresented: $isShowingScanner) {
                //CodeScannerView that takes array of types of codes we want to scan, a string to use as simulated data, completion function to use
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson/npaul@hackingwithswift.com", completion: self.handleScan)
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let code):
            //pulls apart data from QR code into name and email, stores them in details
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            //uses components to create a new Prospect
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            
            //adds new Prospect to prospects and saves 
            self.prospects.add(person)
            
        //if scanning failed, prints error
        case .failure(let error):
            print("Scanning failed")
        }
    }
    
    //creates notification for current prospect
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            /*var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)*/
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        }
        
        //if notifications are allowed, adds notification with addRequest()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                //if not, requests permission to show notifications
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
