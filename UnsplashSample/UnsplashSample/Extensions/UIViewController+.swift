//
//  UIViewController+.swift
//  UnsplashSample
//
//  Created by Gilwan Ryu on 2020/06/26.
//  Copyright © 2020 GilwanRyu. All rights reserved.
//

import UIKit

extension UIViewController {
    func showError(message: String, doneHandler: ((UIAlertAction) -> Void)?, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "done", style: .default, handler: doneHandler)
        alert.addAction(done)
        self.present(alert, animated: true, completion: completion)
    }
}
