//
//  FormViewController.swift
//  easydesu
//
//  Created by Kudo Takuya on 2017/03/19.
//  Copyright © 2017年 Kudo Takuya. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMOAuth2


class FormViewController: UIViewController {
    
    private let kKeychainItemName = "Google Sheets API"
    private let kClientID = "257780597942-94ebcpvamei8jvq65kks18a3fa24613f.apps.googleusercontent.com"
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    
    private let service = GTLRSheetsService()
    let output = UITextView()



    override func viewDidLoad() {
        super.viewDidLoad()

        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        view.addSubview(output);
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(
            forName: kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
        // Do any additional setup after loading the view.
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if let authorizer = service.authorizer,
//            let canAuth = authorizer.canAuthorize, canAuth {
//            listMajors()
//        } else {
//            present(
//                createAuthController(),
//                animated: true,
//                completion: nil
//            )
//        }
//    }

    func listMajors() {
        output.text = "Getting sheet data..."
        let spreadsheetId = "1twaJJZaNuKZKTuoPhWJb1MvcPHbAVUmwrSl_5R8I00I"
        let range = "Class Data!A2:E"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: "displayResultWithTicket:finishedWithObject:error:"
        )
    }
    
    // Process the response and display output
    func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var majorsString = ""
        let rows = result.values!
        
        if rows.isEmpty {
            output.text = "No data found."
            return
        }
        
        majorsString += "Name, Major:\n"
        for row in rows {
            let name = row[0]
            let major = row[4]
            
            majorsString += "\(name), \(major)\n"
        }
        
        output.text = majorsString
    }
    
    
    
    // Creates the auth controller for authorizing access to Google Sheets API
//    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
//        let scopeString = scopes.joined(separator: " ")
//        return GTMOAuth2ViewControllerTouch(
//            scope: scopeString,
//            clientID: kClientID,
//            clientSecret: nil,
//            keychainItemName: kKeychainItemName,
//            delegate: self,
//            finishedSelector: "viewController:finishedWithAuth:error:"
//        )
//    }
//    
    // Handle completion of the authorization process, and update the Google Sheets API
    // with the new credentials.
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismiss(animated: true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButton(_ sender: Any) {
        // create the url-request
        let urlString = "https://sheets.googleapis.com/v4/spreadsheets/1twaJJZaNuKZKTuoPhWJb1MvcPHbAVUmwrSl_5R8I00I:batchUpdate"
        var request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        
        // set the method(HTTP-POST)
        request.httpMethod = "POST"
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // set the request-body(JSON)
        var params: [String: Dictionary] = [
            "requests":[
                "updateCells":[
                    "start":[
                        "sheetId": 0,
                        "rowIndex": 2,
                        "columnIndex": 1
                        ],
                    "rows":[
                        "values":[
                            "userEnteredValue":[
                                "stringValue": "国語"
                                ]
                            ]
                        ],
                    "fields": "userEnteredValue"
                    ]
                ]
            ]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
        }catch let error{
            // エラー処理
            print(error)
        }
        // use NSURLSessionDataTask
        var task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            if (error == nil) {
                var result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                print(result)
            } else {
                print(error)
            }
        })
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
