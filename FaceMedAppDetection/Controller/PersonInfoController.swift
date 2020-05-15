//
//  PersonInfoController.swift
//  FaceMedAppDetection
//
//  Created by Pavel Murzinov on 13.05.2020.
//  Copyright © 2020 Pavel Murzinov. All rights reserved.
//

import UIKit

class PersonInfoController: UITableViewController {
    
    var data: [String]!
    var avatar: UIImage! = #imageLiteral(resourceName: "Bender")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurationController()
        settingUI()
    }
    
    private func settingUI() {
        tableView.backgroundColor = #colorLiteral(red: 0.6640487313, green: 0.9201837182, blue: 0.9324166179, alpha: 1)
    }
    
    private func configurationController() {
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "LabelViewCell", bundle: nil), forCellReuseIdentifier: "LabelViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelViewCell", for: indexPath) as? LabelViewCell else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        
        if index == 0 {
            cell.type = .Head
            cell.setData(data[index], avatar)
        } else if index == data.count - 1 {
            cell.type = .Tail
            cell.setData(data[index])
        } else {
            cell.type = .Middle
            cell.setData(data[index])
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
