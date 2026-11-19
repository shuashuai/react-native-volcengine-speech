import type { AndroidNativeOptions, IosNativeOptions } from './nativeOptions'

const iosKeys = {
  aec_enable_dump: 'SE_PARAMS_KEY_AEC_ENABLE_DUMP_BOOL',
  aec_model_path: 'SE_PARAMS_KEY_AEC_MODEL_PATH_STRING',
  aed_resource_path: 'SE_PARAMS_KEY_AED_RESOURCE_PATH_STRING',
  api_key: 'SE_PARAMS_KEY_API_KEY_STRING',
  appid: 'SE_PARAMS_KEY_APP_ID_STRING',
  appkey: 'SE_PARAMS_KEY_APP_KEY_STRING',
  asr_address: 'SE_PARAMS_KEY_ASR_ADDRESS_STRING',
  asr_auto_stop: 'SE_PARAMS_KEY_ASR_AUTO_STOP_BOOL',
  asr_cluster: 'SE_PARAMS_KEY_ASR_CLUSTER_STRING',
  asr_conn_timeout: 'SE_PARAMS_KEY_ASR_CONN_TIMEOUT_INT',
  asr_correct_words: 'SE_PARAMS_KEY_ASR_CORRECT_WORDS_STRING',
  asr_disable_end_punc: 'SE_PARAMS_KEY_ASR_DISABLE_END_PUNC_BOOL',
  asr_enable_ddc: 'SE_PARAMS_KEY_ASR_ENABLE_DDC_BOOL',
  asr_enable_itn: 'SE_PARAMS_KEY_ASR_ENABLE_ITN_BOOL',
  asr_keep_recording: 'SE_PARAMS_KEY_ASR_KEEP_RECORDING_BOOL',
  asr_language: 'SE_PARAMS_KEY_ASR_LANGUAGE_STRING',
  asr_max_retry_times: 'SE_PARAMS_KEY_ASR_MAX_RETRY_TIMES_INT',
  asr_off_resource_path: 'SE_PARAMS_KEY_ASR_OFF_RESOURCE_PATH_STRING',
  asr_package_size: 'SE_PARAMS_KEY_ASR_PACKAGE_SIZE_INT',
  asr_rec_path: 'SE_PARAMS_KEY_ASR_REC_PATH_STRING',
  asr_recv_timeout: 'SE_PARAMS_KEY_ASR_RECV_TIMEOUT_INT',
  asr_req_params: 'SE_PARAMS_KEY_ASR_REQ_PARAMS_STRING',
  asr_result_type: 'SE_PARAMS_KEY_ASR_RESULT_TYPE_STRING',
  asr_scenario: 'SE_PARAMS_KEY_ASR_SCENARIO_INT',
  asr_show_language: 'SE_PARAMS_KEY_ASR_SHOW_LANG_BOOL',
  asr_show_nlu_punctuation: 'SE_PARAMS_KEY_ASR_SHOW_NLU_PUNC_BOOL',
  asr_show_punctuation: 'SE_PARAMS_KEY_ASR_SHOW_PUNC_BOOL',
  asr_show_utterances: 'SE_PARAMS_KEY_ASR_SHOW_UTTER_BOOL',
  asr_show_volume: 'SE_PARAMS_KEY_ASR_SHOW_VOLUME_BOOL',
  asr_uri: 'SE_PARAMS_KEY_ASR_URI_STRING',
  asr_vad_end_silence_time: 'SE_PARAMS_KEY_ASR_VAD_END_SILENCE_TIME_INT',
  asr_vad_mode: 'SE_PARAMS_KEY_ASR_VAD_MODE_STRING',
  asr_vad_start_silence_time: 'SE_PARAMS_KEY_ASR_VAD_START_SILENCE_TIME_INT',
  asr_work_mode: 'SE_PARAMS_KEY_ASR_WORK_MODE_INT',
  au_ability: 'SE_PARAMS_KEY_AU_ABILITY_INT',
  au_address: 'SE_PARAMS_KEY_AU_ADDRESS_STRING',
  au_audio_packet_duration: 'SE_PARAMS_KEY_AU_AUDIO_PACKET_DURATION_INT',
  au_auto_stop: 'SE_PARAMS_KEY_AU_AUTO_STOP_BOOL',
  au_cluster: 'SE_PARAMS_KEY_AU_CLUSTER_STRING',
  au_conn_timeout: 'SE_PARAMS_KEY_AU_CONN_TIMEOUT_INT',
  au_empty_packet_interval: 'SE_PARAMS_KEY_AU_EMPTY_PACKET_INTERVAL_INT',
  au_process_timeout: 'SE_PARAMS_KEY_AU_PROCESS_TIMEOUT_INT',
  au_rec_path: 'SE_PARAMS_KEY_AU_REC_PATH_STRING',
  au_recv_timeout: 'SE_PARAMS_KEY_AU_RECV_TIMEOUT_INT',
  au_uri: 'SE_PARAMS_KEY_AU_URI_STRING',
  audio_fadeout_duration: 'SE_PARAMS_KEY_AUDIO_FADEOUT_DURATION_INT',
  authenticate_address: 'SE_PARAMS_KEY_AUTHENTICATE_ADDRESS_STRING',
  authenticate_secret: 'SE_PARAMS_KEY_AUTHENTICATE_SECRET_STRING',
  authenticate_type: 'SE_PARAMS_KEY_AUTHENTICATE_TYPE_STRING',
  authenticate_uri: 'SE_PARAMS_KEY_AUTHENTICATE_URI_STRING',
  business_key: 'SE_PARAMS_KEY_BUSINESS_KEY_STRING',
  capt_address: 'SE_PARAMS_KEY_CAPT_ADDRESS_STRING',
  capt_auto_stop: 'SE_PARAMS_KEY_CAPT_AUTO_STOP_BOOL',
  capt_cluster: 'SE_PARAMS_KEY_CAPT_CLUSTER_STRING',
  capt_conn_timeout: 'SE_PARAMS_KEY_CAPT_CONN_TIMEOUT_INT',
  capt_core_type: 'SE_PARAMS_KEY_CAPT_CORE_TYPE_STRING',
  capt_difficulty: 'SE_PARAMS_KEY_CAPT_DIFFICULTY_INT',
  capt_rec_path: 'SE_PARAMS_KEY_CAPT_REC_PATH_STRING',
  capt_recv_timeout: 'SE_PARAMS_KEY_CAPT_RECV_TIMEOUT_INT',
  capt_ref_text: 'SE_PARAMS_KEY_CAPT_REFER_TEXT_STRING',
  capt_response_mode: 'SE_PARAMS_KEY_CAPT_RESPONSE_MODE_STRING',
  capt_scene: 'SE_PARAMS_KEY_CAPT_SCENE_STRING',
  capt_uri: 'SE_PARAMS_KEY_CAPT_URI_STRING',
  channel: 'SE_PARAMS_KEY_CHANNEL_NUM_INT',
  custom_channel: 'SE_PARAMS_KEY_CUSTOM_CHANNEL_INT',
  custom_sample_rate: 'SE_PARAMS_KEY_CUSTOM_SAMPLE_RATE_INT',
  debug_path: 'SE_PARAMS_KEY_DEBUG_PATH_STRING',
  device_id: 'SE_PARAMS_KEY_DEVICE_ID_STRING',
  dialog_address: 'SE_PARAMS_KEY_DIALOG_ADDRESS_STRING',
  dialog_enable_decoder_audio_callback: 'SE_PARAMS_KEY_DIALOG_ENABLE_DECODER_AUDIO_CALLBACK_BOOL',
  dialog_enable_player: 'SE_PARAMS_KEY_DIALOG_ENABLE_PLAYER_BOOL',
  dialog_enable_player_audio_callback: 'SE_PARAMS_KEY_DIALOG_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL',
  dialog_enable_recorder_audio_callback: 'SE_PARAMS_KEY_DIALOG_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL',
  dialog_player_path: 'SE_PARAMS_KEY_DIALOG_PLAYER_PATH_STRING',
  dialog_recorder_path: 'SE_PARAMS_KEY_DIALOG_RECORDER_PATH_STRING',
  dialog_uri: 'SE_PARAMS_KEY_DIALOG_URI_STRING',
  dialog_work_mode: 'SE_PARAMS_KEY_DIALOG_WORK_MODE_INT',
  enable_aec: 'SE_PARAMS_KEY_ENABLE_AEC_BOOL',
  enable_custom_ws_client: 'SE_PARAMS_KEY_ENABLE_CUSTOM_WS_CLIENT_BOOL',
  enable_get_volume: 'SE_PARAMS_KEY_ENABLE_GET_VOLUME_BOOL',
  enable_player_audio_callback: 'SE_PARAMS_KEY_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL',
  enable_rec_audio_callback: 'SE_PARAMS_KEY_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL',
  enable_resampler: 'SE_PARAMS_KEY_ENABLE_RESAMPLER_BOOL',
  enable_resume_from_previous_progress: 'SE_PARAMS_KEY_ENABLE_RESUME_FROM_PREVIOUS_PROGRESS_BOOL',
  enable_ws_reconnect: 'SE_PARAMS_KEY_ENABLE_WS_RECONNECT_BOOL',
  fingerprint_slice_duration: 'SE_PARAMS_KEY_FINGERPRINT_SLICE_DURATION_INT',
  fulllink_address: 'SE_PARAMS_KEY_FULLLINK_ADDRESS_STRING',
  fulllink_asr_auto_stop: 'SE_PARAMS_KEY_FULLLINK_ASR_AUTO_STOP_BOOL',
  fulllink_asr_only: 'SE_PARAMS_KEY_FULLLINK_ASR_ONLY_BOOL',
  fulllink_cluster: 'SE_PARAMS_KEY_FULLLINK_CLUSTER_STRING',
  fulllink_conn_timeout: 'SE_PARAMS_KEY_FULLLINK_CONN_TIMEOUT_INT',
  fulllink_disable_tts: 'SE_PARAMS_KEY_FULLLINK_DISABLE_TTS_BOOL',
  fulllink_query_string: 'SE_PARAMS_KEY_FULLLINK_QUERY_STRING_STRING',
  fulllink_recv_timeout: 'SE_PARAMS_KEY_FULLLINK_RECV_TIMEOUT_INT',
  fulllink_scene_id: 'SE_PARAMS_KEY_FULLLINK_SCENE_ID_STRING',
  fulllink_uri: 'SE_PARAMS_KEY_FULLLINK_URI_STRING',
  fulllink_user_param: 'SE_PARAMS_KEY_FULLLINK_USER_PARAM_STRING',
  fulllink_vad_head_wait_time: 'SE_PARAMS_KEY_FULLLINK_VAD_HEAD_WAIT_TIME_INT',
  kws_enable_vad: 'SE_PARAMS_KEY_KWS_ENABLE_VAD_BOOL',
  kws_root_path: 'SE_PARAMS_KEY_KWS_ROOT_PATH_STRING',
  kws_user_param: 'SE_PARAMS_KEY_KWS_USER_PARAM_STRING',
  kws_vad_end_silence_timeout: 'SE_PARAMS_KEY_KWS_VAD_END_SILENCE_TIMEOUT_INT',
  license_busi_id: 'SE_PARAMS_KEY_LICENSE_BUSI_ID_STRING',
  license_directory: 'SE_PARAMS_KEY_LICENSE_DIRECTORY_STRING',
  license_name: 'SE_PARAMS_KEY_LICENSE_NAME_STRING',
  log_level: 'SE_PARAMS_KEY_LOG_LEVEL_STRING',
  prevent_player_creation: 'SE_PARAMS_KEY_PREVENT_PLAYER_CREATION_BOOL',
  protocol_type: 'SE_PARAMS_KEY_PROTOCOL_TYPE_INT',
  rec_file_type: 'SE_PARAMS_KEY_REC_FILE_TYPE_INT',
  rec_path: 'SE_PARAMS_KEY_REC_PATH_STRING',
  recorder_data_source_type: 'SE_PARAMS_KEY_RECORDER_TYPE_STRING',
  recorder_file: 'SE_PARAMS_KEY_RECORDER_FILE_STRING',
  request_headers: 'SE_PARAMS_KEY_REQUEST_HEADERS_STRING',
  resource_id: 'SE_PARAMS_KEY_RESOURCE_ID_STRING',
  sample_rate: 'SE_PARAMS_KEY_SAMPLE_RATE_INT',
  signal_root_path: 'SE_PARAMS_KEY_SIGNAL_ROOT_PATH_STRING',
  token: 'SE_PARAMS_KEY_APP_TOKEN_STRING',
  tts_address: 'SE_PARAMS_KEY_TTS_ADDRESS_STRING',
  tts_audio_cache_path: 'SE_PARAMS_KEY_TTS_AUDIO_CACHE_PATH_STRING',
  tts_audio_file: 'SE_PARAMS_KEY_TTS_AUDIO_FILE_STRING',
  tts_audio_path: 'SE_PARAMS_KEY_TTS_AUDIO_PATH_STRING',
  tts_backend_cluster: 'SE_PARAMS_KEY_TTS_BACKEND_CLUSTER_STRING',
  tts_business: 'SE_PARAMS_KEY_TTS_BUSINESS_STRING',
  tts_cache_renewal_duration: 'SE_PARAMS_KEY_TTS_CACHE_RENEWAL_DURATION_INT',
  tts_cluster: 'SE_PARAMS_KEY_TTS_CLUSTER_STRING',
  tts_compression_rate: 'SE_PARAMS_KEY_TTS_COMPRESSION_RATE_INT',
  tts_concurrency_mode: 'SE_PARAMS_KEY_TTS_CONCURRENCY_MODE_INT',
  tts_conn_timeout: 'SE_PARAMS_KEY_TTS_CONN_TIMEOUT_INT',
  tts_data_callback_mode: 'SE_PARAMS_KEY_TTS_DATA_CALLBACK_MODE_INT',
  tts_emotion: 'SE_PARAMS_KEY_TTS_EMOTION_STRING',
  tts_enable_cache: 'SE_PARAMS_KEY_TTS_ENABLE_CACHE_BOOL',
  tts_enable_dump: 'SE_PARAMS_KEY_TTS_ENABLE_DUMP_BOOL',
  tts_enable_player: 'SE_PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL',
  tts_fadein_duration: 'SE_PARAMS_KEY_TTS_FADEIN_DURATION_INT',
  tts_fadeout_duration: 'SE_PARAMS_KEY_TTS_FADEOUT_DURATION_INT',
  tts_frontend_type: 'SE_PARAMS_KEY_TTS_FRONTEND_TYPE_STRING',
  tts_language_online: 'SE_PARAMS_KEY_TTS_LANGUAGE_ONLINE_STRING',
  tts_limit_cpu_usage: 'SE_PARAMS_KEY_TTS_LIMIT_CPU_USAGE_BOOL',
  tts_max_cached_audio_num: 'SE_PARAMS_KEY_TTS_MAX_CACHED_AUDIO_NUM_INT',
  tts_pitch: 'SE_PARAMS_KEY_TTS_PITCH_INT',
  tts_pitch_ratio: 'SE_PARAMS_KEY_TTS_PITCH_RATIO_DOUBLE',
  tts_pure_english_opt: 'SE_PARAMS_KEY_TTS_PURE_ENGLISH_OPT_INT',
  tts_rate: 'SE_PARAMS_KEY_TTS_SAMPLE_RATE_INT',
  tts_recv_timeout: 'SE_PARAMS_KEY_TTS_RECV_TIMEOUT_INT',
  tts_req_id: 'SE_PARAMS_KEY_TTS_REQUEST_ID_STRING',
  tts_req_params: 'SE_PARAMS_KEY_TTS_REQ_PARAMS_STRING',
  tts_scenario: 'SE_PARAMS_KEY_TTS_SCENARIO_STRING',
  tts_silence_duration: 'SE_PARAMS_KEY_TTS_SILENCE_DURATION_INT',
  tts_speed: 'SE_PARAMS_KEY_TTS_SPEED_INT',
  tts_speed_ratio: 'SE_PARAMS_KEY_TTS_SPEED_RATIO_DOUBLE',
  tts_split_sentence: 'SE_PARAMS_KEY_TTS_SPLIT_SENTENCE_INT',
  tts_text: 'SE_PARAMS_KEY_TTS_TEXT_STRING',
  tts_text_type: 'SE_PARAMS_KEY_TTS_TEXT_TYPE_STRING',
  tts_uri: 'SE_PARAMS_KEY_TTS_URI_STRING',
  tts_use_voiceclone: 'SE_PARAMS_KEY_TTS_USE_VOICECLONE_BOOL',
  tts_voice_offline: 'SE_PARAMS_KEY_TTS_VOICE_OFFLINE_STRING',
  tts_voice_online: 'SE_PARAMS_KEY_TTS_VOICE_ONLINE_STRING',
  tts_voice_type_offline: 'SE_PARAMS_KEY_TTS_VOICE_TYPE_OFFLINE_STRING',
  tts_voice_type_online: 'SE_PARAMS_KEY_TTS_VOICE_TYPE_ONLINE_STRING',
  tts_volume: 'SE_PARAMS_KEY_TTS_VOLUME_INT',
  tts_volume_ratio: 'SE_PARAMS_KEY_TTS_VOLUME_RATIO_DOUBLE',
  tts_with_frontend: 'SE_PARAMS_KEY_TTS_WITH_FRONTEND_INT',
  tts_with_intent: 'SE_PARAMS_KEY_TTS_WITH_INTENT_BOOL',
  tts_with_timestamp: 'SE_PARAMS_KEY_TTS_WITH_TIMESTAMP_INT',
  tts_work_mode: 'SE_PARAMS_KEY_TTS_WORK_MODE_INT',
  uid: 'SE_PARAMS_KEY_UID_STRING',
  up_channel: 'SE_PARAMS_KEY_UP_CHANNEL_NUM_INT',
  vad_max_music_duration: 'SE_PARAMS_KEY_VAD_MAX_MUSIC_DURATION_INT',
  vad_max_speech_duration: 'SE_PARAMS_KEY_VAD_MAX_SPEECH_DURATION_INT',
  vad_rec_path: 'SE_PARAMS_KEY_VAD_REC_PATH_STRING',
  voiceclone_address: 'SE_PARAMS_KEY_VOICECLONE_ADDRESS_STRING',
  voiceclone_conn_timeout: 'SE_PARAMS_KEY_VOICECLONE_CONN_TIMEOUT_INT',
  voiceclone_enable_dump: 'SE_PARAMS_KEY_VOICECLONE_ENABLE_DUMP_BOOL',
  voiceclone_gender: 'SE_PARAMS_KEY_VOICECLONE_GENDER_BOOL',
  voiceclone_query_uids: 'SE_PARAMS_KEY_VOICECLONE_QUERY_UIDS_STRING',
  voiceclone_rec_path: 'SE_PARAMS_KEY_VOICECLONE_REC_PATH_STRING',
  voiceclone_recv_timeout: 'SE_PARAMS_KEY_VOICECLONE_RECV_TIMEOUT_INT',
  voiceclone_stream_address: 'SE_PARAMS_KEY_VOICECLONE_STREAM_ADDRESS_STRING',
  voiceclone_taskid: 'SE_PARAMS_KEY_VOICECLONE_TASKID_INT',
  voiceclone_text: 'SE_PARAMS_KEY_VOICECLONE_TEXT_STRING',
  voiceclone_text_seq: 'SE_PARAMS_KEY_VOICECLONE_TEXT_SEQ_INT',
  voiceclone_voice_type: 'SE_PARAMS_KEY_VOICECLONE_VOICE_TYPE_STRING',
  voiceconv_address: 'SE_PARAMS_KEY_VOICECONV_ADDRESS_STRING',
  voiceconv_audio_path: 'SE_PARAMS_KEY_VOICECONV_AUDIO_PATH_STRING',
  voiceconv_cluster: 'SE_PARAMS_KEY_VOICECONV_CLUSTER_STRING',
  voiceconv_enable_record_dump: 'SE_PARAMS_KEY_VOICECONV_ENABLE_RECORD_DUMP_BOOL',
  voiceconv_enable_result_dump: 'SE_PARAMS_KEY_VOICECONV_ENABLE_RESULT_DUMP_BOOL',
  voiceconv_request_interval: 'SE_PARAMS_KEY_VOICECONV_REQUEST_INTERVAL_INT',
  voiceconv_result_sample_rate: 'SE_PARAMS_KEY_VOICECONV_RESULT_SAMPLE_RATE_INT',
  voiceconv_uri: 'SE_PARAMS_KEY_VOICECONV_URI_STRING',
  voiceconv_voice: 'SE_PARAMS_KEY_VOICECONV_VOICE_STRING',
  voiceconv_voice_type: 'SE_PARAMS_KEY_VOICECONV_VOICE_TYPE_STRING',
} as const satisfies Partial<Record<keyof AndroidNativeOptions, keyof IosNativeOptions>>

export type SharedOptions = Pick<AndroidNativeOptions, keyof typeof iosKeys>

type SharedOptionsWithoutPrefix<Prefix extends string> =
  Omit<SharedOptions, Extract<keyof SharedOptions, `${Prefix}_${string}`>>

export interface NativeSpeechConfig {
  readonly android?: AndroidNativeOptions
  readonly ios?: IosNativeOptions
}

export type TtsConfig = SharedOptionsWithoutPrefix<'asr'> & NativeSpeechConfig
export type AsrConfig = SharedOptionsWithoutPrefix<'tts'> & NativeSpeechConfig

// SDK 默认值；不是服务端默认值。资源和凭证由调用方明确选择。
export const DEFAULT_TTS_CONFIG = Object.freeze({
  tts_address: 'wss://openspeech.bytedance.com',
  tts_uri: '/api/v3/tts/bidirection',
  tts_enable_player: true,
  debug_path: '',
  tts_conn_timeout: 10000,
  request_headers: '{}',
  enable_player_audio_callback: false,
  tts_audio_path: '',
} satisfies TtsConfig)

export const DEFAULT_ASR_CONFIG = Object.freeze({
  asr_address: 'wss://openspeech.bytedance.com',
  asr_uri: '/api/v3/sauc/bigmodel_nostream',
  protocol_type: 1,
  recorder_data_source_type: 'Recorder',
  enable_get_volume: true,
} satisfies AsrConfig)

function definedOptions<T extends object>(options?: T): Partial<T> {
  return Object.fromEntries(
    Object.entries(options ?? {}).filter(([, value]) => value !== undefined),
  ) as Partial<T>
}

export function resolveNativeConfig(
  config: TtsConfig | AsrConfig,
  kind?: 'tts' | 'asr',
): NativeSpeechConfig {
  let defaults: SharedOptions = {}
  if (kind === 'tts') {
    defaults = DEFAULT_TTS_CONFIG
  }
  else if (kind === 'asr') {
    defaults = DEFAULT_ASR_CONFIG
  }
  const options: SharedOptions = { ...defaults, ...definedOptions(config) }
  const android: Record<string, string | number | boolean> = {}
  const ios: Record<string, string | number | boolean> = {}

  for (const key of Object.keys(iosKeys) as (keyof SharedOptions)[]) {
    const value = options[key]

    if (value !== undefined) {
      android[key] = value
      ios[iosKeys[key]] = value
    }
  }

  return {
    android: { ...android, ...definedOptions(config.android) },
    ios: { ...ios, ...definedOptions(config.ios) },
  }
}
