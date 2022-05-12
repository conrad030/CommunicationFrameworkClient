//
//  FileWrapper.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 09.05.22.
//

import Foundation

struct FileHolder {
    
    private(set) var id: UUID
    private(set) var type: FileType
    private(set) var name: String
    var file: FileRepresentable?
    
    init(id: String, fileType: FileType, name: String) {
        self.id = UUID(uuidString: id) ?? UUID()
        self.type = fileType
        self.name = name
    }
    
    init(file: FileRepresentable) {
        self.id = UUID()
        self.type = file.fileType
        self.file = file
        self.name = file.name
    }
}
