//
//  BroadcastSetupViewController.swift
//  sprint1_broadcastSetupUI
//
//  Created by Alexis Ponce on 6/30/21.
//

import ReplayKit
import LFLiveKit
class BroadcastSetupViewController: UIViewController {

    // Call this method when the user has finished interacting with the view controller and a broadcast stream can start
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userDidFinishSetup();
    }
    func userDidFinishSetup() {
        print("actually went to the setup shit")
        // URL of the resource where broadcast can be viewed that will be returned to the application
        let broadcastURL = URL(string: "rtmp://phx.contribute.live-video.net/app/live_205645450_ga3Ys5uQ9B03Fm4ST51SBiehF8Is5s")
//        let broadcastURL = URL(string: "rtmp://live.restream.io/live/re_4468744_ae3c793ccb92c646bb41")
        
        // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
        let setupInfo: [String : NSCoding & NSObjectProtocol] = ["broadcastName": "Testing" as NSCoding & NSObjectProtocol]
        
        // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
        self.extensionContext?.completeRequest(withBroadcast: broadcastURL!, setupInfo: setupInfo)
    }
    
    func userDidCancelSetup() {
        let error = NSError(domain: "YouAppDomain", code: -1, userInfo: nil)
        // Tell ReplayKit that the extension was cancelled by the user
        self.extensionContext?.cancelRequest(withError: error)
    }
}
