//
//  Snackbar.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 26.05.22.
//

import MaterialComponents.MaterialSnackbar

class Snackbar {
    static func showMessageAlert(name: String) {
        let message = MDCSnackbarMessage()
        message.text = String(format: name)
        MDCSnackbarManager.show(message)
    }
}
