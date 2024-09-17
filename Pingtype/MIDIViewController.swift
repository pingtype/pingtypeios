//
//  MIDIViewController.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 17/02/24.
//

import Foundation
import UIKit
import SWCompression
import WebKit
import CoreMIDI

func comp(req: UnsafeMutablePointer<MIDISysexSendRequest>) -> Void {
    print("Complete");
}

var globalHandlerSet:Bool = false
var globalHandler:MIDICallbackHandler?

func MyMIDIReadProc(pktList: UnsafePointer<MIDIPacketList>,
                    readProcRefCon: Optional<UnsafeMutableRawPointer>, srcConnRefCon: Optional<UnsafeMutableRawPointer>) -> Void
{
    print("MyMIDIReadProc")
    
    //let numberPackets = Int(pktList.pointee.numPackets)
    
    var thisCharacter = ""
    
//    if (pktList.pointee.packet.data.0 == 0xF0) && (pktList.pointee.packet.data.2 == 0x22) && (pktList.pointee.packet.data.2 == 0x33) && (pktList.pointee.packet.data.3 == 0xF7)
    //{
        let asciiBytes: [UInt8] = [pktList.pointee.packet.data.1]
        let asciiString = String(bytes: asciiBytes, encoding: .ascii)

        thisCharacter = asciiString!
  //  }
    
    //let packetData = String(format:"%02X",pktList.pointee.packet.data.0) + "," + String(format:"%02X",pktList.pointee.packet.data.1) + "," + String(format:"%02X",pktList.pointee.packet.data.2) + "," + String(format:"%02X",pktList.pointee.packet.data.3) + "," + String(format:"%02X",pktList.pointee.packet.data.4) + "," + String(format:"%02X",pktList.pointee.packet.data.5) + "," + String(format:"%02X",pktList.pointee.packet.data.6) + "," + String(format:"%02X",pktList.pointee.packet.data.7) + "," + String(format:"%02X",pktList.pointee.packet.data.8)
    
    //print(packetData)

    //let nc = NotificationCenter.default
    //nc.post(name: Notification.Name("MyMIDIReadProc"), object: nil)
    
    NotificationCenter.default.post(name: Notification.Name("MyMIDIReadProc"), object: nil, userInfo: ["message": thisCharacter])
    
    //let h:AnyObject = Unmanaged<AnyObject>.fromOpaque(readProcRefCon!) as AnyObject;
    
    if (globalHandlerSet == false)
    {
        let h:AnyObject = unbridgeMutable(ptr: readProcRefCon!);
        let handler:MIDICallbackHandler = h as! MIDICallbackHandler;
        handler.receivedString(thisString: "initialised");
        globalHandler = handler
        globalHandlerSet = true
    } else {
        globalHandler!.receivedString(thisString: thisCharacter);
    }

    //handler.receivedString(thisString: thisCharacter);
        
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let outputPath = documentsPath.appendingPathComponent("MIDI").appendingPathComponent("MyMIDIReadProc.txt")
    do
    {
        let fileContents = FileManager.default.contents(atPath: outputPath.path)
        var fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
        //var newFileContents = fileContentsAsString! + pktList.debugDescription + "\n"
        //var newFileContents = fileContentsAsString! + packetData + "\n"
        var newFileContents = fileContentsAsString! + thisCharacter
        try newFileContents.write(to: outputPath, atomically: true, encoding: String.Encoding.utf8)
        //try pktList.debugDescription.write(to: outputPath, atomically: true, encoding: String.Encoding.utf8)
    } catch _
    {
        print("error")
    }
    
}

protocol MIDICallbackHandler {

    func processMidiPacket(packet: MIDIPacket,  msgSrc: MIDIEndpointRef) -> Void;
    func processMidiObjectChange(message: MIDIObjectAddRemoveNotification) -> Void;
    func receivedString(thisString: String) -> Void;
}

func bridgeMutable<type : AnyObject>(obj : type) -> UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(obj).toOpaque()
}

func unbridgeMutable(ptr : UnsafeMutableRawPointer) -> AnyObject {
    return Unmanaged.fromOpaque(ptr).takeUnretainedValue()
}

class MIDIViewController: UIViewController, UIGestureRecognizerDelegate, WKNavigationDelegate, MIDICallbackHandler {
    
    func receivedString(thisString: String) {

        //let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //let outputPath = documentsPath.appendingPathComponent("MIDI").appendingPathComponent("MyMIDIReadProc.txt")
        //do
        //{
        //    let fileContents = FileManager.default.contents(atPath: outputPath.path)
        //    var fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
        //    //var newFileContents = fileContentsAsString! + pktList.debugDescription + "\n"
        //    //var newFileContents = fileContentsAsString! + packetData + "\n"
        //    var newFileContents = fileContentsAsString! + "receivedString (" + thisString + ")" + "\n"
        //    try newFileContents.write(to: outputPath, atomically: true, encoding: String.Encoding.utf8)
        //    //try pktList.debugDescription.write(to: outputPath, atomically: true, encoding: String.Encoding.utf8)
        //} catch _
        //{
        //    print("error")
        //}

        DispatchQueue.global(qos: .background).async {
            // Background Thread
            DispatchQueue.main.async {
                // Run UI Updates
                //let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                //let outputPath = documentsPath.appendingPathComponent("MIDI").appendingPathComponent("MyMIDIReadProc.txt")
                //let fileContents = FileManager.default.contents(atPath: outputPath.path)
                //var fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
                self.receivedTextView.text = self.receivedTextView.text + thisString
            }
        }
        
        //self.receivedTextView.text = self.receivedTextView.text + "\n" + thisString
        
    }

    func processMidiPacket(packet: MIDIPacket, msgSrc: MIDIEndpointRef) {
        receivedTextView.text = receivedTextView.text + "\n" + "processMidiPacket"
    }
    
    func processMidiObjectChange(message: MIDIObjectAddRemoveNotification) {
        receivedTextView.text = receivedTextView.text + "\n" + "processMidiObjectChange"
    }
    
        
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var exitButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet var receivedTextView: UITextView!
    
    var selectedItemPath: String?
    
    @objc func exitButtonClicked(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loadButtonClicked(_ sender: Any) {

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputPath = documentsPath.appendingPathComponent("MIDI").appendingPathComponent("MyMIDIReadProc.txt")
        let fileContents = FileManager.default.contents(atPath: outputPath.path)
        let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
            
        receivedTextView.text = fileContentsAsString

    }
    
    @IBAction func clearButtonClicked(_ sender: Any) {

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputPath = documentsPath.appendingPathComponent("MIDI").appendingPathComponent("MyMIDIReadProc.txt")
        do
        {
            let newFileContents = ""
            try newFileContents.write(to: outputPath, atomically: true, encoding: String.Encoding.utf8)
            //try pktList.debugDescription.write(to: outputPath, atomically: true, encoding: String.Encoding.utf8)
        } catch _
        {
            print("error")
        }
        
        receivedTextView.text = ""

    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        
        print("sendButtonClicked")

        var midiClient: MIDIClientRef = 0;
        var outPort:MIDIPortRef = 0;
        MIDIClientCreate("MidiTestClient" as CFString, nil, nil, &midiClient);
        MIDIOutputPortCreate(midiClient, "MidiTest_OutPort" as CFString, &outPort);

        //var packet1:MIDIPacket = MIDIPacket();
        //packet1.timeStamp = 0;
        //packet1.length = 3;
        //packet1.data.0 = 0xB0;
        //packet1.data.1 = 0x46;
        //packet1.data.2 = 0x64;
        //var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet1);

        let dest:MIDIEndpointRef = MIDIGetDestination(0);
        //MIDISend(outPort, dest, &packetList);

        let inputString = inputTextField.text
        var byteArray = [UInt8]()
        byteArray += [0xF0]
        for char in inputString!.utf8{
            byteArray += [char]
        }
        byteArray += [0x22]
        byteArray += [0x33]
        byteArray += [0xF7]

        print(byteArray)

        var method:MIDICompletionProc = comp
        //let buffer:UnsafePointer<UInt8> = UnsafePointer([0xF0,0x65,0x22,0x33,0xF7])
        let buffer:UnsafePointer<UInt8> = UnsafePointer(byteArray)
        var sendRequest = MIDISysexSendRequest(destination: dest,
                                               data: buffer,
                                               bytesToSend: UInt32(byteArray.count),
                                               complete: false,
                                               reserved: (0, 0, 0),
                                               completionProc: method,
                                               completionRefCon: UnsafeMutableRawPointer(&method))
        MIDISendSysex(&sendRequest);
        CFRunLoopRun();

    }

    //typealias MIDINotifyBlock = (UnsafePointer<MIDINotification>) -> Void
    func MyMIDINotifyBlock(midiNotification: UnsafePointer<MIDINotification>) {
        receivedTextView.text = receivedTextView.text + "\n" + "MyMIDINotifyBlock"
        receivedTextView.text = receivedTextView.text + "\n" + midiNotification.debugDescription
    }

    func MyMIDIReadBlock(packetList: UnsafePointer<MIDIPacketList>, srcConnRefCon: Optional<UnsafeMutableRawPointer>) -> Void {
        receivedTextView.text = receivedTextView.text + "\n" + "MyMIDIReadBlock"
        receivedTextView.text = receivedTextView.text + "\n" + packetList.debugDescription
    }

    func receivedMIDISystemCommand(_ data: [UInt8], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        receivedTextView.text = receivedTextView.text + "\n" + "receivedMIDISystemCommand"
        receivedTextView.text = receivedTextView.text + "\n" + data.debugDescription
    }

    func receivedMIDIReadBlock(packet: UnsafePointer<MIDIPacketList>, pointer:Optional<UnsafeMutableRawPointer>) {
        receivedTextView.text = receivedTextView.text + "\n" + "receivedMIDIReadBlock"
        receivedTextView.text = receivedTextView.text + "\n" + packet.debugDescription
    }
    
    @objc func receivedMidi(notification: Notification)
    {
        receivedTextView.text = receivedTextView.text + "\n" + "receivedMidi"
        receivedTextView.text = receivedTextView.text + "\n" + notification.debugDescription
    }
        
    override func viewDidLoad() {
                
        exitButton.action = #selector(exitButtonClicked(sender:))
     
        let tap = UITapGestureRecognizer(target: thisView, action: #selector(UIView.endEditing))
        thisView.addGestureRecognizer(tap)
        
        var midiClient: MIDIClientRef = 0;
        var inPort:MIDIPortRef = 0;
        var src:MIDIEndpointRef = MIDIGetSource(0);
        MIDIClientCreate("MidiTestClient" as CFString, nil, bridgeMutable(obj: self), &midiClient);
        //MIDIClientCreate("MidiTestClient" as CFString, nil, nil, &midiClient);
        //MIDIInputPortCreate(midiClient, "MidiTest_InPort" as CFString, MyMIDIReadProc, nil, &inPort);
        MIDIInputPortCreate(midiClient, "MidiTest_InPort" as CFString, MyMIDIReadProc, bridgeMutable(obj: self), &inPort);
        MIDIPortConnectSource(inPort, src, &src);
        
        
        let observer = NotificationCenter.default.addObserver(forName: Notification.Name("MyMIDIReadProc"), object: nil, queue: nil) { (notification) in
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let outputPath = documentsPath.appendingPathComponent("MIDI").appendingPathComponent("MyMIDIReadProc.txt")
            let fileContents = FileManager.default.contents(atPath: outputPath.path)
            var fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
            self.receivedTextView.text = fileContentsAsString
            
            //self.receivedTextView.text = (notification.userInfo?["message"]) as? String
        }
        
        MyMIDIReadProc(pktList: [], readProcRefCon: bridgeMutable(obj: self), srcConnRefCon: nil)
                
        //let nc = NotificationCenter.default
        //nc.addObserver(self, selector: #selector(receivedMidi), name: Notification.Name("MyMIDIReadProc"), object: nil)

        
        //var status = OSStatus(noErr)
        //var midiClient = MIDIClientRef()
        //status = MIDIClientCreateWithBlock("MyMIDIClient" as CFString, &midiClient, MyMIDINotifyBlock)
        //
        //var endpoint: MIDIEndpointRef = 0
        //MIDIDestinationCreateWithBlock(midiClient, "Virtual MIDI destination endpoint" as CFString, &endpoint, receivedMIDIReadBlock)
        //
        //var inputPort = MIDIPortRef()
        //status = MIDIInputPortCreateWithBlock(midiClient, "MyClient In" as CFString, &inputPort, MyMIDIReadBlock)
        
        //var inPort:MIDIPortRef = 0
        //var src:MIDIEndpointRef = MIDIGetSource(0)
        
        //status = MIDIInputPortCreateWithBlock(midiClient, "MyClient In" as CFString, &inPort, MyMIDIReadBlock)
        //MIDIPortConnectSource(inPort, src, &src)

        //var numberDestinations = MIDIGetNumberOfDestinations()
        //
        //for currentInPort in 0...numberDestinations
        //{
        //    var thisInPort:MIDIPortRef = MIDIPortRef(currentInPort)
        //    var thisSrc:MIDIEndpointRef = MIDIGetSource(currentInPort)
        //    status = MIDIInputPortCreateWithBlock(midiClient, "MyClient In" as CFString, &thisInPort, MyMIDIReadBlock)
        //    MIDIPortConnectSource(thisInPort, thisSrc, &thisSrc)
        //}
        
        //MIDIInputPortCreate(midiClient, "MidiTest_InPort" as CFString, MyMIDIReadProc, nil, &inPort)

        //MIDIPortConnectSource(inPort, src, &src)
        
        //
        //MIDIInputPortCreateWithProtocol(midiClient, "a" as CFString, MIDIProtocolID._1_0, &inputPort) { eventListUnsafePtr, srcConnRefCon in
        //    let midiEventList: MIDIEventList = eventListUnsafePtr.pointee
        //    var packet = midiEventList.packet
        //    self.receivedTextView.text = self.receivedTextView.text + "\n" + ("received \(midiEventList.numPackets) packets")
//
        //    (0 ..< midiEventList.numPackets).forEach { _ in
        //        let words = Mirror(reflecting: packet.words).children
//
        //        words.forEach { word in
        //            let uint32 = word.value as! UInt32
        //            guard uint32 > 0 else { return }
        //            let command = UInt8((uint32 & 0x0000FF00) >> 8)
        //            let value = Int(uint32 & 0x000000FF)
        //            self.receivedTextView.text = self.receivedTextView.text + "\n" + ("command \(command) , value \(value)")
        //        }
//
        //        packet = MIDIEventPacketNext(&packet).pointee
        //    }
//
        //    self.receivedTextView.text = self.receivedTextView.text + "\n" + ("END")
        //    self.receivedTextView.text = self.receivedTextView.text + "\n" + ("")
        //}


        
        
    }
    
}

