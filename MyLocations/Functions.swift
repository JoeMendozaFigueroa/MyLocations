//
//  Functions.swift
//  MyLocations
//
//  Created by Josue Mendoza on 9/17/21.
//

import Foundation
//*/ This is considered a free method. It is not part of any class and so it can be used anywhere in the scope of the App
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

let applicatonDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory,
                                         in: .userDomainMask)
    return paths[0]
}()
let dataSaveFailedNotification = Notification.Name(
    rawValue: "DataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(
        name: dataSaveFailedNotification,
        object: nil)
}
