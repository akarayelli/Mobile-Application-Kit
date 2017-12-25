//
//  SSLPinningViewController.swift
//  MobileAppKit
//
//  Created by Aykut Ersahin on 21.12.2017.
//  Copyright © 2017 MSN. All rights reserved.
//

//********** NOTE *********
//Script file doesn’t have execute permissions.
//That is, you can read and write the file, but you can’t execute it.
//chmod +x BuildScript.command

import Cocoa

class SSLPinningViewController: NSViewController {

    @IBOutlet weak var pinningURLTextField: NSTextField!
    @IBOutlet weak var resultTextField: NSTextField!
    @IBOutlet weak var parseButton: NSButton!
    
    @IBOutlet weak var certificateDownloadPathTextField: NSTextField!
    @IBOutlet weak var browseButton: NSButton!
    @IBOutlet weak var downloadButton: NSButton!
    
    @objc dynamic var isRunning = false
    var outputPipe:Pipe!
    var buildTask:Process!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    @IBAction func parseButtonAction(_ sender: NSButton) {
        
        resultTextField.stringValue = ""
    
        var arguments:[String] = []
        arguments.append(pinningURLTextField.stringValue)
            
        
        runScript(arguments, scriptName: "PinningScript")
    }
    
    @IBAction func downloadButtonAction(_ sender: NSButton) {
        
        var arguments:[String] = []
        arguments.append(pinningURLTextField.stringValue)
        arguments.append(certificateDownloadPathTextField.stringValue)
        runScript(arguments, scriptName: "CertDownloadScript")
        
    }
    
    
    @IBAction func browseButtonAction(_ sender: NSButton) {
        
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose directory to export certificate";
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles          = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        
        if (dialog.runModal() == .OK) {
            if let result = dialog.url {
                if (result.isFileURL) {
                    if FileManager.default.fileExists(atPath: result.path) {
                        certificateDownloadPathTextField.stringValue = result.path
                    }
                }
            }
        }
        else {
            return
        }
    }
    
    
    func runScript(_ arguments:[String]?, scriptName: String!) {
        
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

        taskQueue.async {
            
            guard let path = Bundle.main.path(forResource: scriptName,ofType:"command") else {
                print("Unable to locate " + scriptName)
                return
            }
            
            self.buildTask = Process()
            self.buildTask.launchPath = path
            if(arguments != nil){
                self.buildTask.arguments = arguments
            }
            
            self.buildTask.terminationHandler = {
                task in
                DispatchQueue.main.async(execute: {
                    self.isRunning = false
                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
        }
    }
    
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        
        print("Will capture output and write to textField ")

        outputPipe = Pipe()
        task.standardOutput = outputPipe

        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            print("NSFileHandleDataAvailable notification catched!")
            
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""

            DispatchQueue.main.async(execute: {
                print("*****OUTPUT: " + outputString)
                
                let previousOutput = self.resultTextField.stringValue
                var nextOutput = previousOutput
                if(outputString != ""){
                    nextOutput += "\n" + outputString
                }
                self.resultTextField.stringValue = nextOutput

            })
            
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
}
