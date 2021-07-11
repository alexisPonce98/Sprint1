//
//  SampleHandler.swift
//  sprint1_broadcast
//
//  Created by Alexis Ponce on 6/30/21.
//

import ReplayKit
import LFLiveKit
class SampleHandler: RPBroadcastSampleHandler{

    let session:LFLiveSession = {
        let audio = LFLiveAudioConfiguration.defaultConfiguration(for: .high)
        let video = LFLiveVideoConfiguration.default()
        let session = LFLiveSession(audioConfiguration: audio, videoConfiguration: video, captureType: LFLiveCaptureTypeMask.inputMaskVideo)
        session?.showDebugInfo = true
        return session!
    }()

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        print("Stream started in sampleHandler")
        let stream = LFLiveStreamInfo()
//        stream.url = "rtmp://live.restream.io/live/re_4468744_ae3c793ccb92c646bb41"
        stream.url = "rtmp://phx.contribute.live-video.net/app/live_205645450_ga3Ys5uQ9B03Fm4ST51SBiehF8Is5s"
        session.startLive(stream)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        print("Stream has been stopped by sampleHandler");
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        print("Stream has resumed by sampleHandler");
    }
    
    override func broadcastFinished() {
        print("Stream stopped in sampleHandler")
        // User has requested to finish the broadcast.
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            let pixel = CMSampleBufferGetImageBuffer(sampleBuffer)
            self.session.pushVideo(pixel)
            break
        case RPSampleBufferType.audioApp:
            print("Got app audio")
//            var blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
//            var lengthAtOffset:size_t!
//            var totalLength:size_t!
//            var data:UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
//            CMBlockBufferGetDataPointer(blockBuffer!, atOffset: 0, lengthAtOffsetOut: &lengthAtOffset, totalLengthOut: &totalLength, dataPointerOut: data)
//            let audioData = NSData(bytes: data, length: totalLength) as? Data
//            self.session.pushAudio(audioData)
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
//            print("Got mic audio")
//            let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
//            let blockBufferDataLength = CMBlockBufferGetDataLength(blockBuffer!)
//            var blockBufferData = [UInt8](repeating: 0, count: blockBufferDataLength)
//            let status = CMBlockBufferCopyDataBytes(blockBuffer!, atOffset: 0, dataLength: blockBufferDataLength, destination: &blockBufferData)
//            guard status == noErr else {
//                print("unable to copy data bytes");
//                return;
//            }
//            let data = Data(bytes: blockBufferData, count: blockBufferDataLength)
//            self.session.pushAudio(data)
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}

extension SampleHandler: LFLiveSessionDelegate{
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        switch state{
        case .pending:
            print("The state of the stream has changed, pending");
            break;
        case .ready:
            print("The state of the stream has changed, it is now ready");
            break;
        case .start:
            print("The state of the stream has changed, it has now started");
            break;
        case .stop:
            print("The state of the stream has changed, it has now stopped");
            break;
        case .error:
            print("The state of the stream has changed, there was an error");
            break;
        case .refresh:
            print("The state of the stream has changed, it is refreshing");
            break;
        default:
            print("Unknown state");
            break;
        }
    }
    
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        print("Degbug info has been sent, \(debugInfo)");
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print("there was an error: \(errorCode)");
    }
}
