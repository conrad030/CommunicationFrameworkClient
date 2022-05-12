//
//  PDFFile.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 09.05.22.
//

import SwiftUI
import UniformTypeIdentifiers

struct PDFFile: FileDocument, FileRepresentable {
    
    var data: Data {
        if let data = self.innerData {
            return data
        } else {
            guard url.startAccessingSecurityScopedResource() else { return Data() }
            defer { url.stopAccessingSecurityScopedResource() }
            return try! Data(contentsOf: self.url)
        }
    }
    var view: AnyView {
        AnyView(
            Text(self.name)
                .bold()
                .font(.system(size: 16))
                .lineLimit(2)
                .foregroundColor(.blue)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.white)
                )
                .clipped()
        )
    }
    
    var storedName: String?
    
    var name: String {
        get {
            self.storedName ?? self.url.lastPathComponent
        }
        set {
            self.storedName = newValue
        }
    }
    
    var fileType: FileType {
        .pdf
    }
    
    static var readableContentTypes: [UTType]{[.pdf]}
    
    private var innerData: Data?
    private var url: URL = URL(fileURLWithPath: "")
    
    init(data: Data) {
        self.innerData = data
    }
    
    init(url: URL) {
        self.url = url
    }
    
    init(configuration: ReadConfiguration) throws {
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try FileWrapper(url: self.url, options: .immediate)
    }
}
