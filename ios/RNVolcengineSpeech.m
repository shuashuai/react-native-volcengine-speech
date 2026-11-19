#import <React/RCTEventEmitter.h>
#import <TargetConditionals.h>

#if TARGET_OS_SIMULATOR

@interface RNVolcengineSpeech : RCTEventEmitter
@end

@implementation RNVolcengineSpeech
RCT_EXPORT_MODULE(RNVolcengineSpeech)

+ (BOOL)requiresMainQueueSetup { return NO; }

- (NSDictionary *)constantsToExport {
  return @{@"isSimulatorStub": @YES};
}

- (NSArray<NSString *> *)supportedEvents { return @[@"RNVolcengineSpeechEvent"]; }

RCT_EXPORT_METHOD(invoke:(NSString *)operation instanceId:(NSString *)instanceId
                  taskId:(NSString *)taskId kind:(NSString *)kind payload:(NSDictionary *)payload
                  config:(NSDictionary *)config resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  if ([operation isEqualToString:@"destroy"] || [operation isEqualToString:@"cancel"]) {
    resolve(nil);
    return;
  }
  reject(@"E_UNSUPPORTED", @"Volcengine Speech requires a physical iOS device", nil);
}
@end

#else

#import <SpeechEngineToB/SpeechEngine.h>

static NSDictionary *SpeechOptionDefinitions(void) {
  static NSDictionary *definitions;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    definitions = @{
      @"SE_PARAMS_KEY_AEC_ENABLE_DUMP_BOOL": @[SE_PARAMS_KEY_AEC_ENABLE_DUMP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_AEC_MODEL_PATH_STRING": @[SE_PARAMS_KEY_AEC_MODEL_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AED_RESOURCE_PATH_STRING": @[SE_PARAMS_KEY_AED_RESOURCE_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_API_KEY_STRING": @[SE_PARAMS_KEY_API_KEY_STRING, @"STRING"],
      @"SE_PARAMS_KEY_APP_ID_STRING": @[SE_PARAMS_KEY_APP_ID_STRING, @"STRING"],
      @"SE_PARAMS_KEY_APP_KEY_STRING": @[SE_PARAMS_KEY_APP_KEY_STRING, @"STRING"],
      @"SE_PARAMS_KEY_APP_TOKEN_STRING": @[SE_PARAMS_KEY_APP_TOKEN_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_ADDRESS_STRING": @[SE_PARAMS_KEY_ASR_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_AUTO_STOP_BOOL": @[SE_PARAMS_KEY_ASR_AUTO_STOP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_CLUSTER_STRING": @[SE_PARAMS_KEY_ASR_CLUSTER_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_CONN_TIMEOUT_INT": @[SE_PARAMS_KEY_ASR_CONN_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_ASR_CORRECT_WORDS_STRING": @[SE_PARAMS_KEY_ASR_CORRECT_WORDS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_DISABLE_END_PUNC_BOOL": @[SE_PARAMS_KEY_ASR_DISABLE_END_PUNC_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_ENABLE_DDC_BOOL": @[SE_PARAMS_KEY_ASR_ENABLE_DDC_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_ENABLE_ITN_BOOL": @[SE_PARAMS_KEY_ASR_ENABLE_ITN_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_KEEP_RECORDING_BOOL": @[SE_PARAMS_KEY_ASR_KEEP_RECORDING_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_LANGUAGE_STRING": @[SE_PARAMS_KEY_ASR_LANGUAGE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_MAX_RETRY_TIMES_INT": @[SE_PARAMS_KEY_ASR_MAX_RETRY_TIMES_INT, @"INT"],
      @"SE_PARAMS_KEY_ASR_OFF_RESOURCE_PATH_STRING": @[SE_PARAMS_KEY_ASR_OFF_RESOURCE_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_PACKAGE_SIZE_INT": @[SE_PARAMS_KEY_ASR_PACKAGE_SIZE_INT, @"INT"],
      @"SE_PARAMS_KEY_ASR_RECV_TIMEOUT_INT": @[SE_PARAMS_KEY_ASR_RECV_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_ASR_REC_PATH_STRING": @[SE_PARAMS_KEY_ASR_REC_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_REQ_PARAMS_STRING": @[SE_PARAMS_KEY_ASR_REQ_PARAMS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_RESULT_TYPE_STRING": @[SE_PARAMS_KEY_ASR_RESULT_TYPE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_SCENARIO_INT": @[SE_PARAMS_KEY_ASR_SCENARIO_INT, @"INT"],
      @"SE_PARAMS_KEY_ASR_SHOW_LANG_BOOL": @[SE_PARAMS_KEY_ASR_SHOW_LANG_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_SHOW_NLU_PUNC_BOOL": @[SE_PARAMS_KEY_ASR_SHOW_NLU_PUNC_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_SHOW_PUNC_BOOL": @[SE_PARAMS_KEY_ASR_SHOW_PUNC_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_SHOW_UTTER_BOOL": @[SE_PARAMS_KEY_ASR_SHOW_UTTER_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_SHOW_VOLUME_BOOL": @[SE_PARAMS_KEY_ASR_SHOW_VOLUME_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ASR_URI_STRING": @[SE_PARAMS_KEY_ASR_URI_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_VAD_END_SILENCE_TIME_INT": @[SE_PARAMS_KEY_ASR_VAD_END_SILENCE_TIME_INT, @"INT"],
      @"SE_PARAMS_KEY_ASR_VAD_MODE_STRING": @[SE_PARAMS_KEY_ASR_VAD_MODE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_ASR_VAD_START_SILENCE_TIME_INT": @[SE_PARAMS_KEY_ASR_VAD_START_SILENCE_TIME_INT, @"INT"],
      @"SE_PARAMS_KEY_ASR_WORK_MODE_INT": @[SE_PARAMS_KEY_ASR_WORK_MODE_INT, @"INT"],
      @"SE_PARAMS_KEY_AUDIO_FADEOUT_DURATION_INT": @[SE_PARAMS_KEY_AUDIO_FADEOUT_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_AUTHENTICATE_ADDRESS_STRING": @[SE_PARAMS_KEY_AUTHENTICATE_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AUTHENTICATE_CREDENTIAL_STRING": @[SE_PARAMS_KEY_AUTHENTICATE_CREDENTIAL_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AUTHENTICATE_SECRET_STRING": @[SE_PARAMS_KEY_AUTHENTICATE_SECRET_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AUTHENTICATE_TYPE_STRING": @[SE_PARAMS_KEY_AUTHENTICATE_TYPE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AUTHENTICATE_URI_STRING": @[SE_PARAMS_KEY_AUTHENTICATE_URI_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AU_ABILITY_INT": @[SE_PARAMS_KEY_AU_ABILITY_INT, @"INT"],
      @"SE_PARAMS_KEY_AU_ADDRESS_STRING": @[SE_PARAMS_KEY_AU_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AU_AUDIO_PACKET_DURATION_INT": @[SE_PARAMS_KEY_AU_AUDIO_PACKET_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_AU_AUTO_STOP_BOOL": @[SE_PARAMS_KEY_AU_AUTO_STOP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_AU_CLUSTER_STRING": @[SE_PARAMS_KEY_AU_CLUSTER_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AU_CONN_TIMEOUT_INT": @[SE_PARAMS_KEY_AU_CONN_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_AU_EMPTY_PACKET_INTERVAL_INT": @[SE_PARAMS_KEY_AU_EMPTY_PACKET_INTERVAL_INT, @"INT"],
      @"SE_PARAMS_KEY_AU_PROCESS_TIMEOUT_INT": @[SE_PARAMS_KEY_AU_PROCESS_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_AU_RECV_TIMEOUT_INT": @[SE_PARAMS_KEY_AU_RECV_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_AU_REC_PATH_STRING": @[SE_PARAMS_KEY_AU_REC_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_AU_URI_STRING": @[SE_PARAMS_KEY_AU_URI_STRING, @"STRING"],
      @"SE_PARAMS_KEY_BUSINESS_KEY_STRING": @[SE_PARAMS_KEY_BUSINESS_KEY_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CAPT_ADDRESS_STRING": @[SE_PARAMS_KEY_CAPT_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CAPT_AUTO_STOP_BOOL": @[SE_PARAMS_KEY_CAPT_AUTO_STOP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_CAPT_CLUSTER_STRING": @[SE_PARAMS_KEY_CAPT_CLUSTER_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CAPT_CONN_TIMEOUT_INT": @[SE_PARAMS_KEY_CAPT_CONN_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_CAPT_CORE_TYPE_STRING": @[SE_PARAMS_KEY_CAPT_CORE_TYPE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CAPT_DIFFICULTY_INT": @[SE_PARAMS_KEY_CAPT_DIFFICULTY_INT, @"INT"],
      @"SE_PARAMS_KEY_CAPT_RECV_TIMEOUT_INT": @[SE_PARAMS_KEY_CAPT_RECV_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_CAPT_REC_PATH_STRING": @[SE_PARAMS_KEY_CAPT_REC_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CAPT_REFER_TEXT_STRING": @[SE_PARAMS_KEY_CAPT_REFER_TEXT_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CAPT_RESPONSE_MODE_STRING": @[SE_PARAMS_KEY_CAPT_RESPONSE_MODE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CAPT_SCENE_STRING": @[SE_PARAMS_KEY_CAPT_SCENE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CAPT_URI_STRING": @[SE_PARAMS_KEY_CAPT_URI_STRING, @"STRING"],
      @"SE_PARAMS_KEY_CHANNEL_NUM_INT": @[SE_PARAMS_KEY_CHANNEL_NUM_INT, @"INT"],
      @"SE_PARAMS_KEY_CUSTOM_CHANNEL_INT": @[SE_PARAMS_KEY_CUSTOM_CHANNEL_INT, @"INT"],
      @"SE_PARAMS_KEY_CUSTOM_SAMPLE_RATE_INT": @[SE_PARAMS_KEY_CUSTOM_SAMPLE_RATE_INT, @"INT"],
      @"SE_PARAMS_KEY_CUSTOM_WS_CLIENT_PTR_DOUBLE": @[SE_PARAMS_KEY_CUSTOM_WS_CLIENT_PTR_DOUBLE, @"DOUBLE"],
      @"SE_PARAMS_KEY_DEBUG_PATH_STRING": @[SE_PARAMS_KEY_DEBUG_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_DEVICE_ID_STRING": @[SE_PARAMS_KEY_DEVICE_ID_STRING, @"STRING"],
      @"SE_PARAMS_KEY_DIALOG_ADDRESS_STRING": @[SE_PARAMS_KEY_DIALOG_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_DIALOG_ENABLE_DECODER_AUDIO_CALLBACK_BOOL": @[SE_PARAMS_KEY_DIALOG_ENABLE_DECODER_AUDIO_CALLBACK_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_DIALOG_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL": @[SE_PARAMS_KEY_DIALOG_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_DIALOG_ENABLE_PLAYER_BOOL": @[SE_PARAMS_KEY_DIALOG_ENABLE_PLAYER_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_DIALOG_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL": @[SE_PARAMS_KEY_DIALOG_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_DIALOG_PLAYER_PATH_STRING": @[SE_PARAMS_KEY_DIALOG_PLAYER_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_DIALOG_RECORDER_PATH_STRING": @[SE_PARAMS_KEY_DIALOG_RECORDER_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_DIALOG_URI_STRING": @[SE_PARAMS_KEY_DIALOG_URI_STRING, @"STRING"],
      @"SE_PARAMS_KEY_DIALOG_WORK_MODE_INT": @[SE_PARAMS_KEY_DIALOG_WORK_MODE_INT, @"INT"],
      @"SE_PARAMS_KEY_ENABLE_AEC_BOOL": @[SE_PARAMS_KEY_ENABLE_AEC_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ENABLE_CUSTOM_WS_CLIENT_BOOL": @[SE_PARAMS_KEY_ENABLE_CUSTOM_WS_CLIENT_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ENABLE_GET_VOLUME_BOOL": @[SE_PARAMS_KEY_ENABLE_GET_VOLUME_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL": @[SE_PARAMS_KEY_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL": @[SE_PARAMS_KEY_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ENABLE_RESAMPLER_BOOL": @[SE_PARAMS_KEY_ENABLE_RESAMPLER_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ENABLE_RESUME_FROM_PREVIOUS_PROGRESS_BOOL": @[SE_PARAMS_KEY_ENABLE_RESUME_FROM_PREVIOUS_PROGRESS_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_ENABLE_WS_RECONNECT_BOOL": @[SE_PARAMS_KEY_ENABLE_WS_RECONNECT_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_FINGERPRINT_SLICE_DURATION_INT": @[SE_PARAMS_KEY_FINGERPRINT_SLICE_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_FULLLINK_ADDRESS_STRING": @[SE_PARAMS_KEY_FULLLINK_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_FULLLINK_ASR_AUTO_STOP_BOOL": @[SE_PARAMS_KEY_FULLLINK_ASR_AUTO_STOP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_FULLLINK_ASR_ONLY_BOOL": @[SE_PARAMS_KEY_FULLLINK_ASR_ONLY_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_FULLLINK_CLUSTER_STRING": @[SE_PARAMS_KEY_FULLLINK_CLUSTER_STRING, @"STRING"],
      @"SE_PARAMS_KEY_FULLLINK_CONN_TIMEOUT_INT": @[SE_PARAMS_KEY_FULLLINK_CONN_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_FULLLINK_DISABLE_TTS_BOOL": @[SE_PARAMS_KEY_FULLLINK_DISABLE_TTS_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_FULLLINK_FILTER_WAKEUP_WORD_STRING": @[SE_PARAMS_KEY_FULLLINK_FILTER_WAKEUP_WORD_STRING, @"STRING"],
      @"SE_PARAMS_KEY_FULLLINK_QUERY_STRING_STRING": @[SE_PARAMS_KEY_FULLLINK_QUERY_STRING_STRING, @"STRING"],
      @"SE_PARAMS_KEY_FULLLINK_RECV_TIMEOUT_INT": @[SE_PARAMS_KEY_FULLLINK_RECV_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_FULLLINK_SCENE_ID_STRING": @[SE_PARAMS_KEY_FULLLINK_SCENE_ID_STRING, @"STRING"],
      @"SE_PARAMS_KEY_FULLLINK_URI_STRING": @[SE_PARAMS_KEY_FULLLINK_URI_STRING, @"STRING"],
      @"SE_PARAMS_KEY_FULLLINK_USER_PARAM_STRING": @[SE_PARAMS_KEY_FULLLINK_USER_PARAM_STRING, @"STRING"],
      @"SE_PARAMS_KEY_FULLLINK_VAD_HEAD_WAIT_TIME_INT": @[SE_PARAMS_KEY_FULLLINK_VAD_HEAD_WAIT_TIME_INT, @"INT"],
      @"SE_PARAMS_KEY_KWS_ENABLE_VAD_BOOL": @[SE_PARAMS_KEY_KWS_ENABLE_VAD_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_KWS_ROOT_PATH_STRING": @[SE_PARAMS_KEY_KWS_ROOT_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_KWS_USER_PARAM_STRING": @[SE_PARAMS_KEY_KWS_USER_PARAM_STRING, @"STRING"],
      @"SE_PARAMS_KEY_KWS_VAD_END_SILENCE_TIMEOUT_INT": @[SE_PARAMS_KEY_KWS_VAD_END_SILENCE_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_LICENSE_BUSI_ID_STRING": @[SE_PARAMS_KEY_LICENSE_BUSI_ID_STRING, @"STRING"],
      @"SE_PARAMS_KEY_LICENSE_DIRECTORY_STRING": @[SE_PARAMS_KEY_LICENSE_DIRECTORY_STRING, @"STRING"],
      @"SE_PARAMS_KEY_LICENSE_NAME_STRING": @[SE_PARAMS_KEY_LICENSE_NAME_STRING, @"STRING"],
      @"SE_PARAMS_KEY_LOG_LEVEL_STRING": @[SE_PARAMS_KEY_LOG_LEVEL_STRING, @"STRING"],
      @"SE_PARAMS_KEY_PREVENT_PLAYER_CREATION_BOOL": @[SE_PARAMS_KEY_PREVENT_PLAYER_CREATION_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_PROTOCOL_TYPE_INT": @[SE_PARAMS_KEY_PROTOCOL_TYPE_INT, @"INT"],
      @"SE_PARAMS_KEY_RECORDER_FILE_STRING": @[SE_PARAMS_KEY_RECORDER_FILE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_RECORDER_TYPE_STRING": @[SE_PARAMS_KEY_RECORDER_TYPE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_REC_FILE_TYPE_INT": @[SE_PARAMS_KEY_REC_FILE_TYPE_INT, @"INT"],
      @"SE_PARAMS_KEY_REC_PATH_STRING": @[SE_PARAMS_KEY_REC_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_REQUEST_HEADERS_STRING": @[SE_PARAMS_KEY_REQUEST_HEADERS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_RESET_AUDIOSESSION_BOOL": @[SE_PARAMS_KEY_RESET_AUDIOSESSION_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_RESOURCE_ID_STRING": @[SE_PARAMS_KEY_RESOURCE_ID_STRING, @"STRING"],
      @"SE_PARAMS_KEY_RESTART_AUDIOSESSION_BOOL": @[SE_PARAMS_KEY_RESTART_AUDIOSESSION_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_RESUME_OTHERS_INTERRUPTED_PLAYBACK_BOOL": @[SE_PARAMS_KEY_RESUME_OTHERS_INTERRUPTED_PLAYBACK_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_SAMPLE_RATE_INT": @[SE_PARAMS_KEY_SAMPLE_RATE_INT, @"INT"],
      @"SE_PARAMS_KEY_SIGNAL_ROOT_PATH_STRING": @[SE_PARAMS_KEY_SIGNAL_ROOT_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_STOP_RECORD_WHEN_BACKGROUND_BOOL": @[SE_PARAMS_KEY_STOP_RECORD_WHEN_BACKGROUND_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_STOP_RECORD_WHEN_INTERRUPTION_BOOL": @[SE_PARAMS_KEY_STOP_RECORD_WHEN_INTERRUPTION_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_TTS_ADDRESS_STRING": @[SE_PARAMS_KEY_TTS_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_AUDIO_CACHE_PATH_STRING": @[SE_PARAMS_KEY_TTS_AUDIO_CACHE_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_AUDIO_FILE_STRING": @[SE_PARAMS_KEY_TTS_AUDIO_FILE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_AUDIO_PATH_STRING": @[SE_PARAMS_KEY_TTS_AUDIO_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_BACKEND_CLUSTER_STRING": @[SE_PARAMS_KEY_TTS_BACKEND_CLUSTER_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_BUSINESS_STRING": @[SE_PARAMS_KEY_TTS_BUSINESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_CACHE_RENEWAL_DURATION_INT": @[SE_PARAMS_KEY_TTS_CACHE_RENEWAL_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_CLUSTER_STRING": @[SE_PARAMS_KEY_TTS_CLUSTER_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_COMPRESSION_RATE_INT": @[SE_PARAMS_KEY_TTS_COMPRESSION_RATE_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_CONCURRENCY_MODE_INT": @[SE_PARAMS_KEY_TTS_CONCURRENCY_MODE_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_CONN_TIMEOUT_INT": @[SE_PARAMS_KEY_TTS_CONN_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_DATA_CALLBACK_MODE_INT": @[SE_PARAMS_KEY_TTS_DATA_CALLBACK_MODE_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_EMOTION_STRING": @[SE_PARAMS_KEY_TTS_EMOTION_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_ENABLE_CACHE_BOOL": @[SE_PARAMS_KEY_TTS_ENABLE_CACHE_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_TTS_ENABLE_DUMP_BOOL": @[SE_PARAMS_KEY_TTS_ENABLE_DUMP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL": @[SE_PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_TTS_FADEIN_DURATION_INT": @[SE_PARAMS_KEY_TTS_FADEIN_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_FADEOUT_DURATION_INT": @[SE_PARAMS_KEY_TTS_FADEOUT_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_FRONTEND_TYPE_STRING": @[SE_PARAMS_KEY_TTS_FRONTEND_TYPE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_LANGUAGE_ONLINE_STRING": @[SE_PARAMS_KEY_TTS_LANGUAGE_ONLINE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_LIMIT_CPU_USAGE_BOOL": @[SE_PARAMS_KEY_TTS_LIMIT_CPU_USAGE_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_TTS_MAX_CACHED_AUDIO_NUM_INT": @[SE_PARAMS_KEY_TTS_MAX_CACHED_AUDIO_NUM_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_OFF_RESOURCE_PATH_STRING": @[SE_PARAMS_KEY_TTS_OFF_RESOURCE_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_PITCH_INT": @[SE_PARAMS_KEY_TTS_PITCH_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_PITCH_RATIO_DOUBLE": @[SE_PARAMS_KEY_TTS_PITCH_RATIO_DOUBLE, @"DOUBLE"],
      @"SE_PARAMS_KEY_TTS_PURE_ENGLISH_OPT_INT": @[SE_PARAMS_KEY_TTS_PURE_ENGLISH_OPT_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_RECV_TIMEOUT_INT": @[SE_PARAMS_KEY_TTS_RECV_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_REQUEST_ID_STRING": @[SE_PARAMS_KEY_TTS_REQUEST_ID_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_REQ_PARAMS_STRING": @[SE_PARAMS_KEY_TTS_REQ_PARAMS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_SAMPLE_RATE_INT": @[SE_PARAMS_KEY_TTS_SAMPLE_RATE_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_SCENARIO_STRING": @[SE_PARAMS_KEY_TTS_SCENARIO_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_SILENCE_DURATION_INT": @[SE_PARAMS_KEY_TTS_SILENCE_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_SPEED_INT": @[SE_PARAMS_KEY_TTS_SPEED_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_SPEED_RATIO_DOUBLE": @[SE_PARAMS_KEY_TTS_SPEED_RATIO_DOUBLE, @"DOUBLE"],
      @"SE_PARAMS_KEY_TTS_SPLIT_SENTENCE_INT": @[SE_PARAMS_KEY_TTS_SPLIT_SENTENCE_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_TEXT_STRING": @[SE_PARAMS_KEY_TTS_TEXT_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_TEXT_TYPE_STRING": @[SE_PARAMS_KEY_TTS_TEXT_TYPE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_URI_STRING": @[SE_PARAMS_KEY_TTS_URI_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_USE_VOICECLONE_BOOL": @[SE_PARAMS_KEY_TTS_USE_VOICECLONE_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_TTS_VOICE_OFFLINE_STRING": @[SE_PARAMS_KEY_TTS_VOICE_OFFLINE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_VOICE_ONLINE_STRING": @[SE_PARAMS_KEY_TTS_VOICE_ONLINE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_VOICE_TYPE_OFFLINE_STRING": @[SE_PARAMS_KEY_TTS_VOICE_TYPE_OFFLINE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_VOICE_TYPE_ONLINE_STRING": @[SE_PARAMS_KEY_TTS_VOICE_TYPE_ONLINE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_TTS_VOLUME_INT": @[SE_PARAMS_KEY_TTS_VOLUME_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_VOLUME_RATIO_DOUBLE": @[SE_PARAMS_KEY_TTS_VOLUME_RATIO_DOUBLE, @"DOUBLE"],
      @"SE_PARAMS_KEY_TTS_WITH_FRONTEND_INT": @[SE_PARAMS_KEY_TTS_WITH_FRONTEND_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_WITH_INTENT_BOOL": @[SE_PARAMS_KEY_TTS_WITH_INTENT_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_TTS_WITH_TIMESTAMP_INT": @[SE_PARAMS_KEY_TTS_WITH_TIMESTAMP_INT, @"INT"],
      @"SE_PARAMS_KEY_TTS_WORK_MODE_INT": @[SE_PARAMS_KEY_TTS_WORK_MODE_INT, @"INT"],
      @"SE_PARAMS_KEY_UID_STRING": @[SE_PARAMS_KEY_UID_STRING, @"STRING"],
      @"SE_PARAMS_KEY_UP_CHANNEL_NUM_INT": @[SE_PARAMS_KEY_UP_CHANNEL_NUM_INT, @"INT"],
      @"SE_PARAMS_KEY_VAD_HEAD_SILENCE_THRESHOLD_INT": @[SE_PARAMS_KEY_VAD_HEAD_SILENCE_THRESHOLD_INT, @"INT"],
      @"SE_PARAMS_KEY_VAD_MAX_MUSIC_DURATION_INT": @[SE_PARAMS_KEY_VAD_MAX_MUSIC_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_VAD_MAX_SPEECH_DURATION_INT": @[SE_PARAMS_KEY_VAD_MAX_SPEECH_DURATION_INT, @"INT"],
      @"SE_PARAMS_KEY_VAD_REC_PATH_STRING": @[SE_PARAMS_KEY_VAD_REC_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VAD_TAIL_SILENCE_THRESHOLD_INT": @[SE_PARAMS_KEY_VAD_TAIL_SILENCE_THRESHOLD_INT, @"INT"],
      @"SE_PARAMS_KEY_VOICECLONE_ADDRESS_STRING": @[SE_PARAMS_KEY_VOICECLONE_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECLONE_CONN_TIMEOUT_INT": @[SE_PARAMS_KEY_VOICECLONE_CONN_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_VOICECLONE_ENABLE_DUMP_BOOL": @[SE_PARAMS_KEY_VOICECLONE_ENABLE_DUMP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_VOICECLONE_GENDER_BOOL": @[SE_PARAMS_KEY_VOICECLONE_GENDER_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_VOICECLONE_QUERY_UIDS_STRING": @[SE_PARAMS_KEY_VOICECLONE_QUERY_UIDS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECLONE_RECV_TIMEOUT_INT": @[SE_PARAMS_KEY_VOICECLONE_RECV_TIMEOUT_INT, @"INT"],
      @"SE_PARAMS_KEY_VOICECLONE_REC_PATH_STRING": @[SE_PARAMS_KEY_VOICECLONE_REC_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECLONE_STREAM_ADDRESS_STRING": @[SE_PARAMS_KEY_VOICECLONE_STREAM_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECLONE_TASKID_INT": @[SE_PARAMS_KEY_VOICECLONE_TASKID_INT, @"INT"],
      @"SE_PARAMS_KEY_VOICECLONE_TEXT_SEQ_INT": @[SE_PARAMS_KEY_VOICECLONE_TEXT_SEQ_INT, @"INT"],
      @"SE_PARAMS_KEY_VOICECLONE_TEXT_STRING": @[SE_PARAMS_KEY_VOICECLONE_TEXT_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECLONE_VOICE_TYPE_STRING": @[SE_PARAMS_KEY_VOICECLONE_VOICE_TYPE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECONV_ADDRESS_STRING": @[SE_PARAMS_KEY_VOICECONV_ADDRESS_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECONV_AUDIO_PATH_STRING": @[SE_PARAMS_KEY_VOICECONV_AUDIO_PATH_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECONV_CLUSTER_STRING": @[SE_PARAMS_KEY_VOICECONV_CLUSTER_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECONV_ENABLE_RECORD_DUMP_BOOL": @[SE_PARAMS_KEY_VOICECONV_ENABLE_RECORD_DUMP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_VOICECONV_ENABLE_RESULT_DUMP_BOOL": @[SE_PARAMS_KEY_VOICECONV_ENABLE_RESULT_DUMP_BOOL, @"BOOL"],
      @"SE_PARAMS_KEY_VOICECONV_REQUEST_INTERVAL_INT": @[SE_PARAMS_KEY_VOICECONV_REQUEST_INTERVAL_INT, @"INT"],
      @"SE_PARAMS_KEY_VOICECONV_RESULT_SAMPLE_RATE_INT": @[SE_PARAMS_KEY_VOICECONV_RESULT_SAMPLE_RATE_INT, @"INT"],
      @"SE_PARAMS_KEY_VOICECONV_URI_STRING": @[SE_PARAMS_KEY_VOICECONV_URI_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECONV_VOICE_STRING": @[SE_PARAMS_KEY_VOICECONV_VOICE_STRING, @"STRING"],
      @"SE_PARAMS_KEY_VOICECONV_VOICE_TYPE_STRING": @[SE_PARAMS_KEY_VOICECONV_VOICE_TYPE_STRING, @"STRING"],
    };
  });
  return definitions;
}

@interface VolcSpeechTask : NSObject <SpeechEngineDelegate>
@property(nonatomic, copy) void (^callback)(SEMessageType, NSData *);
@property(nonatomic, strong) SpeechEngine *engine;
@property(nonatomic, copy) NSString *instanceId;
@property(nonatomic, copy) NSString *taskId;
@property(nonatomic, copy) NSString *sessionPayload;
@property(nonatomic, copy) RCTPromiseResolveBlock resolve;
@property(nonatomic, copy) RCTPromiseRejectBlock reject;
@property(nonatomic) BOOL tts;
@property(nonatomic) BOOL sessionRequested;
@property(nonatomic) BOOL finishing;
@property(nonatomic) BOOL synthesisEnded;
@property(nonatomic) NSUInteger synthesizedSentences;
@property(nonatomic) NSUInteger playedSentences;
@property(nonatomic) BOOL playEnded;
@end

@implementation VolcSpeechTask
- (void)onMessageWithType:(SEMessageType)type andData:(NSData *)data {
  if (self.callback) self.callback(type, data);
}
@end

@interface RNVolcengineSpeech : RCTEventEmitter
@property(nonatomic, strong) dispatch_queue_t speechQueue;
@property(nonatomic, strong) VolcSpeechTask *active;
@property(nonatomic) BOOL observing;
@end

@implementation RNVolcengineSpeech
RCT_EXPORT_MODULE(RNVolcengineSpeech)

+ (BOOL)requiresMainQueueSetup { return NO; }

- (instancetype)init {
  if ((self = [super init])) {
    _speechQueue = dispatch_queue_create("com.finstao.volcenginespeech", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (dispatch_queue_t)methodQueue { return self.speechQueue; }
- (NSArray<NSString *> *)supportedEvents { return @[@"RNVolcengineSpeechEvent"]; }
- (void)startObserving { self.observing = YES; }
- (void)stopObserving { self.observing = NO; }

- (void)emit:(VolcSpeechTask *)task type:(NSString *)type code:(NSInteger)code data:(NSString *)data {
  if (!self.observing) return;
  [self sendEventWithName:@"RNVolcengineSpeechEvent" body:@{
    @"instanceId": task.instanceId,
    @"taskId": task.taskId,
    @"type": type,
    @"payload": @{@"nativeCode": @(code), @"data": data ?: @""}
  }];
}

- (void)close:(VolcSpeechTask *)task code:(NSString *)code {
  if (self.active != task) return;
  self.active = nil;
  if (task.reject) task.reject(code, @"Speech task ended before becoming ready", nil);
  task.reject = nil;
  task.resolve = nil;
  [task.engine destroyEngine];
}

- (void)terminal:(VolcSpeechTask *)task type:(NSString *)type code:(NSInteger)code data:(NSString *)data {
  [self close:task code:@"E_NATIVE"];
  [self emit:task type:type code:code data:data];
}

- (void)finishPlaybackIfReady:(VolcSpeechTask *)task code:(SEMessageType)code data:(NSString *)data {
  // BiTTS reports playback per sentence, even after the session has finished synthesizing.
  if (task.synthesisEnded && (task.playEnded
      || (task.playedSentences > 0 && task.playedSentences >= task.synthesizedSentences))) {
    [self terminal:task type:@"playbackFinished" code:code data:data];
  }
}

- (void)ready:(VolcSpeechTask *)task code:(NSInteger)code data:(NSString *)data {
  if (!task.resolve) return;
  task.resolve(nil);
  task.resolve = nil;
  task.reject = nil;
  [self emit:task type:@"ready" code:code data:data];
}

- (void)handle:(VolcSpeechTask *)task code:(SEMessageType)code bytes:(NSData *)bytes {
  if (self.active != task) return;
  NSString *data = [[NSString alloc] initWithData:bytes ?: [NSData data] encoding:NSUTF8StringEncoding];
  switch (code) {
    case SEEngineStart:
      if (!task.tts) {
        [self ready:task code:code data:data];
      } else if (!task.sessionRequested) {
        task.sessionRequested = YES;
        NSInteger result = [task.engine sendDirective:SEDirectiveEventStartSession data:task.sessionPayload];
        if (result != 0) [self terminal:task type:@"error" code:result data:@""];
      }
      break;
    case SEEventSessionStarted: [self ready:task code:code data:data]; break;
    case SERecorderBegin: [self emit:task type:@"recordingStarted" code:code data:data]; break;
    case SERecorderEnd: [self emit:task type:@"inputEnded" code:code data:data]; break;
    case SEPartialResult: [self emit:task type:@"partialResult" code:code data:data]; break;
    case SEFinalResult: [self terminal:task type:@"finalResult" code:code data:data]; break;
    case SEVolumeLevel: [self emit:task type:@"volume" code:code data:data]; break;
    case SETtsStartPlaying:
    case SEPlayerStartPlayAudio:
      [self emit:task type:@"playbackStarted" code:code data:data];
      break;
    case SETtsFinishPlaying:
      task.playEnded = YES;
      [self finishPlaybackIfReady:task code:code data:data];
      break;
    case SEEventTTSSentenceEnd:
      task.synthesizedSentences++;
      break;
    case SEPlayerFinishPlayAudio:
      task.playedSentences++;
      [self finishPlaybackIfReady:task code:code data:data];
      break;
    case SEEventSessionFinished:
      task.synthesisEnded = YES;
      [self emit:task type:@"synthesisFinished" code:code data:data];
      [self finishPlaybackIfReady:task code:code data:data];
      break;
    case SEEngineStop:
    case SEEngineError:
    case SEEventSessionFailed: [self terminal:task type:@"error" code:code data:data]; break;
    default: break;
  }
}

static NSString *SpeechJSON(NSDictionary *payload, NSError **error) {
  if (!payload) return @"";
  NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:error];
  return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

- (void)start:(NSString *)instanceId taskId:(NSString *)taskId tts:(BOOL)tts
      payload:(NSDictionary *)payload options:(NSDictionary *)options
      resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  if (self.active) {
    reject(@"E_BUSY", @"A speech task already owns the native engine", nil);
    return;
  }
  NSError *error = nil;
  NSString *input = SpeechJSON(payload, &error);
  if (!input) {
    reject(@"E_INVALID_ARGUMENT", @"Invalid speech payload", error);
    return;
  }
  static BOOL prepared;
  @synchronized ([SpeechEngine class]) {
    if (!prepared) prepared = [SpeechEngine prepareEnvironment];
  }
  if (!prepared) {
    reject(@"E_NATIVE", @"Speech SDK environment failed", nil);
    return;
  }
  VolcSpeechTask *task = [VolcSpeechTask new];
  task.instanceId = instanceId;
  task.taskId = taskId;
  task.tts = tts;
  task.resolve = resolve;
  task.reject = reject;
  task.engine = [SpeechEngine new];
  __weak typeof(self) weakSelf = self;
  __weak VolcSpeechTask *weakTask = task;
  task.callback = ^(SEMessageType code, NSData *bytes) {
    RNVolcengineSpeech *owner = weakSelf;
    if (!owner) return;
    NSData *snapshot = [bytes copy];
    dispatch_async(owner.speechQueue, ^{
      VolcSpeechTask *current = weakTask;
      if (current) [owner handle:current code:code bytes:snapshot];
    });
  };
  if (![task.engine createEngineWithDelegate:task]) {
    reject(@"E_NATIVE", @"Failed to create SpeechEngine", nil);
    return;
  }
  self.active = task;
  for (NSString *key in options) {
    id value = options[key];
    NSArray *definition = SpeechOptionDefinitions()[key];
    NSString *nativeKey = definition.firstObject;
    NSString *type = definition.lastObject;
    BOOL number = [value isKindOfClass:[NSNumber class]];
    BOOL boolean = number && CFGetTypeID((__bridge CFTypeRef)value) == CFBooleanGetTypeID();
    if ([type isEqualToString:@"STRING"] && [value isKindOfClass:[NSString class]]) {
      [task.engine setStringParam:value forKey:nativeKey];
    } else if ([type isEqualToString:@"BOOL"] && boolean) {
      [task.engine setBoolParam:[value boolValue] forKey:nativeKey];
    } else if ([type isEqualToString:@"INT"] && number && !boolean &&
        [value doubleValue] == [value integerValue]) {
      [task.engine setIntParam:[value integerValue] forKey:nativeKey];
    } else if (([type isEqualToString:@"DOUBLE"] || [type isEqualToString:@"FLOAT"]) && number && !boolean) {
      [task.engine setDoubleParam:[value doubleValue] forKey:nativeKey];
    } else {
      [self close:task code:@"E_INVALID_ARGUMENT"];
      return;
    }
  }
  [task.engine setStringParam:(tts ? SE_BITTS_ENGINE : SE_ASR_ENGINE)
                       forKey:SE_PARAMS_KEY_ENGINE_NAME_STRING];
  if (!tts && payload) [task.engine setStringParam:input forKey:SE_PARAMS_KEY_ASR_REQ_PARAMS_STRING];
  task.sessionPayload = input;
  if (tts) {
    [task.engine setStringParam:input forKey:SE_PARAMS_KEY_START_ENGINE_PAYLOAD_STRING];
  }
  NSString *operation = @"initEngine";
  NSInteger result = [task.engine initEngine];
  if (result == 0) {
    operation = @"directive 1000";
    result = [task.engine sendDirective:SEDirectiveStartEngine data:tts ? input : @""];
  }
  if (result != 0) {
    task.reject = nil;
    [self close:task code:@"E_NATIVE"];
    reject(@"E_NATIVE", [NSString stringWithFormat:@"Speech SDK error %ld at %@", (long)result, operation], nil);
    return;
  }
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC), self.speechQueue, ^{
    if (self.active == task && task.reject) [self close:task code:@"E_TIMEOUT"];
  });
}

RCT_EXPORT_METHOD(invoke:(NSString *)operation instanceId:(NSString *)instanceId
                  taskId:(NSString *)taskId kind:(NSString *)kind payload:(NSDictionary *)payload
                  config:(NSDictionary *)config resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  if ([operation isEqualToString:@"start"]) {
    [self start:instanceId taskId:taskId tts:[kind isEqualToString:@"tts"]
        payload:payload options:config[@"ios"] resolve:resolve reject:reject];
    return;
  }
  VolcSpeechTask *task = self.active;
  BOOL ownsTask = task && [task.instanceId isEqualToString:instanceId]
      && (!taskId || [task.taskId isEqualToString:taskId]);
  BOOL cancel = [operation isEqualToString:@"cancel"];
  if (cancel || [operation isEqualToString:@"destroy"]) {
    if (ownsTask) {
      [self close:task code:@"E_CANCELLED"];
      if (cancel) [self emit:task type:@"cancelled" code:0 data:@""];
    }
    resolve(nil);
    return;
  }
  if (!ownsTask) {
    reject(@"E_INVALID_TASK", @"Speech task is inactive", nil);
    return;
  }
  NSInteger result;
  if ([operation isEqualToString:@"appendText"] && task.tts && !task.finishing) {
    NSError *error = nil;
    NSString *input = SpeechJSON(payload, &error);
    if (!input) {
      reject(@"E_INVALID_ARGUMENT", @"Invalid TTS payload", error);
      return;
    }
    result = [task.engine sendDirective:SEDirectiveEventTaskRequest data:input];
  } else if ([operation isEqualToString:@"finishInput"]) {
    result = task.finishing ? 0 : [task.engine sendDirective:
        (task.tts ? SEDirectiveEventFinishSession : SEDirectiveFinishTalking) data:@""];
    if (result == 0) task.finishing = YES;
  } else {
    reject(@"E_UNSUPPORTED", @"Unsupported speech operation", nil);
    return;
  }
  if (result == 0) resolve(nil);
  else reject(@"E_NATIVE", [NSString stringWithFormat:@"Speech SDK error %ld", (long)result], nil);
}

- (void)invalidate {
  dispatch_async(self.speechQueue, ^{
    if (self.active) [self close:self.active code:@"E_DESTROYED"];
  });
  [super invalidate];
}
@end

#endif
