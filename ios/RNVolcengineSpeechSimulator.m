#import <TargetConditionals.h>

#if TARGET_OS_SIMULATOR

#import <React/RCTEventEmitter.h>
#import <AVFoundation/AVFoundation.h>
#import <zlib.h>
#import <arpa/inet.h>

// The vendor x86_64 archive lacks SpeechCreateHandle and related symbols.
// Simulator speech uses the documented wire protocols; device builds keep SpeechEngine.
@interface RNVolcengineSpeech : RCTEventEmitter <NSURLSessionWebSocketDelegate>
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSURLSessionWebSocketTask *socket;
@property(nonatomic, strong) AVAudioEngine *recorder;
@property(nonatomic, copy) NSString *instanceId;
@property(nonatomic, copy) NSString *taskId;
@property(nonatomic, strong) NSMutableData *pendingAudio;
@property(nonatomic, strong) NSMutableArray<NSData *> *frames;
@property(nonatomic, copy) RCTPromiseResolveBlock startResolve;
@property(nonatomic, copy) RCTPromiseRejectBlock startReject;
@property(nonatomic) BOOL inputEnded;
@property(nonatomic) BOOL sending;
@property(nonatomic) BOOL tapInstalled;
@property(nonatomic) BOOL volumeEnabled;
@property(nonatomic, copy) NSString *kind;
@property(nonatomic, copy) NSString *ttsSessionId;
@property(nonatomic, strong) NSDictionary *ttsParameters;
@property(nonatomic, strong) AVAudioEngine *playerEngine;
@property(nonatomic, strong) AVAudioPlayerNode *player;
@property(nonatomic, strong) AVAudioFormat *playFormat;
@property(nonatomic, strong) NSMutableData *pendingPcm;
@property(nonatomic) double playSampleRate;
@property(nonatomic) NSUInteger scheduledBuffers;
@property(nonatomic) NSUInteger scheduledFrames;
@property(nonatomic) BOOL synthesisEnded;
@property(nonatomic) BOOL playbackStarted;
@property(nonatomic) BOOL ttsReadPaused;
@property(nonatomic) BOOL ttsReadPending;
@property(nonatomic) NSUInteger ttsReadGeneration;
@end

@implementation RNVolcengineSpeech
RCT_EXPORT_MODULE(RNVolcengineSpeech)

+ (BOOL)requiresMainQueueSetup { return NO; }
- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
- (NSArray<NSString *> *)supportedEvents { return @[@"RNVolcengineSpeechEvent"]; }
- (NSDictionary *)constantsToExport {
  return @{@"isSimulatorStub": @NO, @"supportsAsr": @YES, @"supportsTts": @YES,
           @"ttsImplementation": @"simulator-websocket",
           @"asrImplementation": @"simulator-websocket"};
}

- (void)emit:(NSString *)type data:(id)data {
  if (!self.taskId) return;
  [self sendEventWithName:@"RNVolcengineSpeechEvent" body:@{
    @"instanceId": self.instanceId, @"taskId": self.taskId, @"type": type,
    @"payload": data ? @{@"data": data} : @{}
  }];
}

- (void)stopRecorder {
  if (self.tapInstalled) {
    [self.recorder.inputNode removeTapOnBus:0];
    self.tapInstalled = NO;
  }
  [self.recorder stop];
  self.recorder = nil;
  [[AVAudioSession sharedInstance] setActive:NO
    withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)close {
  // Clear task identity before stopping the player: stop also triggers callbacks.
  self.taskId = nil;
  [self.player stop];
  [self.playerEngine stop];
  self.player = nil;
  self.playerEngine = nil;
  self.playFormat = nil;
  self.pendingPcm = nil;
  self.ttsParameters = nil;
  self.ttsSessionId = nil;
  [self stopRecorder];
  [self.socket cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
  [self.session invalidateAndCancel];
  self.socket = nil;
  self.session = nil;
  self.instanceId = nil;
  self.taskId = nil;
  self.startResolve = nil;
  self.startReject = nil;
  self.frames = nil;
  self.pendingAudio = nil;
  self.sending = NO;
  self.ttsReadPending = NO;
  self.ttsReadPaused = NO;
}

- (void)fail:(NSString *)code nativeCode:(NSInteger)nativeCode {
  if (!self.taskId) return;
  NSLog(@"[VolcengineSimulator%@] error=%@ nativeCode=%ld", [self.kind isEqual:@"tts"] ? @"Tts" : @"Asr", code, (long)nativeCode);
  if (self.startReject) {
    self.startReject(code, @"Simulator speech failed; inspect the error code", nil);
  }
  else {
    [self sendEventWithName:@"RNVolcengineSpeechEvent" body:@{
      @"instanceId": self.instanceId, @"taskId": self.taskId, @"type": @"error",
      @"payload": @{@"nativeCode": @(nativeCode), @"data":
        [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:
          @{@"code": @(nativeCode), @"stage": code} options:0 error:nil] encoding:NSUTF8StringEncoding]}
    }];
  }
  [self close];
}

// All outgoing frames are uncompressed (supported by the service). Responses may
// still be gzip encoded; cap decompression to avoid unbounded server payloads.
- (NSData *)inflate:(NSData *)data {
  z_stream stream = {0};
  stream.next_in = (Bytef *)data.bytes;
  stream.avail_in = (uInt)data.length;
  if (inflateInit2(&stream, 15 + 32) != Z_OK) return nil;
  NSMutableData *output = [NSMutableData data];
  int status;
  do {
    uint8_t buffer[8192];
    stream.next_out = buffer;
    stream.avail_out = sizeof(buffer);
    status = inflate(&stream, Z_NO_FLUSH);
    [output appendBytes:buffer length:sizeof(buffer) - stream.avail_out];
    if (output.length > 4 * 1024 * 1024) break;
  } while (status == Z_OK);
  inflateEnd(&stream);
  return status == Z_STREAM_END ? output : nil;
}

- (void)receive:(NSURLSessionWebSocketTask *)socket {
  if ([self.kind isEqual:@"tts"]) {
    if (self.ttsReadPending) return;
    self.ttsReadPending = YES;
    NSUInteger generation = ++self.ttsReadGeneration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      if (self.socket == socket && self.ttsReadPending && self.ttsReadGeneration == generation) {
        [self fail:@"E_TTS_RECEIVE_TIMEOUT" nativeCode:0];
      }
    });
  }
  __weak typeof(self) weakSelf = self;
  [socket receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage *message, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      RNVolcengineSpeech *self = weakSelf;
      if (!self || self.socket != socket) return;
      self.ttsReadPending = NO;
      if (error) { [self fail:[self.kind isEqual:@"tts"] ? @"E_TTS_RECEIVE" : @"E_ASR_RECEIVE" nativeCode:error.code]; return; }
      if ([self.kind isEqual:@"tts"]) {
        if (message.type != NSURLSessionWebSocketMessageTypeData) { [self fail:@"E_TTS_PROTOCOL" nativeCode:0]; return; }
        [self receiveTtsFrame:message.data];
        if (self.socket == socket) {
          if (self.scheduledFrames >= self.playSampleRate * 20) self.ttsReadPaused = YES;
          else [self receive:socket];
        }
        return;
      }
      NSData *data = message.data;
      if (message.type != NSURLSessionWebSocketMessageTypeData || data.length < 8) {
        [self fail:@"E_ASR_PROTOCOL" nativeCode:0]; return;
      }
      const uint8_t *bytes = data.bytes;
      NSUInteger offset = (bytes[0] & 15) * 4;
      uint8_t type = bytes[1] >> 4;
      uint8_t flags = bytes[1] & 15;
      uint32_t serviceCode = 0;
      if (offset < 4 || (bytes[0] >> 4) != 1) {
        [self fail:@"E_ASR_PROTOCOL" nativeCode:0]; return;
      }
      if (type == 15 || (flags & 1)) {
        if (data.length < offset + 4) { [self fail:@"E_ASR_PROTOCOL" nativeCode:0]; return; }
        uint32_t value;
        memcpy(&value, bytes + offset, 4);
        if (type == 15) serviceCode = ntohl(value);
        offset += 4;
      }
      if (data.length < offset + 4) { [self fail:@"E_ASR_PROTOCOL" nativeCode:0]; return; }
      uint32_t length;
      memcpy(&length, bytes + offset, 4);
      length = ntohl(length);
      offset += 4;
      if (length > data.length - offset) { [self fail:@"E_ASR_PROTOCOL" nativeCode:0]; return; }
      NSData *body = [data subdataWithRange:NSMakeRange(offset, length)];
      if ((bytes[2] & 15) == 1) body = [self inflate:body];
      if (!body || (bytes[2] & 15) > 1) { [self fail:@"E_ASR_PROTOCOL" nativeCode:0]; return; }
      if (type == 15) { [self fail:@"E_ASR_SERVICE" nativeCode:serviceCode]; return; }
      if (type != 9) { [self fail:@"E_ASR_PROTOCOL" nativeCode:0]; return; }
      NSDictionary *result = [NSJSONSerialization JSONObjectWithData:body options:0 error:nil];
      if (![result isKindOfClass:NSDictionary.class]) { [self fail:@"E_ASR_PROTOCOL" nativeCode:0]; return; }
      if (flags & 2) {
        NSLog(@"[VolcengineSimulatorAsr] finalResult");
        [self emit:@"finalResult" data:result];
        [self close];
      }
      else {
        [self emit:@"partialResult" data:result];
        [self receive:socket];
      }
    });
  }];
}

- (void)drain {
  if (!self.socket || self.sending || !self.frames.count) return;
  NSURLSessionWebSocketTask *socket = self.socket;
  NSData *frame = self.frames.firstObject;
  [self.frames removeObjectAtIndex:0];
  self.sending = YES;
  __weak typeof(self) weakSelf = self;
  [socket sendMessage:[[NSURLSessionWebSocketMessage alloc] initWithData:frame]
    completionHandler:^(NSError *error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        RNVolcengineSpeech *self = weakSelf;
        if (!self || self.socket != socket) return;
        self.sending = NO;
        if (error) [self fail:[self.kind isEqual:@"tts"] ? @"E_TTS_SEND" : @"E_ASR_SEND" nativeCode:error.code];
        else [self drain];
      });
    }];
}

- (void)enqueue:(NSData *)body type:(uint8_t)type final:(BOOL)final {
  if (!self.socket) return;
  uint8_t header[] = {0x11, (uint8_t)((type << 4) | (final ? 2 : 0)),
                      (uint8_t)(type == 1 ? 0x10 : 0), 0};
  uint32_t length = htonl((uint32_t)body.length);
  NSMutableData *frame = [NSMutableData dataWithBytes:header length:4];
  [frame appendBytes:&length length:4];
  [frame appendData:body];
  [self.frames addObject:frame];
  // Bound audio queued behind a stalled connection to ten seconds.
  if (self.frames.count > 100) { [self fail:@"E_ASR_BACKPRESSURE" nativeCode:0]; return; }
  [self drain];
}

// TTS has connection/session events, distinct from the ASR binary protocol.
- (void)enqueueTtsEvent:(uint32_t)event payload:(NSDictionary *)payload {
  NSData *body = [NSJSONSerialization dataWithJSONObject:payload ?: @{} options:0 error:nil];
  uint8_t header[] = {0x11, 0x14, 0x10, 0};
  NSMutableData *frame = [NSMutableData dataWithBytes:header length:4];
  uint32_t value = htonl(event);
  [frame appendBytes:&value length:4];
  if (event >= 100) {
    NSData *session = [self.ttsSessionId dataUsingEncoding:NSUTF8StringEncoding];
    value = htonl((uint32_t)session.length);
    [frame appendBytes:&value length:4];
    [frame appendData:session];
  }
  value = htonl((uint32_t)body.length);
  [frame appendBytes:&value length:4];
  [frame appendData:body];
  [self.frames addObject:frame];
  if (self.frames.count > 100) { [self fail:@"E_TTS_BACKPRESSURE" nativeCode:0]; return; }
  [self drain];
}

- (NSDictionary *)ttsPayload:(uint32_t)event text:(NSString *)text {
  NSMutableDictionary *payload = [self.ttsParameters mutableCopy];
  payload[@"event"] = @(event);
  payload[@"namespace"] = @"BidirectionalTTS";
  if (text) {
    NSMutableDictionary *parameters = [payload[@"req_params"] mutableCopy];
    parameters[@"text"] = text;
    payload[@"req_params"] = parameters;
  }
  return payload;
}

- (BOOL)startPlayer:(NSError **)error {
  AVAudioSession *session = AVAudioSession.sharedInstance;
  if (![session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:0 error:error]
      || ![session setActive:YES error:error]) return NO;
  self.playerEngine = [AVAudioEngine new];
  self.player = [AVAudioPlayerNode new];
  self.playFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
    sampleRate:self.playSampleRate channels:1 interleaved:NO];
  [self.playerEngine attachNode:self.player];
  AVAudioOutputNode *output = self.playerEngine.outputNode;
  AVAudioFormat *hardwareFormat = [output inputFormatForBus:0];
  if (hardwareFormat.sampleRate <= 0 || hardwareFormat.channelCount == 0) return NO;
  [self.playerEngine connect:self.player to:self.playerEngine.mainMixerNode format:self.playFormat];
  [self.playerEngine connect:self.playerEngine.mainMixerNode to:output format:hardwareFormat];
  NSLog(@"[VolcengineSimulatorTts] output sampleRate=%.0f channels=%u volume=%.2f",
    hardwareFormat.sampleRate, hardwareFormat.channelCount, session.outputVolume);
  [self.playerEngine prepare];
  return [self.playerEngine startAndReturnError:error];
}

- (void)completePlaybackIfReady {
  // SessionFinished only ends synthesis. DataPlayedBack is the audio device's
  // completion callback, so gaps between incoming chunks cannot end the UI early.
  if (!self.synthesisEnded || self.scheduledBuffers != 0 || !self.taskId) return;
  if (self.pendingPcm.length) { [self fail:@"E_TTS_PCM" nativeCode:0]; return; }
  NSLog(@"[VolcengineSimulatorTts] playbackFinished");
  [self emit:@"playbackFinished" data:nil];
  [self close];
}

- (void)playPcm:(NSData *)data {
  [self.pendingPcm appendData:data];
  NSUInteger frames = self.pendingPcm.length / 2;
  if (!frames) return;
  // Bound buffered playback to two minutes, independently of packet count.
  if (self.scheduledFrames + frames > self.playSampleRate * 120) {
    [self fail:@"E_TTS_BACKPRESSURE" nativeCode:0]; return;
  }
  AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.playFormat frameCapacity:(AVAudioFrameCount)frames];
  buffer.frameLength = (AVAudioFrameCount)frames;
  const uint8_t *bytes = self.pendingPcm.bytes;
  float *samples = buffer.floatChannelData[0];
  for (NSUInteger i = 0; i < frames; i++) {
    int16_t sample = (int16_t)((uint16_t)bytes[i * 2] | ((uint16_t)bytes[i * 2 + 1] << 8));
    samples[i] = sample / 32768.0f;
  }
  [self.pendingPcm replaceBytesInRange:NSMakeRange(0, frames * 2) withBytes:NULL length:0];
  self.scheduledBuffers += 1;
  self.scheduledFrames += frames;
  NSString *taskId = self.taskId;
  __weak typeof(self) weakSelf = self;
  [self.player scheduleBuffer:buffer completionCallbackType:AVAudioPlayerNodeCompletionDataPlayedBack
    completionHandler:^(AVAudioPlayerNodeCompletionCallbackType type) {
      dispatch_async(dispatch_get_main_queue(), ^{
        RNVolcengineSpeech *self = weakSelf;
        if (!self || ![self.taskId isEqual:taskId]) return;
        self.scheduledBuffers -= 1;
        self.scheduledFrames -= frames;
        // Do not reject long replies just because synthesis outruns playback.
        // Resume one receive when the local queue drains below ten seconds.
        if (self.ttsReadPaused && self.scheduledFrames <= self.playSampleRate * 10 && self.socket) {
          self.ttsReadPaused = NO;
          [self receive:self.socket];
        }
        [self completePlaybackIfReady];
      });
    }];
  if (!self.playbackStarted) {
    self.playbackStarted = YES;
    [self.player play];
    NSLog(@"[VolcengineSimulatorTts] playbackStarted");
    [self emit:@"playbackStarted" data:nil];
  }
}

// Parse before applying state changes; every optional field is length checked.
- (NSDictionary *)parseTtsFrame:(NSData *)data {
  if (data.length < 12) return nil;
  const uint8_t *bytes = data.bytes;
  NSUInteger offset = (bytes[0] & 15) * 4;
  uint8_t type = bytes[1] >> 4;
  if ((bytes[0] >> 4) != 1 || offset < 4 || offset > data.length - 8) return nil;
  uint32_t value;
  memcpy(&value, bytes + offset, 4);
  value = ntohl(value);
  offset += 4;
  if (type == 15) {
    uint32_t size;
    memcpy(&size, bytes + offset, 4);
    if (ntohl(size) != data.length - offset - 4) return nil;
    return @{@"errorCode": @(value)};
  }
  // All normal TTS frames carry an event. Connection responses include a
  // connect ID; session/audio responses include the requested session ID.
  if ((type != 9 && type != 11) || (bytes[1] & 15) != 4) return nil;
  uint32_t event = value;
  if (event == 50 || event == 51 || event == 52 || event >= 100) {
    if (offset > data.length - 4) return nil;
    memcpy(&value, bytes + offset, 4);
    NSUInteger length = ntohl(value);
    offset += 4;
    if (length > data.length - offset) return nil;
    if (event >= 100) {
      NSString *session = [[NSString alloc] initWithBytes:bytes + offset length:length encoding:NSUTF8StringEncoding];
      if (![session isEqual:self.ttsSessionId]) return nil;
    }
    offset += length;
  }
  if (offset > data.length - 4) return nil;
  memcpy(&value, bytes + offset, 4);
  NSUInteger length = ntohl(value);
  offset += 4;
  if (length != data.length - offset) return nil;
  NSData *body = [data subdataWithRange:NSMakeRange(offset, length)];
  if ((bytes[2] & 15) == 1) body = [self inflate:body];
  if (!body || (bytes[2] & 15) > 1) return nil;
  if (event == 352) {
    if (type != 11 || (bytes[2] >> 4) != 0) return nil;
    return @{@"event": @(event), @"audio": body};
  }
  id payload = [NSJSONSerialization JSONObjectWithData:body options:0 error:nil];
  if (![payload isKindOfClass:NSDictionary.class]) return nil;
  return @{@"event": @(event), @"payload": payload};
}

- (void)receiveTtsFrame:(NSData *)data {
  NSDictionary *frame = [self parseTtsFrame:data];
  if (!frame) { [self fail:@"E_TTS_PROTOCOL" nativeCode:0]; return; }
  if (frame[@"errorCode"]) { [self fail:@"E_TTS_SERVICE" nativeCode:[frame[@"errorCode"] integerValue]]; return; }
  NSInteger event = [frame[@"event"] integerValue];
  if (event == 50) {
    [self enqueueTtsEvent:100 payload:[self ttsPayload:100 text:nil]];
  }
  else if (event == 150) {
    if (!self.startResolve) { [self fail:@"E_TTS_PROTOCOL" nativeCode:0]; return; }
    NSError *error = nil;
    if (![self startPlayer:&error]) { [self fail:@"E_TTS_PLAYER" nativeCode:error.code]; return; }
    NSLog(@"[VolcengineSimulatorTts] sessionStarted");
    [self emit:@"ready" data:nil];
    RCTPromiseResolveBlock resolve = self.startResolve;
    self.startResolve = nil;
    self.startReject = nil;
    if (resolve) resolve(nil);
  }
  else if (event == 352) {
    if (!self.player || self.synthesisEnded) { [self fail:@"E_TTS_PROTOCOL" nativeCode:0]; return; }
    [self playPcm:frame[@"audio"]];
  }
  else if (event == 152) {
    self.synthesisEnded = YES;
    NSLog(@"[VolcengineSimulatorTts] synthesisFinished pendingBuffers=%lu", (unsigned long)self.scheduledBuffers);
    [self emit:@"synthesisFinished" data:frame[@"payload"]];
    // Network completion must leave scheduled audio alive until DataPlayedBack.
    [self.socket cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
    [self.session invalidateAndCancel];
    self.socket = nil;
    self.session = nil;
    [self completePlaybackIfReady];
  }
  else if (event == 51 || event == 153) {
    [self fail:@"E_TTS_SERVICE" nativeCode:[(frame[@"payload"][@"status_code"] ?: frame[@"payload"][@"code"]) integerValue]];
  }
  else if (event == 151 || event == 52) {
    [self fail:@"E_TTS_CLOSED" nativeCode:0];
  }
}

- (void)startTts:(NSString *)instanceId taskId:(NSString *)taskId payload:(NSDictionary *)payload
         config:(NSDictionary *)config resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  if (self.taskId) { reject(@"E_BUSY", @"Another speech task is active", nil); return; }
  NSDictionary *options = [config[@"ios"] isKindOfClass:NSDictionary.class] ? config[@"ios"] : @{};
  NSString *key = options[@"SE_PARAMS_KEY_API_KEY_STRING"];
  NSString *resource = options[@"SE_PARAMS_KEY_RESOURCE_ID_STRING"];
  NSString *address = options[@"SE_PARAMS_KEY_TTS_ADDRESS_STRING"] ?: @"wss://openspeech.bytedance.com";
  NSString *uri = options[@"SE_PARAMS_KEY_TTS_URI_STRING"] ?: @"/api/v3/tts/bidirection";
  NSURL *url = [NSURL URLWithString:[address stringByAppendingString:uri]];
  NSMutableDictionary *request = [payload isKindOfClass:NSDictionary.class] ? [payload mutableCopy] : [NSMutableDictionary new];
  NSMutableDictionary *parameters = [request[@"req_params"] isKindOfClass:NSDictionary.class]
    ? [request[@"req_params"] mutableCopy] : [NSMutableDictionary new];
  NSMutableDictionary *audio = [parameters[@"audio_params"] isKindOfClass:NSDictionary.class]
    ? [parameters[@"audio_params"] mutableCopy] : [NSMutableDictionary new];
  NSString *format = audio[@"format"] ?: @"pcm";
  NSNumber *sampleRate = audio[@"sample_rate"] ?: @24000;
  if (!key.length || !resource.length || ![url.scheme isEqual:@"wss"] || ![parameters[@"speaker"] length]) {
    reject(@"E_CONFIG", @"Simulator TTS requires API key, resource ID, speaker and a wss URL", nil); return;
  }
  if (![format isEqual:@"pcm"] || ![@[@8000, @16000, @22050, @24000, @32000, @44100, @48000] containsObject:sampleRate]
      || (options[@"SE_PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL"] && ![options[@"SE_PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL"] boolValue])) {
    reject(@"E_UNSUPPORTED", @"Simulator TTS supports PCM with the built-in player only", nil); return;
  }
  audio[@"format"] = @"pcm";
  audio[@"sample_rate"] = sampleRate;
  parameters[@"audio_params"] = audio;
  request[@"req_params"] = parameters;
  self.ttsParameters = request;
  self.ttsSessionId = NSUUID.UUID.UUIDString;
  self.kind = @"tts";
  self.instanceId = instanceId;
  self.taskId = taskId;
  self.startResolve = resolve;
  self.startReject = reject;
  self.frames = [NSMutableArray new];
  self.pendingPcm = [NSMutableData new];
  self.playSampleRate = sampleRate.doubleValue;
  self.inputEnded = NO;
  self.synthesisEnded = NO;
  self.playbackStarted = NO;
  self.scheduledBuffers = 0;
  self.scheduledFrames = 0;
  self.ttsReadPaused = NO;
  self.ttsReadPending = NO;
  NSMutableURLRequest *webRequest = [NSMutableURLRequest requestWithURL:url];
  [webRequest setValue:key forHTTPHeaderField:@"X-Api-Key"];
  [webRequest setValue:resource forHTTPHeaderField:@"X-Api-Resource-Id"];
  [webRequest setValue:NSUUID.UUID.UUIDString forHTTPHeaderField:@"X-Api-Connect-Id"];
  NSURLSessionConfiguration *sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration;
  sessionConfig.timeoutIntervalForRequest = 15;
  sessionConfig.timeoutIntervalForResource = 600;
  self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:NSOperationQueue.mainQueue];
  self.socket = [self.session webSocketTaskWithRequest:webRequest];
  [self.socket resume];
  [self receive:self.socket];
  NSString *currentTask = self.taskId;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if ([self.taskId isEqual:currentTask] && self.startReject) [self fail:@"E_TTS_CONNECT_TIMEOUT" nativeCode:0];
  });
}

- (BOOL)startRecorder:(NSError **)error {
  AVAudioSession *audioSession = AVAudioSession.sharedInstance;
  if (![audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement
                        options:0 error:error] || ![audioSession setActive:YES error:error]) return NO;
  self.recorder = [AVAudioEngine new];
  AVAudioInputNode *input = self.recorder.inputNode;
  AVAudioFormat *source = [input outputFormatForBus:0];
  if (source.sampleRate <= 0 || source.channelCount == 0) return NO;
  AVAudioFormat *target = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
    sampleRate:16000 channels:1 interleaved:YES];
  AVAudioConverter *converter = [[AVAudioConverter alloc] initFromFormat:source toFormat:target];
  if (!converter) return NO;
  __weak typeof(self) weakSelf = self;
  NSString *taskId = self.taskId;
  [input installTapOnBus:0 bufferSize:1024 format:source block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
    AVAudioFrameCount capacity = (AVAudioFrameCount)ceil(buffer.frameLength * 16000 / source.sampleRate) + 32;
    AVAudioPCMBuffer *output = [[AVAudioPCMBuffer alloc] initWithPCMFormat:target frameCapacity:capacity];
    __block BOOL supplied = NO;
    NSError *conversionError = nil;
    [converter convertToBuffer:output error:&conversionError withInputFromBlock:
      ^AVAudioBuffer *(AVAudioPacketCount count, AVAudioConverterInputStatus *status) {
        if (supplied) { *status = AVAudioConverterInputStatus_NoDataNow; return nil; }
        supplied = YES;
        *status = AVAudioConverterInputStatus_HaveData;
        return buffer;
      }];
    NSData *pcm = [NSData dataWithBytes:output.int16ChannelData[0] length:output.frameLength * 2];
    dispatch_async(dispatch_get_main_queue(), ^{
      RNVolcengineSpeech *self = weakSelf;
      if (!self || ![self.taskId isEqual:taskId] || self.inputEnded) return;
      if (conversionError) { [self fail:@"E_ASR_AUDIO_CONVERT" nativeCode:conversionError.code]; return; }
      [self.pendingAudio appendData:pcm];
      // 100 ms of signed little-endian mono PCM at 16 kHz.
      while (self.pendingAudio.length >= 3200 && self.socket) {
        NSData *chunk = [self.pendingAudio subdataWithRange:NSMakeRange(0, 3200)];
        [self.pendingAudio replaceBytesInRange:NSMakeRange(0, 3200) withBytes:NULL length:0];
        [self enqueue:chunk type:2 final:NO];
        if (self.volumeEnabled) {
          const int16_t *samples = chunk.bytes;
          double sum = 0;
          for (NSUInteger i = 0; i < 1600; i++) { double v = samples[i] / 32768.0; sum += v * v; }
          [self emit:@"volume" data:@{@"volume": @(MAX(-60, 10 * log10(MAX(sum / 1600, 1e-6))))}];
        }
      }
    });
  }];
  self.tapInstalled = YES;
  [self.recorder prepare];
  return [self.recorder startAndReturnError:error];
}

RCT_EXPORT_METHOD(invoke:(NSString *)operation instanceId:(NSString *)instanceId
                  taskId:(NSString *)taskId kind:(NSString *)kind payload:(NSDictionary *)payload
                  config:(NSDictionary *)config resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  if ([operation isEqual:@"destroy"] || [operation isEqual:@"cancel"]) {
    if ([self.instanceId isEqual:instanceId] &&
        ([operation isEqual:@"destroy"] || [self.taskId isEqual:taskId])) {
      if (self.startReject) self.startReject(@"E_CANCELLED", @"Speech cancelled before ready", nil);
      [self emit:@"cancelled" data:nil];
      [self close];
    }
    resolve(nil); return;
  }
  if ([kind isEqual:@"tts"]) {
    if ([operation isEqual:@"start"]) {
      [self startTts:instanceId taskId:taskId payload:payload config:config resolve:resolve reject:reject];
      return;
    }
    if (![self.instanceId isEqual:instanceId] || ![self.taskId isEqual:taskId] || ![self.kind isEqual:@"tts"] || self.startReject) {
      reject(@"E_INVALID_TASK", @"TTS task is inactive or not ready", nil); return;
    }
    if ([operation isEqual:@"appendText"] && !self.inputEnded) {
      NSString *text = payload[@"req_params"][@"text"];
      if (![text isKindOfClass:NSString.class]) { reject(@"E_CONFIG", @"TTS requires text", nil); return; }
      [self enqueueTtsEvent:200 payload:[self ttsPayload:200 text:text]];
      resolve(nil); return;
    }
    if ([operation isEqual:@"finishInput"]) {
      if (!self.inputEnded) {
        self.inputEnded = YES;
        [self enqueueTtsEvent:102 payload:@{}];
        [self emit:@"inputEnded" data:nil];
        NSLog(@"[VolcengineSimulatorTts] inputEnded");
      }
      resolve(nil); return;
    }
    reject(@"E_INVALID_TASK", @"TTS input already ended or operation unsupported", nil); return;
  }
  if (![kind isEqual:@"asr"]) { reject(@"E_UNSUPPORTED", @"Unknown speech engine", nil); return; }
  if ([operation isEqual:@"finishInput"]) {
    if (![self.instanceId isEqual:instanceId] || ![self.taskId isEqual:taskId]) {
      reject(@"E_INVALID_TASK", @"ASR task is inactive", nil); return;
    }
    if (!self.inputEnded) {
      self.inputEnded = YES;
      [self stopRecorder];
      [self enqueue:[self.pendingAudio copy] type:2 final:YES];
      [self.pendingAudio setLength:0];
      [self emit:@"inputEnded" data:nil];
      NSLog(@"[VolcengineSimulatorAsr] inputEnded");
      NSURLSessionWebSocketTask *socket = self.socket;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.socket == socket) [self fail:@"E_ASR_RESULT_TIMEOUT" nativeCode:0];
      });
    }
    resolve(nil); return;
  }
  if (![operation isEqual:@"start"]) { reject(@"E_UNSUPPORTED", @"Unsupported ASR operation", nil); return; }
  if (self.taskId) { reject(@"E_BUSY", @"Another ASR task is active", nil); return; }
  if (AVAudioSession.sharedInstance.recordPermission != AVAudioSessionRecordPermissionGranted) {
    reject(@"E_MIC_PERMISSION", @"Request microphone permission before starting ASR", nil); return;
  }
  NSDictionary *options = [config[@"ios"] isKindOfClass:NSDictionary.class] ? config[@"ios"] : @{};
  NSString *key = options[@"SE_PARAMS_KEY_API_KEY_STRING"];
  NSString *resource = options[@"SE_PARAMS_KEY_RESOURCE_ID_STRING"];
  NSString *address = options[@"SE_PARAMS_KEY_ASR_ADDRESS_STRING"] ?: @"wss://openspeech.bytedance.com";
  NSString *uri = options[@"SE_PARAMS_KEY_ASR_URI_STRING"] ?: @"/api/v3/sauc/bigmodel_nostream";
  NSURL *url = [NSURL URLWithString:[address stringByAppendingString:uri]];
  if (!key.length || !resource.length || ![url.scheme isEqual:@"wss"]) {
    reject(@"E_CONFIG", @"Simulator ASR requires API key, resource ID and a wss URL", nil); return;
  }
  NSString *source = options[@"SE_PARAMS_KEY_RECORDER_DATA_SOURCE_TYPE_STRING"];
  if (source && ![source isEqual:@"Recorder"]) {
    reject(@"E_UNSUPPORTED", @"Simulator ASR supports the built-in recorder only", nil); return;
  }
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setValue:key forHTTPHeaderField:@"X-Api-Key"];
  [request setValue:resource forHTTPHeaderField:@"X-Api-Resource-Id"];
  NSString *requestId = NSUUID.UUID.UUIDString;
  [request setValue:requestId forHTTPHeaderField:@"X-Api-Request-Id"];
  [request setValue:requestId forHTTPHeaderField:@"X-Api-Connect-Id"];
  self.kind = @"asr";
  self.instanceId = instanceId;
  self.taskId = taskId;
  self.startResolve = resolve;
  self.startReject = reject;
  self.frames = [NSMutableArray new];
  self.pendingAudio = [NSMutableData new];
  self.inputEnded = NO;
  self.volumeEnabled = [options[@"SE_PARAMS_KEY_ENABLE_GET_VOLUME_BOOL"] boolValue];
  NSURLSessionConfiguration *sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration;
  sessionConfig.timeoutIntervalForRequest = 10;
  sessionConfig.timeoutIntervalForResource = 120;
  self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:NSOperationQueue.mainQueue];
  self.socket = [self.session webSocketTaskWithRequest:request];
  NSMutableDictionary *parameters = [@{@"model_name": @"bigmodel", @"enable_itn": @YES,
                                      @"enable_punc": @YES, @"result_type": @"full"} mutableCopy];
  NSString *configured = options[@"SE_PARAMS_KEY_ASR_REQ_PARAMS_STRING"];
  if (configured.length) {
    id parsed = [NSJSONSerialization JSONObjectWithData:[configured dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (![parsed isKindOfClass:NSDictionary.class]) { [self fail:@"E_CONFIG" nativeCode:0]; return; }
    [parameters addEntriesFromDictionary:parsed];
  }
  if ([payload isKindOfClass:NSDictionary.class]) [parameters addEntriesFromDictionary:payload];
  NSMutableDictionary *audio = [@{@"format": @"pcm", @"codec": @"raw", @"rate": @16000,
                                 @"bits": @16, @"channel": @1} mutableCopy];
  if (options[@"SE_PARAMS_KEY_ASR_LANGUAGE_STRING"]) audio[@"language"] = options[@"SE_PARAMS_KEY_ASR_LANGUAGE_STRING"];
  NSData *body = [NSJSONSerialization dataWithJSONObject:@{
    @"user": @{@"uid": @"ios-simulator"}, @"audio": audio, @"request": parameters
  } options:0 error:nil];
  [self.socket resume];
  [self enqueue:body type:1 final:NO];
  [self receive:self.socket];
  NSURLSessionWebSocketTask *socket = self.socket;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if (self.socket == socket && self.startReject) [self fail:@"E_ASR_CONNECT_TIMEOUT" nativeCode:0];
  });
}

- (void)URLSession:(NSURLSession *)session webSocketTask:(NSURLSessionWebSocketTask *)socket
 didOpenWithProtocol:(NSString *)protocol {
  if (self.socket != socket) return;
  if ([self.kind isEqual:@"tts"]) {
    [self enqueueTtsEvent:1 payload:@{}];
    return;
  }
  NSError *error = nil;
  if (![self startRecorder:&error]) { [self fail:@"E_ASR_RECORDER" nativeCode:error.code]; return; }
  NSLog(@"[VolcengineSimulatorAsr] connected recordingStarted");
  [self emit:@"ready" data:nil];
  [self emit:@"recordingStarted" data:nil];
  RCTPromiseResolveBlock resolve = self.startResolve;
  self.startResolve = nil;
  self.startReject = nil;
  if (resolve) resolve(nil);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 didCompleteWithError:(NSError *)error {
  if (self.socket == task) [self fail:[self.kind isEqual:@"tts"] ? @"E_TTS_CONNECTION" : @"E_ASR_CONNECTION" nativeCode:error.code];
}

- (void)invalidate {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.startReject) self.startReject(@"E_DESTROYED", @"Speech module destroyed", nil);
    [self close];
  });
  [super invalidate];
}
@end

#endif
