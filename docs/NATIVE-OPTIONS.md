# 原生初始化选项（SpeechEngine 0.0.15.0）

共有字段写在初始化对象顶层。SDK 使用以下映射在两端传递同一个值。是否生效仍由当前语音引擎和服务资源决定，例如 `asr_*` 用于 ASR，`tts_*` 用于 TTS。

| 公共字段（Android 原生键） | iOS 原生常量 | 类型 |
| --- | --- | --- |
| `aec_enable_dump` | `SE_PARAMS_KEY_AEC_ENABLE_DUMP_BOOL` | `boolean` |
| `aec_model_path` | `SE_PARAMS_KEY_AEC_MODEL_PATH_STRING` | `string` |
| `aed_resource_path` | `SE_PARAMS_KEY_AED_RESOURCE_PATH_STRING` | `string` |
| `api_key` | `SE_PARAMS_KEY_API_KEY_STRING` | `string` |
| `appid` | `SE_PARAMS_KEY_APP_ID_STRING` | `string` |
| `appkey` | `SE_PARAMS_KEY_APP_KEY_STRING` | `string` |
| `asr_address` | `SE_PARAMS_KEY_ASR_ADDRESS_STRING` | `string` |
| `asr_auto_stop` | `SE_PARAMS_KEY_ASR_AUTO_STOP_BOOL` | `boolean` |
| `asr_cluster` | `SE_PARAMS_KEY_ASR_CLUSTER_STRING` | `string` |
| `asr_conn_timeout` | `SE_PARAMS_KEY_ASR_CONN_TIMEOUT_INT` | `number` |
| `asr_correct_words` | `SE_PARAMS_KEY_ASR_CORRECT_WORDS_STRING` | `string` |
| `asr_disable_end_punc` | `SE_PARAMS_KEY_ASR_DISABLE_END_PUNC_BOOL` | `boolean` |
| `asr_enable_ddc` | `SE_PARAMS_KEY_ASR_ENABLE_DDC_BOOL` | `boolean` |
| `asr_enable_itn` | `SE_PARAMS_KEY_ASR_ENABLE_ITN_BOOL` | `boolean` |
| `asr_keep_recording` | `SE_PARAMS_KEY_ASR_KEEP_RECORDING_BOOL` | `boolean` |
| `asr_language` | `SE_PARAMS_KEY_ASR_LANGUAGE_STRING` | `string` |
| `asr_max_retry_times` | `SE_PARAMS_KEY_ASR_MAX_RETRY_TIMES_INT` | `number` |
| `asr_off_resource_path` | `SE_PARAMS_KEY_ASR_OFF_RESOURCE_PATH_STRING` | `string` |
| `asr_package_size` | `SE_PARAMS_KEY_ASR_PACKAGE_SIZE_INT` | `number` |
| `asr_rec_path` | `SE_PARAMS_KEY_ASR_REC_PATH_STRING` | `string` |
| `asr_recv_timeout` | `SE_PARAMS_KEY_ASR_RECV_TIMEOUT_INT` | `number` |
| `asr_req_params` | `SE_PARAMS_KEY_ASR_REQ_PARAMS_STRING` | `string` |
| `asr_result_type` | `SE_PARAMS_KEY_ASR_RESULT_TYPE_STRING` | `string` |
| `asr_scenario` | `SE_PARAMS_KEY_ASR_SCENARIO_INT` | `number` |
| `asr_show_language` | `SE_PARAMS_KEY_ASR_SHOW_LANG_BOOL` | `boolean` |
| `asr_show_nlu_punctuation` | `SE_PARAMS_KEY_ASR_SHOW_NLU_PUNC_BOOL` | `boolean` |
| `asr_show_punctuation` | `SE_PARAMS_KEY_ASR_SHOW_PUNC_BOOL` | `boolean` |
| `asr_show_utterances` | `SE_PARAMS_KEY_ASR_SHOW_UTTER_BOOL` | `boolean` |
| `asr_show_volume` | `SE_PARAMS_KEY_ASR_SHOW_VOLUME_BOOL` | `boolean` |
| `asr_uri` | `SE_PARAMS_KEY_ASR_URI_STRING` | `string` |
| `asr_vad_end_silence_time` | `SE_PARAMS_KEY_ASR_VAD_END_SILENCE_TIME_INT` | `number` |
| `asr_vad_mode` | `SE_PARAMS_KEY_ASR_VAD_MODE_STRING` | `string` |
| `asr_vad_start_silence_time` | `SE_PARAMS_KEY_ASR_VAD_START_SILENCE_TIME_INT` | `number` |
| `asr_work_mode` | `SE_PARAMS_KEY_ASR_WORK_MODE_INT` | `number` |
| `au_ability` | `SE_PARAMS_KEY_AU_ABILITY_INT` | `number` |
| `au_address` | `SE_PARAMS_KEY_AU_ADDRESS_STRING` | `string` |
| `au_audio_packet_duration` | `SE_PARAMS_KEY_AU_AUDIO_PACKET_DURATION_INT` | `number` |
| `au_auto_stop` | `SE_PARAMS_KEY_AU_AUTO_STOP_BOOL` | `boolean` |
| `au_cluster` | `SE_PARAMS_KEY_AU_CLUSTER_STRING` | `string` |
| `au_conn_timeout` | `SE_PARAMS_KEY_AU_CONN_TIMEOUT_INT` | `number` |
| `au_empty_packet_interval` | `SE_PARAMS_KEY_AU_EMPTY_PACKET_INTERVAL_INT` | `number` |
| `au_process_timeout` | `SE_PARAMS_KEY_AU_PROCESS_TIMEOUT_INT` | `number` |
| `au_rec_path` | `SE_PARAMS_KEY_AU_REC_PATH_STRING` | `string` |
| `au_recv_timeout` | `SE_PARAMS_KEY_AU_RECV_TIMEOUT_INT` | `number` |
| `au_uri` | `SE_PARAMS_KEY_AU_URI_STRING` | `string` |
| `audio_fadeout_duration` | `SE_PARAMS_KEY_AUDIO_FADEOUT_DURATION_INT` | `number` |
| `authenticate_address` | `SE_PARAMS_KEY_AUTHENTICATE_ADDRESS_STRING` | `string` |
| `authenticate_secret` | `SE_PARAMS_KEY_AUTHENTICATE_SECRET_STRING` | `string` |
| `authenticate_type` | `SE_PARAMS_KEY_AUTHENTICATE_TYPE_STRING` | `string` |
| `authenticate_uri` | `SE_PARAMS_KEY_AUTHENTICATE_URI_STRING` | `string` |
| `business_key` | `SE_PARAMS_KEY_BUSINESS_KEY_STRING` | `string` |
| `capt_address` | `SE_PARAMS_KEY_CAPT_ADDRESS_STRING` | `string` |
| `capt_auto_stop` | `SE_PARAMS_KEY_CAPT_AUTO_STOP_BOOL` | `boolean` |
| `capt_cluster` | `SE_PARAMS_KEY_CAPT_CLUSTER_STRING` | `string` |
| `capt_conn_timeout` | `SE_PARAMS_KEY_CAPT_CONN_TIMEOUT_INT` | `number` |
| `capt_core_type` | `SE_PARAMS_KEY_CAPT_CORE_TYPE_STRING` | `string` |
| `capt_difficulty` | `SE_PARAMS_KEY_CAPT_DIFFICULTY_INT` | `number` |
| `capt_rec_path` | `SE_PARAMS_KEY_CAPT_REC_PATH_STRING` | `string` |
| `capt_recv_timeout` | `SE_PARAMS_KEY_CAPT_RECV_TIMEOUT_INT` | `number` |
| `capt_ref_text` | `SE_PARAMS_KEY_CAPT_REFER_TEXT_STRING` | `string` |
| `capt_response_mode` | `SE_PARAMS_KEY_CAPT_RESPONSE_MODE_STRING` | `string` |
| `capt_scene` | `SE_PARAMS_KEY_CAPT_SCENE_STRING` | `string` |
| `capt_uri` | `SE_PARAMS_KEY_CAPT_URI_STRING` | `string` |
| `channel` | `SE_PARAMS_KEY_CHANNEL_NUM_INT` | `number` |
| `custom_channel` | `SE_PARAMS_KEY_CUSTOM_CHANNEL_INT` | `number` |
| `custom_sample_rate` | `SE_PARAMS_KEY_CUSTOM_SAMPLE_RATE_INT` | `number` |
| `debug_path` | `SE_PARAMS_KEY_DEBUG_PATH_STRING` | `string` |
| `device_id` | `SE_PARAMS_KEY_DEVICE_ID_STRING` | `string` |
| `dialog_address` | `SE_PARAMS_KEY_DIALOG_ADDRESS_STRING` | `string` |
| `dialog_enable_decoder_audio_callback` | `SE_PARAMS_KEY_DIALOG_ENABLE_DECODER_AUDIO_CALLBACK_BOOL` | `boolean` |
| `dialog_enable_player` | `SE_PARAMS_KEY_DIALOG_ENABLE_PLAYER_BOOL` | `boolean` |
| `dialog_enable_player_audio_callback` | `SE_PARAMS_KEY_DIALOG_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL` | `boolean` |
| `dialog_enable_recorder_audio_callback` | `SE_PARAMS_KEY_DIALOG_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL` | `boolean` |
| `dialog_player_path` | `SE_PARAMS_KEY_DIALOG_PLAYER_PATH_STRING` | `string` |
| `dialog_recorder_path` | `SE_PARAMS_KEY_DIALOG_RECORDER_PATH_STRING` | `string` |
| `dialog_uri` | `SE_PARAMS_KEY_DIALOG_URI_STRING` | `string` |
| `dialog_work_mode` | `SE_PARAMS_KEY_DIALOG_WORK_MODE_INT` | `number` |
| `enable_aec` | `SE_PARAMS_KEY_ENABLE_AEC_BOOL` | `boolean` |
| `enable_custom_ws_client` | `SE_PARAMS_KEY_ENABLE_CUSTOM_WS_CLIENT_BOOL` | `boolean` |
| `enable_get_volume` | `SE_PARAMS_KEY_ENABLE_GET_VOLUME_BOOL` | `boolean` |
| `enable_player_audio_callback` | `SE_PARAMS_KEY_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL` | `boolean` |
| `enable_rec_audio_callback` | `SE_PARAMS_KEY_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL` | `boolean` |
| `enable_resampler` | `SE_PARAMS_KEY_ENABLE_RESAMPLER_BOOL` | `boolean` |
| `enable_resume_from_previous_progress` | `SE_PARAMS_KEY_ENABLE_RESUME_FROM_PREVIOUS_PROGRESS_BOOL` | `boolean` |
| `enable_ws_reconnect` | `SE_PARAMS_KEY_ENABLE_WS_RECONNECT_BOOL` | `boolean` |
| `fingerprint_slice_duration` | `SE_PARAMS_KEY_FINGERPRINT_SLICE_DURATION_INT` | `number` |
| `fulllink_address` | `SE_PARAMS_KEY_FULLLINK_ADDRESS_STRING` | `string` |
| `fulllink_asr_auto_stop` | `SE_PARAMS_KEY_FULLLINK_ASR_AUTO_STOP_BOOL` | `boolean` |
| `fulllink_asr_only` | `SE_PARAMS_KEY_FULLLINK_ASR_ONLY_BOOL` | `boolean` |
| `fulllink_cluster` | `SE_PARAMS_KEY_FULLLINK_CLUSTER_STRING` | `string` |
| `fulllink_conn_timeout` | `SE_PARAMS_KEY_FULLLINK_CONN_TIMEOUT_INT` | `number` |
| `fulllink_disable_tts` | `SE_PARAMS_KEY_FULLLINK_DISABLE_TTS_BOOL` | `boolean` |
| `fulllink_query_string` | `SE_PARAMS_KEY_FULLLINK_QUERY_STRING_STRING` | `string` |
| `fulllink_recv_timeout` | `SE_PARAMS_KEY_FULLLINK_RECV_TIMEOUT_INT` | `number` |
| `fulllink_scene_id` | `SE_PARAMS_KEY_FULLLINK_SCENE_ID_STRING` | `string` |
| `fulllink_uri` | `SE_PARAMS_KEY_FULLLINK_URI_STRING` | `string` |
| `fulllink_user_param` | `SE_PARAMS_KEY_FULLLINK_USER_PARAM_STRING` | `string` |
| `fulllink_vad_head_wait_time` | `SE_PARAMS_KEY_FULLLINK_VAD_HEAD_WAIT_TIME_INT` | `number` |
| `kws_enable_vad` | `SE_PARAMS_KEY_KWS_ENABLE_VAD_BOOL` | `boolean` |
| `kws_root_path` | `SE_PARAMS_KEY_KWS_ROOT_PATH_STRING` | `string` |
| `kws_user_param` | `SE_PARAMS_KEY_KWS_USER_PARAM_STRING` | `string` |
| `kws_vad_end_silence_timeout` | `SE_PARAMS_KEY_KWS_VAD_END_SILENCE_TIMEOUT_INT` | `number` |
| `license_busi_id` | `SE_PARAMS_KEY_LICENSE_BUSI_ID_STRING` | `string` |
| `license_directory` | `SE_PARAMS_KEY_LICENSE_DIRECTORY_STRING` | `string` |
| `license_name` | `SE_PARAMS_KEY_LICENSE_NAME_STRING` | `string` |
| `log_level` | `SE_PARAMS_KEY_LOG_LEVEL_STRING` | `string` |
| `prevent_player_creation` | `SE_PARAMS_KEY_PREVENT_PLAYER_CREATION_BOOL` | `boolean` |
| `protocol_type` | `SE_PARAMS_KEY_PROTOCOL_TYPE_INT` | `number` |
| `rec_file_type` | `SE_PARAMS_KEY_REC_FILE_TYPE_INT` | `number` |
| `rec_path` | `SE_PARAMS_KEY_REC_PATH_STRING` | `string` |
| `recorder_data_source_type` | `SE_PARAMS_KEY_RECORDER_TYPE_STRING` | `string` |
| `recorder_file` | `SE_PARAMS_KEY_RECORDER_FILE_STRING` | `string` |
| `request_headers` | `SE_PARAMS_KEY_REQUEST_HEADERS_STRING` | `string` |
| `resource_id` | `SE_PARAMS_KEY_RESOURCE_ID_STRING` | `string` |
| `sample_rate` | `SE_PARAMS_KEY_SAMPLE_RATE_INT` | `number` |
| `signal_root_path` | `SE_PARAMS_KEY_SIGNAL_ROOT_PATH_STRING` | `string` |
| `token` | `SE_PARAMS_KEY_APP_TOKEN_STRING` | `string` |
| `tts_address` | `SE_PARAMS_KEY_TTS_ADDRESS_STRING` | `string` |
| `tts_audio_cache_path` | `SE_PARAMS_KEY_TTS_AUDIO_CACHE_PATH_STRING` | `string` |
| `tts_audio_file` | `SE_PARAMS_KEY_TTS_AUDIO_FILE_STRING` | `string` |
| `tts_audio_path` | `SE_PARAMS_KEY_TTS_AUDIO_PATH_STRING` | `string` |
| `tts_backend_cluster` | `SE_PARAMS_KEY_TTS_BACKEND_CLUSTER_STRING` | `string` |
| `tts_business` | `SE_PARAMS_KEY_TTS_BUSINESS_STRING` | `string` |
| `tts_cache_renewal_duration` | `SE_PARAMS_KEY_TTS_CACHE_RENEWAL_DURATION_INT` | `number` |
| `tts_cluster` | `SE_PARAMS_KEY_TTS_CLUSTER_STRING` | `string` |
| `tts_compression_rate` | `SE_PARAMS_KEY_TTS_COMPRESSION_RATE_INT` | `number` |
| `tts_concurrency_mode` | `SE_PARAMS_KEY_TTS_CONCURRENCY_MODE_INT` | `number` |
| `tts_conn_timeout` | `SE_PARAMS_KEY_TTS_CONN_TIMEOUT_INT` | `number` |
| `tts_data_callback_mode` | `SE_PARAMS_KEY_TTS_DATA_CALLBACK_MODE_INT` | `number` |
| `tts_emotion` | `SE_PARAMS_KEY_TTS_EMOTION_STRING` | `string` |
| `tts_enable_cache` | `SE_PARAMS_KEY_TTS_ENABLE_CACHE_BOOL` | `boolean` |
| `tts_enable_dump` | `SE_PARAMS_KEY_TTS_ENABLE_DUMP_BOOL` | `boolean` |
| `tts_enable_player` | `SE_PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL` | `boolean` |
| `tts_fadein_duration` | `SE_PARAMS_KEY_TTS_FADEIN_DURATION_INT` | `number` |
| `tts_fadeout_duration` | `SE_PARAMS_KEY_TTS_FADEOUT_DURATION_INT` | `number` |
| `tts_frontend_type` | `SE_PARAMS_KEY_TTS_FRONTEND_TYPE_STRING` | `string` |
| `tts_language_online` | `SE_PARAMS_KEY_TTS_LANGUAGE_ONLINE_STRING` | `string` |
| `tts_limit_cpu_usage` | `SE_PARAMS_KEY_TTS_LIMIT_CPU_USAGE_BOOL` | `boolean` |
| `tts_max_cached_audio_num` | `SE_PARAMS_KEY_TTS_MAX_CACHED_AUDIO_NUM_INT` | `number` |
| `tts_pitch` | `SE_PARAMS_KEY_TTS_PITCH_INT` | `number` |
| `tts_pitch_ratio` | `SE_PARAMS_KEY_TTS_PITCH_RATIO_DOUBLE` | `number` |
| `tts_pure_english_opt` | `SE_PARAMS_KEY_TTS_PURE_ENGLISH_OPT_INT` | `number` |
| `tts_rate` | `SE_PARAMS_KEY_TTS_SAMPLE_RATE_INT` | `number` |
| `tts_recv_timeout` | `SE_PARAMS_KEY_TTS_RECV_TIMEOUT_INT` | `number` |
| `tts_req_id` | `SE_PARAMS_KEY_TTS_REQUEST_ID_STRING` | `string` |
| `tts_req_params` | `SE_PARAMS_KEY_TTS_REQ_PARAMS_STRING` | `string` |
| `tts_scenario` | `SE_PARAMS_KEY_TTS_SCENARIO_STRING` | `string` |
| `tts_silence_duration` | `SE_PARAMS_KEY_TTS_SILENCE_DURATION_INT` | `number` |
| `tts_speed` | `SE_PARAMS_KEY_TTS_SPEED_INT` | `number` |
| `tts_speed_ratio` | `SE_PARAMS_KEY_TTS_SPEED_RATIO_DOUBLE` | `number` |
| `tts_split_sentence` | `SE_PARAMS_KEY_TTS_SPLIT_SENTENCE_INT` | `number` |
| `tts_text` | `SE_PARAMS_KEY_TTS_TEXT_STRING` | `string` |
| `tts_text_type` | `SE_PARAMS_KEY_TTS_TEXT_TYPE_STRING` | `string` |
| `tts_uri` | `SE_PARAMS_KEY_TTS_URI_STRING` | `string` |
| `tts_use_voiceclone` | `SE_PARAMS_KEY_TTS_USE_VOICECLONE_BOOL` | `boolean` |
| `tts_voice_offline` | `SE_PARAMS_KEY_TTS_VOICE_OFFLINE_STRING` | `string` |
| `tts_voice_online` | `SE_PARAMS_KEY_TTS_VOICE_ONLINE_STRING` | `string` |
| `tts_voice_type_offline` | `SE_PARAMS_KEY_TTS_VOICE_TYPE_OFFLINE_STRING` | `string` |
| `tts_voice_type_online` | `SE_PARAMS_KEY_TTS_VOICE_TYPE_ONLINE_STRING` | `string` |
| `tts_volume` | `SE_PARAMS_KEY_TTS_VOLUME_INT` | `number` |
| `tts_volume_ratio` | `SE_PARAMS_KEY_TTS_VOLUME_RATIO_DOUBLE` | `number` |
| `tts_with_frontend` | `SE_PARAMS_KEY_TTS_WITH_FRONTEND_INT` | `number` |
| `tts_with_intent` | `SE_PARAMS_KEY_TTS_WITH_INTENT_BOOL` | `boolean` |
| `tts_with_timestamp` | `SE_PARAMS_KEY_TTS_WITH_TIMESTAMP_INT` | `number` |
| `tts_work_mode` | `SE_PARAMS_KEY_TTS_WORK_MODE_INT` | `number` |
| `uid` | `SE_PARAMS_KEY_UID_STRING` | `string` |
| `up_channel` | `SE_PARAMS_KEY_UP_CHANNEL_NUM_INT` | `number` |
| `vad_max_music_duration` | `SE_PARAMS_KEY_VAD_MAX_MUSIC_DURATION_INT` | `number` |
| `vad_max_speech_duration` | `SE_PARAMS_KEY_VAD_MAX_SPEECH_DURATION_INT` | `number` |
| `vad_rec_path` | `SE_PARAMS_KEY_VAD_REC_PATH_STRING` | `string` |
| `voiceclone_address` | `SE_PARAMS_KEY_VOICECLONE_ADDRESS_STRING` | `string` |
| `voiceclone_conn_timeout` | `SE_PARAMS_KEY_VOICECLONE_CONN_TIMEOUT_INT` | `number` |
| `voiceclone_enable_dump` | `SE_PARAMS_KEY_VOICECLONE_ENABLE_DUMP_BOOL` | `boolean` |
| `voiceclone_gender` | `SE_PARAMS_KEY_VOICECLONE_GENDER_BOOL` | `boolean` |
| `voiceclone_query_uids` | `SE_PARAMS_KEY_VOICECLONE_QUERY_UIDS_STRING` | `string` |
| `voiceclone_rec_path` | `SE_PARAMS_KEY_VOICECLONE_REC_PATH_STRING` | `string` |
| `voiceclone_recv_timeout` | `SE_PARAMS_KEY_VOICECLONE_RECV_TIMEOUT_INT` | `number` |
| `voiceclone_stream_address` | `SE_PARAMS_KEY_VOICECLONE_STREAM_ADDRESS_STRING` | `string` |
| `voiceclone_taskid` | `SE_PARAMS_KEY_VOICECLONE_TASKID_INT` | `number` |
| `voiceclone_text` | `SE_PARAMS_KEY_VOICECLONE_TEXT_STRING` | `string` |
| `voiceclone_text_seq` | `SE_PARAMS_KEY_VOICECLONE_TEXT_SEQ_INT` | `number` |
| `voiceclone_voice_type` | `SE_PARAMS_KEY_VOICECLONE_VOICE_TYPE_STRING` | `string` |
| `voiceconv_address` | `SE_PARAMS_KEY_VOICECONV_ADDRESS_STRING` | `string` |
| `voiceconv_audio_path` | `SE_PARAMS_KEY_VOICECONV_AUDIO_PATH_STRING` | `string` |
| `voiceconv_cluster` | `SE_PARAMS_KEY_VOICECONV_CLUSTER_STRING` | `string` |
| `voiceconv_enable_record_dump` | `SE_PARAMS_KEY_VOICECONV_ENABLE_RECORD_DUMP_BOOL` | `boolean` |
| `voiceconv_enable_result_dump` | `SE_PARAMS_KEY_VOICECONV_ENABLE_RESULT_DUMP_BOOL` | `boolean` |
| `voiceconv_request_interval` | `SE_PARAMS_KEY_VOICECONV_REQUEST_INTERVAL_INT` | `number` |
| `voiceconv_result_sample_rate` | `SE_PARAMS_KEY_VOICECONV_RESULT_SAMPLE_RATE_INT` | `number` |
| `voiceconv_uri` | `SE_PARAMS_KEY_VOICECONV_URI_STRING` | `string` |
| `voiceconv_voice` | `SE_PARAMS_KEY_VOICECONV_VOICE_STRING` | `string` |
| `voiceconv_voice_type` | `SE_PARAMS_KEY_VOICECONV_VOICE_TYPE_STRING` | `string` |

## Android 专用入口

以下字段没有确认的同类型跨平台映射，仅通过 `android` 传入。

| 原生字段 | 类型 |
| --- | --- |
| `app_version` | `string` |
| `audio_stream_type` | `number` |
| `device_info` | `string` |
| `enable_check_record_permission` | `boolean` |
| `enable_filter_head_silence` | `boolean` |
| `enable_upload_raw_audio` | `boolean` |
| `fulllink_disable_semantic_vad` | `boolean` |
| `fulllink_filter_wakeup_word` | `number` |
| `fulllink_max_valid_speech_duration` | `number` |
| `fulllink_ppe_env` | `string` |
| `kws_enable_signal_vad` | `boolean` |
| `kws_work_mode` | `number` |
| `non_standard_impl_player` | `boolean` |
| `player_disable_reuse` | `boolean` |
| `recorder_directory` | `string` |
| `recorder_disable_reuse` | `boolean` |
| `recorder_preset` | `number` |
| `signal_in_mic_num` | `number` |
| `signal_mode` | `number` |
| `signal_out_mic_num` | `number` |
| `signal_thread_priority` | `number` |
| `start_engine_payload` | `string` |
| `tts_enable_progress` | `boolean` |
| `tts_off_resource_path` | `string` |
| `tts_style_name` | `string` |
| `use_alog` | `boolean` |
| `weave_channel` | `number` |

## iOS 专用入口

以下字段没有确认的同类型跨平台映射，仅通过 `ios` 传入。

| 原生字段 | 类型 |
| --- | --- |
| `SE_PARAMS_KEY_AUTHENTICATE_CREDENTIAL_STRING` | `string` |
| `SE_PARAMS_KEY_CUSTOM_WS_CLIENT_PTR_DOUBLE` | `number` |
| `SE_PARAMS_KEY_FULLLINK_FILTER_WAKEUP_WORD_STRING` | `string` |
| `SE_PARAMS_KEY_RESET_AUDIOSESSION_BOOL` | `boolean` |
| `SE_PARAMS_KEY_RESTART_AUDIOSESSION_BOOL` | `boolean` |
| `SE_PARAMS_KEY_RESUME_OTHERS_INTERRUPTED_PLAYBACK_BOOL` | `boolean` |
| `SE_PARAMS_KEY_STOP_RECORD_WHEN_BACKGROUND_BOOL` | `boolean` |
| `SE_PARAMS_KEY_STOP_RECORD_WHEN_INTERRUPTION_BOOL` | `boolean` |
| `SE_PARAMS_KEY_TTS_OFF_RESOURCE_PATH_STRING` | `string` |
| `SE_PARAMS_KEY_VAD_HEAD_SILENCE_THRESHOLD_INT` | `number` |
| `SE_PARAMS_KEY_VAD_TAIL_SILENCE_THRESHOLD_INT` | `number` |
