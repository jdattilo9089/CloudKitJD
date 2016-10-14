//
//  TableViewTableViewController.swift
//  CloudKitJD
//
//  Created by student3 on 10/7/16.
//  Copyright © 2016 John Hersey High School. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    var name = String()
    var students = [CKRecord]()
    var refresh:UIRefreshControl!
    let publicData = CKContainer.defaultContainer().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load students")
        refresh.addTarget(self, action: #selector(ViewController.loadData), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    func loadData(){
        students = [CKRecord]()
        let publicData = CKContainer.defaultContainer().publicCloudDatabase

        let query = CKQuery(recordType: "Student", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        publicData.performQuery(query, inZoneWithID: nil) { (results:[CKRecord]?, NSError) in
            if let students = results{
                self.students = students
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                })
                
            }
        }
        
        
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            
            return cell
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return students.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if students.count == 0 {
            return cell
        }
        
        let student = students[indexPath.row]
        
        if let studentContent = student["content"] as? String {
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormat.stringFromDate(student.creationDate!)
            
            cell.textLabel?.text = studentContent
            cell.detailTextLabel?.text = dateString
        }
        
        return cell
    }
    @IBAction func addStudentButton(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add a Student", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler{(textField:UITextField) -> Void in
            textField.placeholder = "Enter Student"
        }
        alert.addAction(UIAlertAction(title: "Send", style: .Default, handler: {(action:UIAlertAction) -> Void in
            let textField = alert.textFields!.first!
            self.name = textField.text!
            if textField.text != ""{
                let newStudent = CKRecord(recordType: "Student")
                newStudent["content"] = textField.text
                
                let publicData = CKContainer.defaultContainer().publicCloudDatabase
                publicData.saveRecord(newStudent, completionHandler: {(record:CKRecord?, error:NSError?)-> Void in
                    if error == nil{
                        self.tableView.beginUpdates()
                        self.students.insert(newStudent, atIndex: 0)
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                        self.tableView.endUpdates()
                        print("Student Saved")
                    }
                } )
            }
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    
    //
    //       override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    //        // Return false if you do not want the specified item to be editable.
    //        return true
    //}
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


