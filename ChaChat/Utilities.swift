//
//  Utilities.swift
//  ChaChat
//
//  Created by Sandeep Gautam on 03/05/2021.
//

import Foundation
import UIKit

class Utilities {
    
    
    func showAlert (title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(alertAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func getDate () -> String {
        let today: Date = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.string(from: today)
    }
}
