//
//  ContentView.swift
//  HotProspects
//
//  Created by Ping Yun on 10/11/20.
//

import SwiftUI

struct ContentView: View {
    //creates and stores single instance of Prospects class
    var prospects = Prospects()
    
    var body: some View {
        //tab view with three instances of ProspectsView and one MeView
        TabView {
            //ProspectsView for people user has met
            ProspectsView(filter: .none)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Everyone")
                }
            //ProspectsView for people user has contacted
            ProspectsView(filter: .contacted)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Contacted")
                }
            //ProspectsView for people user has not contacted
            ProspectsView(filter: .uncontacted)
                .tabItem {
                    Image(systemName: "questionmark.diamond")
                    Text("Uncontacted")
                }
            //MeView for information about user to be scanned
            MeView()
                .tabItem {
                    Image(systemName: "person.crop.square")
                    Text("Me")
                }
        }
        //adds prospects property to TabView so ProspectsView instances will get it 
        .environmentObject(prospects)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
