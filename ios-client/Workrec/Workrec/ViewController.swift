//
//  ViewController.swift
//  Workrec
//
//  Created by ishida on 2018/12/02.
//  Copyright © 2018 ishida. All rights reserved.
//

import UIKit
import WorkrecSDK
import RxSwift

class ViewController: UIViewController {
    var works = [WorkListItem]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       self.reloadData()
    }
    
    func reloadData() {
        _ = API.getWorkList()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.works = $0.works
                self.tableView.reloadData()
            })
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.works.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let work = works[indexPath.row]
        cell.textLabel?.text = work.title
        cell.detailTextLabel?.text = work.id
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .destructive, title: "削除", handler: { (_, indexPath) -> Void in
            _ = API.deleteWork(workId: self.works[indexPath.row].id).subscribe {
                self.reloadData()
            }
        })]
    }
}
