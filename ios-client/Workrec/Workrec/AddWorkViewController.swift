//
//  AddWorkViewController.swift
//  Workrec
//
//  Created by ishida on 2018/12/04.
//  Copyright © 2018 ishida. All rights reserved.
//

import UIKit
import WorkrecSDK

class AddWorkViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onAddButton(_ sender: Any) {
        let title = self.titleTextField.text ?? ""
        print("TITLE: \(title)")
        _ = API.addWork(title: title).subscribe {
            print("SUB: \($0)")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
