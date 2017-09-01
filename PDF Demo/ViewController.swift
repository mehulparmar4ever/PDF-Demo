//
//  ViewController.swift
//  PDF Demo
//
//  Created by Mehul on 01/09/17.
//  Copyright © 2017 classroom. All rights reserved.
//

import UIKit
import Alamofire
import UXMPDFKit

private let CellIdentifier =  "TableViewCell"

class ViewController: UIViewController {

    var arrPdf = NSArray()
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Get Url of PDF files
        Alamofire.request("http://27.109.20.118/SilverPixelz/api/pdf_repositories").responseJSON { response in
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result

            if let json = response.result.value {
                self.arrPdf = json as! NSArray
//                print("JSON: \(self.arrPdf)") // serialized json response
                self.tableview.reloadData()
            }
    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func btnDownloadClicked(_ sender: UIButton) {
        let intTag = sender.tag
        let indexPath = IndexPath(row: intTag, section: 0)

        let arrdata = self.arrPdf[indexPath.row]

        let document = (arrdata as AnyObject).value(forKey: "document_upload") as! String
        var pdfFileName = (arrdata as AnyObject).value(forKey: "pdf_name") as! String
        let pdfPathExtension = URL(fileURLWithPath: document).pathExtension
        pdfFileName = pdfFileName + "." + pdfPathExtension
        print("pdfFileName \(pdfFileName)")

        // Final PDF url
        let strUrlPDF = "http://www.silvergiftz.com/pdf/" + document
        print("Server file URL \(strUrlPDF)")
        
        self.startDownload(strFileUrl: strUrlPDF, strFileName: pdfFileName)
    }
    
    func startDownload(strFileUrl: String, strFileName : String) {
        if self.checkFile_Downloaded_Or_not(strFileName : strFileName) {
            self.showFileWithPath(self.destinationURLForFile(strFileName: strFileName))
        }
        else {
            self.DownloadFile(strFileUrl: strFileUrl, strFileName: strFileName, success: { (strResultPath) in
                self.showFileWithPath(self.destinationURLForFile(strFileName: strFileName))
            }, failure: { (error) in
                print(error.debugDescription)
            })
        }
    }

    func destinationURLForFile(strFileName : String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath + "/\(strFileName)")
        return destinationURLForFile.path
    }

    func showFileWithPath(_ path: String){
        let isFileFound:Bool? = FileManager.default.fileExists(atPath: path)
        if isFileFound == true {
            print("path : \(path)")
            
            let document = try! PDFDocument(filePath: path, password: "")
            let pdf = PDFViewController(document: document)
            self.navigationController?.pushViewController(pdf, animated: true)
        }
        else {
            print("isFileFound NO")
        }
    }

    func checkFile_Downloaded_Or_not(strFileName: String) -> Bool {
        
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: self.destinationURLForFile(strFileName: strFileName)){
            return true
        }
        else{
            return false
        }
    }

    // Mark:- Download File
    func DownloadFile(strFileUrl : String, strFileName : String, success:@escaping (_ strResultURL: String) -> Void , failure:@escaping (_ responseObject:AnyObject) -> Void) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(strFileName)")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(strFileUrl, to: destination).response { response in
            
//            if SVProgressHUD.isVisible() {
                if UIApplication.shared.isIgnoringInteractionEvents {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
//                SVProgressHUD.dismiss()
//            }
            
            if response.error == nil {
                success("\(response.destinationURL!)")
            }
            else {
                failure(response.error as AnyObject)
            }
            }.downloadProgress { (progress) in
                print("Download Progress: \(progress.fractionCompleted)")
                if !UIApplication.shared.isIgnoringInteractionEvents {
                    UIApplication.shared.beginIgnoringInteractionEvents()
                }
//                SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: AppAlertMsg.KDownloadingFiles)
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return self.animals.count
        return self.arrPdf.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:TableViewCell = self.tableview.dequeueReusableCell(withIdentifier: CellIdentifier) as! TableViewCell!
        cell.btnDownload.tag = indexPath.row
        cell.btnDownload.addTarget(self, action: #selector(ViewController.btnDownloadClicked(_:)), for: UIControlEvents.touchUpInside)
        
        let arrdata = self.arrPdf[indexPath.row]
        let strPDFName = (arrdata as AnyObject).value(forKey: "pdf_name") as! String
        cell.lblPDFName.text = strPDFName
        
        return cell
    }

}
