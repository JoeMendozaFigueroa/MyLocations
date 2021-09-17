//
//  Functions.swift
//  MyLocations
//
//  Created by Josue Mendoza on 9/17/21.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
