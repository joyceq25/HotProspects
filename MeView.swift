//
//  MeView.swift
//  HotProspects
//
//  Created by Ping Yun on 10/11/20.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    //stores user's name
    @State private var name = "Anonymous"
    //stores user's email address
    @State private var emailAddress = "you@yoursite.com"
    
    //stores active Core Image context
    let context = CIContext()
    //stores instance of Core Image's QR code generator filter
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView {
            VStack {
                //text field for name
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(.title)
                    .padding(.horizontal)
                
                //text field for email address
                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress)
                    .font(.title)
                    .padding([.horizontal, .bottom])
                
                //passes in name and email address to generateQRCode(from:), displays QR code
                Image(uiImage: generateQRCode(from: "\(name)\n(emailAddress)"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Spacer()
            }
            .navigationBarTitle("Your code")
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        //converts input string to data
        let data = Data(string.utf8)
        //uses data as input for filter
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            //converts output CIImage to CGImage
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                //converts CGImage to UIImage and returns it
                return UIImage(cgImage: cgimg)
            }
        }
        
        //if conversion fails, sends back xmark.circle, if that can't be read sends back empty UIImage
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
