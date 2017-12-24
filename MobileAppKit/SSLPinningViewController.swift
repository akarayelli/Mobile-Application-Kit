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
            
        parseButton.isEnabled = false
        
        runScript(arguments)
    }
    
    
    func runScript(_ arguments:[String]) {
        
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

        taskQueue.async {
            
            guard let path = Bundle.main.path(forResource: "PinningScript",ofType:"command") else {
                print("Unable to locate PinningScript.command")
                return
            }
            
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            
            self.buildTask.terminationHandler = {
                task in
                DispatchQueue.main.async(execute: {
                    self.parseButton.isEnabled = true
                    self.isRunning = false
                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
        }
    }
    
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {

        outputPipe = Pipe()
        task.standardOutput = outputPipe

        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            //4.
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            //5.
            DispatchQueue.main.async(execute: {
                let previousOutput = self.resultTextField.stringValue
                let nextOutput = previousOutput + "\n" + outputString
                self.resultTextField.stringValue = nextOutput
            })
            
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
}
