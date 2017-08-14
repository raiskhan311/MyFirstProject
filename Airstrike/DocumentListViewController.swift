//
//  DocumentListViewController.swift
//  Airstrike
//
//  Created by APPLE on 02/05/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit
import Foundation

class DocumentListViewController: UIViewController, UITableViewDataSource,UITabBarDelegate,NSURLConnectionDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        get_data_from_url()
        getFromJson()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_UploadDocument(_ sender: Any) {
        let url = URL(string: "http://35.164.49.74/api/document_upload.php")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }

    @IBOutlet weak var tbl_TableView: UITableView!
    
    @IBAction func btn_CloseDocumentList(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func getFromJson(){
        let url = NSURL(string: "http://35.164.49.74/api/document_upload.php")
        let request = NSMutableURLRequest(url: url! as URL)
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            guard error == nil && data != nil else
            {
                print("Error:", error as Any)
                return
            }
            let httpStatus = response as? HTTPURLResponse
            if httpStatus?.statusCode == 200
            {
              if data?.count != 0
              {
                let responseString = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                let time = responseString["current_time"]
                print(String(describing:time))
                let posts = responseString["post"] as? [AnyObject]
                for post in posts!
                {
                    let text = post["text"]as! String
                    print(text)
                    DispatchQueue.main.async {
                        //table.reload
                        //label.text ...etc
                    }
                }
                }
                else
              {
                print("No data got from url!")
                }
            }
            else{
                print("error httpStatus code is: ",httpStatus?.statusCode as Any)
            }
        }
        task.resume()
    }
    
    // Mark: - TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    var id:[String] = []
    var league_id:[String] = []
    var document_name:[String] = []
    var created_date:[String] = []
 /*
    //create function
    
    func get_data_from_url(){
    
        let requestURL: NSURL = NSURL(string: "http://35.164.49.74/api/document_list.php")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
            }
        }
        task.resume()
    }   */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
