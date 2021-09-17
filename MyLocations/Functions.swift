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
