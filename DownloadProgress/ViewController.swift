//
//  ViewController.swift
//  DownloadProgress
//
//  Created by Sachin Dumal on 09/12/19.
//  Copyright © 2019 Sachin Dumal. All rights reserved.
//https://medium.com/swlh/tracking-download-progress-with-urlsessiondownloaddelegate-5174147009f

enum URLString: String {
    case urlOne = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Polarlicht_2.jpg/1920px-Polarlicht_2.jpg?1568971082971"
}

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.contentMode = .scaleAspectFill
    }

    @IBAction func startDownload(_ sender: Any) {
        if let imageURL = getURLFromString(URLString.urlOne.rawValue) {
            download(from: imageURL)
        }
}
    
    // MARK:- fetch image from url
    
   private func download(from url: URL) {
        let configuration  = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let session        = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        let downloadTask   = session.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
    // MARK:- prepare url from string
    
  private func getURLFromString(_ str: String) -> URL?{
        return URL(string: str)!
    }
}



//MARK:- Extension For DownloadTask

extension ViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentageDownloaded = totalBytesWritten / totalBytesExpectedToWrite
        // update the percentage label
        DispatchQueue.main.async {
            self.progressLabel.text = "\(percentageDownloaded * 100)%"
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
          // get downloaded data from location
          let data = readDownloadedData(of: location)
          
          // set image to imageView
          setImageToImageView(from: data)
      }
      
    
    // MARK:- read downloaded data
    
    private func readDownloadedData(of url: URL) -> Data? {
        do {
             let reader = try FileHandle(forReadingFrom: url)
            let data = reader.readDataToEndOfFile()
            return data
        } catch  {
            print(error)
            return nil
        }
    }
    
    // MARK:- get image from Data
    
    private func getUIImageFromData(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    // MARK:- set image to image view
    
    private func setImageToImageView(from data: Data?) {
        guard let imageData = data else { return}
        guard let image = getUIImageFromData(imageData) else { return}
        DispatchQueue.main.async {self.imageView.image = image}
    }
    
}
