//
//  FormViewController.swift
//  easydesu
//
//  Created by Kudo Takuya on 2017/03/19.
//  Copyright © 2017年 Kudo Takuya. All rights reserved.
//

import UIKit


class FormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mypicker: UIPickerView!
    @IBOutlet weak var commentField: UITextField!

     var categoryArr: NSArray = ["住所","メニュー","写真","コメント"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mypicker.delegate = self
        mypicker.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArr.count
    }
    
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArr[row] as? String
    }
    
    //選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("列: \(row)")
        print("値: \(categoryArr[row])")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
  


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButton(_ sender: Any) {
        // create the url-request
        print(nameField.text!)
        let urlString = "https://sheets.googleapis.com/v4/spreadsheets/1twaJJZaNuKZKTuoPhWJb1MvcPHbAVUmwrSl_5R8I00I:batchUpdate"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        
        // set the method(HTTP-POST)
        request.httpMethod = "POST"
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ya29.GlwUBKbBcnfUWUidpkJaSN_S0RdlJ04CFrpGk6-qKCm_LsT44wUNVHZ8A-dFEJNLeF6lefmPgm9PgzBYWBxBCT6g0bY9vmCOcE80P6Ls2eXzbHhVxKJKEQDfF5IIjg", forHTTPHeaderField: "Authorization")
        
        // set the request-body(JSON)
        let params: [String: Dictionary] = [
            "requests":[
                "updateCells":[
                    "start":[
                        "sheetId": 0,
                        "rowIndex": 45,
                        "columnIndex": 1
                        ],
                    "rows":[
                        "values":[
                            "userEnteredValue":[
                                "stringValue": "\(nameField.text!)"
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
