//
//  DiagnoseApp.swift
//  Diagnose
//
//  Created by Foundation 3 on 05/03/26.
//

import SwiftUI
import GoogleSignIn

@main
struct DiagnoseApp: App {
    var body: some Scene {
        WindowGroup {
            RoleSelectionRootView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
