package com.finstao.volcenginespeech;

import static com.bytedance.speech.speechengine.SpeechEngineDefines.*;

import android.app.Application;
import com.bytedance.speech.speechengine.SpeechEngine;
import com.bytedance.speech.speechengine.SpeechEngineGenerator;
import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import org.json.JSONObject;

final class VolcengineSpeechModule extends ReactContextBaseJavaModule {
  private final ScheduledExecutorService queue = Executors.newSingleThreadScheduledExecutor();
  private Task active;
  private boolean prepared;

  private static final class Task {
    final String instanceId;
    final String taskId;
    final boolean tts;
    final SpeechEngine engine;
    Promise start;
    boolean started;
    boolean playEnded;
    boolean synthesisEnded;
    boolean finishing;

    Task(String instanceId, String taskId, boolean tts, SpeechEngine engine, Promise start) {
      this.instanceId = instanceId;
      this.taskId = taskId;
      this.tts = tts;
      this.engine = engine;
      this.start = start;
    }
  }

  VolcengineSpeechModule(ReactApplicationContext context) {
    super(context);
  }

  @Override public String getName() { return "RNVolcengineSpeech"; }
  @ReactMethod public void addListener(String name) {}
  @ReactMethod public void removeListeners(double count) {}

  @ReactMethod
  public void invoke(String operation, String instanceId, String taskId, String kind,
      ReadableMap payload, ReadableMap config, Promise promise) {
    queue.execute(() -> {
      try {
        if ("start".equals(operation)) {
          start(instanceId, taskId, "tts".equals(kind), payload, config, promise);
          return;
        }
        Task task = active;
        boolean ownsTask = task != null && task.instanceId.equals(instanceId)
            && (taskId == null || task.taskId.equals(taskId));
        switch (operation) {
          case "cancel":
          case "destroy":
            if (ownsTask) {
              close(task, "E_CANCELLED");
              if ("cancel".equals(operation)) emit(task, "cancelled", 0, "");
            }
            break;
          case "appendText":
            if (!ownsTask || !task.tts || task.finishing) {
              promise.reject("E_INVALID_TASK", "TTS task does not accept text");
              return;
            }
            directive(task, DIRECTIVE_EVENT_TASK_REQUEST, json(payload));
            break;
          case "finishInput":
            if (!ownsTask) {
              promise.reject("E_INVALID_TASK", "Speech task is inactive");
              return;
            }
            if (!task.finishing) {
              directive(task, task.tts ? DIRECTIVE_EVENT_FINISH_SESSION : DIRECTIVE_FINISH_TALKING, "");
              task.finishing = true;
            }
            break;
          default:
            promise.reject("E_UNSUPPORTED", "Unknown speech operation");
            return;
        }
        promise.resolve(null);
      } catch (Exception error) {
        promise.reject("E_NATIVE", error);
      }
    });
  }

  private void start(String instanceId, String taskId, boolean tts, ReadableMap payload,
      ReadableMap config, Promise promise) throws Exception {
    if (active != null) {
      promise.reject("E_BUSY", "A speech task already owns the native engine");
      return;
    }
    if (!prepared) {
      Application app = (Application) getReactApplicationContext().getApplicationContext();
      prepared = SpeechEngineGenerator.PrepareEnvironment(app, app);
      if (!prepared) throw new IllegalStateException("Speech SDK environment failed");
    }
    SpeechEngine engine = SpeechEngineGenerator.getInstance();
    engine.createEngine();
    Task task = new Task(instanceId, taskId, tts, engine, promise);
    active = task;
    try {
      engine.setContext(getReactApplicationContext().getApplicationContext());
      applyOptions(engine, config == null || !config.hasKey("android") ? null : config.getMap("android"));
      engine.setOptionString(PARAMS_KEY_ENGINE_NAME_STRING, tts ? BITTS_ENGINE : ASR_ENGINE);
      if (!tts && payload != null) engine.setOptionString(PARAMS_KEY_ASR_REQ_PARAMS_STRING, json(payload));
      check(engine.initEngine());
      String input = tts ? json(payload) : "";
      engine.setListener((type, data, length) -> {
        String text = data == null ? "" : new String(data, 0,
            Math.max(0, Math.min(length, data.length)), StandardCharsets.UTF_8);
        queue.execute(() -> onMessage(task, type, text));
      });
      directive(task, DIRECTIVE_START_ENGINE, input);
      queue.schedule(() -> {
        if (active == task && task.start != null) close(task, "E_TIMEOUT");
      }, 20, TimeUnit.SECONDS);
    } catch (Exception error) {
      task.start = null;
      close(task, "E_NATIVE");
      throw error;
    }
  }

  private static void applyOptions(SpeechEngine engine, ReadableMap options) {
    if (options == null) return;
    ReadableMapKeySetIterator keys = options.keySetIterator();
    while (keys.hasNextKey()) {
      String key = keys.nextKey();
      switch (key) {
        case PARAMS_KEY_AEC_MODEL_PATH_STRING:
        case PARAMS_KEY_AED_RESOURCE_PATH_STRING:
        case PARAMS_KEY_API_KEY_STRING:
        case PARAMS_KEY_APP_VERSION_STRING:
        case PARAMS_KEY_APP_ID_STRING:
        case PARAMS_KEY_APP_KEY_STRING:
        case PARAMS_KEY_ASR_ADDRESS_STRING:
        case PARAMS_KEY_ASR_CLUSTER_STRING:
        case PARAMS_KEY_ASR_CORRECT_WORDS_STRING:
        case PARAMS_KEY_ASR_LANGUAGE_STRING:
        case PARAMS_KEY_ASR_OFF_RESOURCE_PATH_STRING:
        case PARAMS_KEY_ASR_REC_PATH_STRING:
        case PARAMS_KEY_ASR_REQ_PARAMS_STRING:
        case PARAMS_KEY_ASR_RESULT_TYPE_STRING:
        case PARAMS_KEY_ASR_URI_STRING:
        case PARAMS_KEY_ASR_VAD_MODE_STRING:
        case PARAMS_KEY_AU_ADDRESS_STRING:
        case PARAMS_KEY_AU_CLUSTER_STRING:
        case PARAMS_KEY_AU_REC_PATH_STRING:
        case PARAMS_KEY_AU_URI_STRING:
        case PARAMS_KEY_AUTHENTICATE_ADDRESS_STRING:
        case PARAMS_KEY_AUTHENTICATE_SECRET_STRING:
        case PARAMS_KEY_AUTHENTICATE_TYPE_STRING:
        case PARAMS_KEY_AUTHENTICATE_URI_STRING:
        case PARAMS_KEY_BUSINESS_KEY_STRING:
        case PARAMS_KEY_CAPT_ADDRESS_STRING:
        case PARAMS_KEY_CAPT_CLUSTER_STRING:
        case PARAMS_KEY_CAPT_CORE_TYPE_STRING:
        case PARAMS_KEY_CAPT_REC_PATH_STRING:
        case PARAMS_KEY_CAPT_REFER_TEXT_STRING:
        case PARAMS_KEY_CAPT_RESPONSE_MODE_STRING:
        case PARAMS_KEY_CAPT_SCENE_STRING:
        case PARAMS_KEY_CAPT_URI_STRING:
        case PARAMS_KEY_DEBUG_PATH_STRING:
        case PARAMS_KEY_DEVICE_ID_STRING:
        case PARAMS_KEY_DEVICE_INFO_STRING:
        case PARAMS_KEY_DIALOG_ADDRESS_STRING:
        case PARAMS_KEY_DIALOG_PLAYER_PATH_STRING:
        case PARAMS_KEY_DIALOG_RECORDER_PATH_STRING:
        case PARAMS_KEY_DIALOG_URI_STRING:
        case PARAMS_KEY_FULLLINK_ADDRESS_STRING:
        case PARAMS_KEY_FULLLINK_CLUSTER_STRING:
        case PARAMS_KEY_FULLLINK_PPE_ENV_STRING:
        case PARAMS_KEY_FULLLINK_QUERY_STRING_STRING:
        case PARAMS_KEY_FULLLINK_SCENE_ID_STRING:
        case PARAMS_KEY_FULLLINK_URI_STRING:
        case PARAMS_KEY_FULLLINK_USER_PARAM_STRING:
        case PARAMS_KEY_KWS_ROOT_PATH_STRING:
        case PARAMS_KEY_KWS_USER_PARAM_STRING:
        case PARAMS_KEY_LICENSE_BUSI_ID_STRING:
        case PARAMS_KEY_LICENSE_DIRECTORY_STRING:
        case PARAMS_KEY_LICENSE_NAME_STRING:
        case PARAMS_KEY_LOG_LEVEL_STRING:
        case PARAMS_KEY_REC_PATH_STRING:
        case PARAMS_KEY_RECORDER_TYPE_STRING:
        case PARAMS_KEY_RECORDER_DIRECTORY_STRING:
        case PARAMS_KEY_RECORDER_FILE_STRING:
        case PARAMS_KEY_REQUEST_HEADERS_STRING:
        case PARAMS_KEY_RESOURCE_ID_STRING:
        case PARAMS_KEY_SIGNAL_ROOT_PATH_STRING:
        case PARAMS_KEY_START_ENGINE_PAYLOAD_STRING:
        case PARAMS_KEY_APP_TOKEN_STRING:
        case PARAMS_KEY_TTS_ADDRESS_STRING:
        case PARAMS_KEY_TTS_AUDIO_CACHE_PATH_STRING:
        case PARAMS_KEY_TTS_AUDIO_FILE_STRING:
        case PARAMS_KEY_TTS_AUDIO_PATH_STRING:
        case PARAMS_KEY_TTS_BACKEND_CLUSTER_STRING:
        case PARAMS_KEY_TTS_BUSINESS_STRING:
        case PARAMS_KEY_TTS_CLUSTER_STRING:
        case PARAMS_KEY_TTS_EMOTION_STRING:
        case PARAMS_KEY_TTS_FRONTEND_TYPE_STRING:
        case PARAMS_KEY_TTS_LANGUAGE_ONLINE_STRING:
        case PARAMS_KEY_TTS_OFFLINE_RESOURCE_PATH_STRING:
        case PARAMS_KEY_TTS_REQUEST_ID_STRING:
        case PARAMS_KEY_TTS_REQ_PARAMS_STRING:
        case PARAMS_KEY_TTS_SCENARIO_STRING:
        case PARAMS_KEY_TTS_STYLE_NAME_STRING:
        case PARAMS_KEY_TTS_TEXT_STRING:
        case PARAMS_KEY_TTS_TEXT_TYPE_STRING:
        case PARAMS_KEY_TTS_URI_STRING:
        case PARAMS_KEY_TTS_VOICE_OFFLINE_STRING:
        case PARAMS_KEY_TTS_VOICE_ONLINE_STRING:
        case PARAMS_KEY_TTS_VOICE_TYPE_OFFLINE_STRING:
        case PARAMS_KEY_TTS_VOICE_TYPE_ONLINE_STRING:
        case PARAMS_KEY_UID_STRING:
        case PARAMS_KEY_VAD_REC_PATH_STRING:
        case PARAMS_KEY_VOICECLONE_ADDRESS_STRING:
        case PARAMS_KEY_VOICECLONE_QUERY_UIDS_STRING:
        case PARAMS_KEY_VOICECLONE_REC_PATH_STRING:
        case PARAMS_KEY_VOICECLONE_STREAM_ADDRESS_STRING:
        case PARAMS_KEY_VOICECLONE_TEXT_STRING:
        case PARAMS_KEY_VOICECLONE_VOICE_TYPE_STRING:
        case PARAMS_KEY_VOICECONV_ADDRESS_STRING:
        case PARAMS_KEY_VOICECONV_AUDIO_PATH_STRING:
        case PARAMS_KEY_VOICECONV_CLUSTER_STRING:
        case PARAMS_KEY_VOICECONV_URI_STRING:
        case PARAMS_KEY_VOICECONV_VOICE_STRING:
        case PARAMS_KEY_VOICECONV_VOICE_TYPE_STRING:
          engine.setOptionString(key, options.getString(key));
          break;
        case PARAMS_KEY_AEC_ENABLE_DUMP_BOOL:
        case PARAMS_KEY_ASR_AUTO_STOP_BOOL:
        case PARAMS_KEY_ASR_DISABLE_END_PUNC_BOOL:
        case PARAMS_KEY_ASR_ENABLE_DDC_BOOL:
        case PARAMS_KEY_ASR_ENABLE_ITN_BOOL:
        case PARAMS_KEY_ASR_KEEP_RECORDING_BOOL:
        case PARAMS_KEY_ASR_SHOW_LANG_BOOL:
        case PARAMS_KEY_ASR_SHOW_NLU_PUNC_BOOL:
        case PARAMS_KEY_ASR_SHOW_PUNC_BOOL:
        case PARAMS_KEY_ASR_SHOW_UTTER_BOOL:
        case PARAMS_KEY_ASR_SHOW_VOLUME_BOOL:
        case PARAMS_KEY_AU_AUTO_STOP_BOOL:
        case PARAMS_KEY_CAPT_AUTO_STOP_BOOL:
        case PARAMS_KEY_DIALOG_ENABLE_DECODER_AUDIO_CALLBACK_BOOL:
        case PARAMS_KEY_DIALOG_ENABLE_PLAYER_BOOL:
        case PARAMS_KEY_DIALOG_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL:
        case PARAMS_KEY_DIALOG_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL:
        case PARAMS_KEY_ENABLE_AEC_BOOL:
        case PARAMS_KEY_ENABLE_CHECK_RECORD_PERMISSION_BOOL:
        case PARAMS_KEY_ENABLE_CUSTOM_WS_CLIENT_BOOL:
        case PARAMS_KEY_ENABLE_FILTER_HEAD_SILENCE_BOOL:
        case PARAMS_KEY_ENABLE_GET_VOLUME_BOOL:
        case PARAMS_KEY_ENABLE_PLAYER_AUDIO_CALLBACK_BOOL:
        case PARAMS_KEY_ENABLE_RECORDER_AUDIO_CALLBACK_BOOL:
        case PARAMS_KEY_ENABLE_RESAMPLER_BOOL:
        case PARAMS_KEY_ENABLE_RESUME_FROM_PREVIOUS_PROGRESS_BOOL:
        case PARAMS_KEY_ENABLE_UPLOAD_RAW_AUDIO_BOOL:
        case PARAMS_KEY_ENABLE_WS_RECONNECT_BOOL:
        case PARAMS_KEY_FULLLINK_ASR_AUTO_STOP_BOOL:
        case PARAMS_KEY_FULLLINK_ASR_ONLY_BOOL:
        case PARAMS_KEY_FULLLINK_DISABLE_SEMANTIC_VAD_BOOL:
        case PARAMS_KEY_FULLLINK_DISABLE_TTS_BOOL:
        case PARAMS_KEY_KWS_ENABLE_SIGNAL_VAD_BOOL:
        case PARAMS_KEY_KWS_ENABLE_VAD_BOOL:
        case PARAMS_KEY_NON_STANDARD_IMPL_PLAYER_BOOL:
        case PARAMS_KEY_PLAYER_DISABLE_REUSE_BOOL:
        case PARAMS_KEY_PREVENT_PLAYER_CREATION_BOOL:
        case PARAMS_KEY_RECORDER_DISABLE_REUSE_BOOL:
        case PARAMS_KEY_TTS_ENABLE_CACHE_BOOL:
        case PARAMS_KEY_TTS_ENABLE_DUMP_BOOL:
        case PARAMS_KEY_TTS_ENABLE_PLAYER_BOOL:
        case PARAMS_KEY_TTS_ENABLE_PROGRESS_BOOL:
        case PARAMS_KEY_TTS_LIMIT_CPU_USAGE_BOOL:
        case PARAMS_KEY_TTS_USE_VOICECLONE_BOOL:
        case PARAMS_KEY_TTS_WITH_INTENT_BOOL:
        case PARAMS_KEY_USE_ALOG_BOOL:
        case PARAMS_KEY_VOICECLONE_ENABLE_DUMP_BOOL:
        case PARAMS_KEY_VOICECLONE_GENDER_BOOL:
        case PARAMS_KEY_VOICECONV_ENABLE_RECORD_DUMP_BOOL:
        case PARAMS_KEY_VOICECONV_ENABLE_RESULT_DUMP_BOOL:
          engine.setOptionBoolean(key, options.getBoolean(key));
          break;
        case PARAMS_KEY_ASR_CONN_TIMEOUT_INT:
        case PARAMS_KEY_ASR_MAX_RETRY_TIMES_INT:
        case PARAMS_KEY_ASR_PACKAGE_SIZE_INT:
        case PARAMS_KEY_ASR_RECV_TIMEOUT_INT:
        case PARAMS_KEY_ASR_SCENARIO_INT:
        case PARAMS_KEY_ASR_VAD_END_SILENCE_TIME_INT:
        case PARAMS_KEY_ASR_VAD_START_SILENCE_TIME_INT:
        case PARAMS_KEY_ASR_WORK_MODE_INT:
        case PARAMS_KEY_AU_ABILITY_INT:
        case PARAMS_KEY_AU_AUDIO_PACKET_DURATION_INT:
        case PARAMS_KEY_AU_CONN_TIMEOUT_INT:
        case PARAMS_KEY_AU_EMPTY_PACKET_INTERVAL_INT:
        case PARAMS_KEY_AU_PROCESS_TIMEOUT_INT:
        case PARAMS_KEY_AU_RECV_TIMEOUT_INT:
        case PARAMS_KEY_AUDIO_FADEOUT_DURATION_INT:
        case PARAMS_KEY_AUDIO_STREAM_TYPE_INT:
        case PARAMS_KEY_CAPT_CONN_TIMEOUT_INT:
        case PARAMS_KEY_CAPT_DIFFICULTY_INT:
        case PARAMS_KEY_CAPT_RECV_TIMEOUT_INT:
        case PARAMS_KEY_CHANNEL_NUM_INT:
        case PARAMS_KEY_CUSTOM_CHANNEL_INT:
        case PARAMS_KEY_CUSTOM_SAMPLE_RATE_INT:
        case PARAMS_KEY_DIALOG_WORK_MODE_INT:
        case PARAMS_KEY_FINGERPRINT_SLICE_DURATION_INT:
        case PARAMS_KEY_FULLLINK_CONN_TIMEOUT_INT:
        case PARAMS_KEY_FULLLINK_FILTER_WAKEUP_WORD_INT:
        case PARAMS_KEY_FULLLINK_MAX_VALID_SPEECH_DURATION_INT:
        case PARAMS_KEY_FULLLINK_RECV_TIMEOUT_INT:
        case PARAMS_KEY_FULLLINK_VAD_HEAD_WAIT_TIME_INT:
        case PARAMS_KEY_KWS_VAD_END_SILENCE_TIMEOUT_INT:
        case PARAMS_KEY_KWS_WORK_MODE_INT:
        case PARAMS_KEY_PROTOCOL_TYPE_INT:
        case PARAMS_KEY_REC_FILE_TYPE_INT:
        case PARAMS_KEY_RECORDER_PRESET_INT:
        case PARAMS_KEY_SAMPLE_RATE_INT:
        case PARAMS_KEY_SIGNAL_IN_MIC_NUM_INT:
        case PARAMS_KEY_SIGNAL_MODE_INT:
        case PARAMS_KEY_SIGNAL_OUT_MIC_NUM_INT:
        case PARAMS_KEY_SIGNAL_THREAD_PRIORITY_INT:
        case PARAMS_KEY_TTS_CACHE_RENEWAL_DURATION_INT:
        case PARAMS_KEY_TTS_COMPRESSION_RATE_INT:
        case PARAMS_KEY_TTS_CONCURRENCY_MODE_INT:
        case PARAMS_KEY_TTS_CONN_TIMEOUT_INT:
        case PARAMS_KEY_TTS_DATA_CALLBACK_MODE_INT:
        case PARAMS_KEY_TTS_FADEIN_DURATION_INT:
        case PARAMS_KEY_TTS_FADEOUT_DURATION_INT:
        case PARAMS_KEY_TTS_MAX_CACHED_AUDIO_NUM_INT:
        case PARAMS_KEY_TTS_PITCH_INT:
        case PARAMS_KEY_TTS_PURE_ENGLISH_OPT_INT:
        case PARAMS_KEY_TTS_SAMPLE_RATE_INT:
        case PARAMS_KEY_TTS_RECV_TIMEOUT_INT:
        case PARAMS_KEY_TTS_SILENCE_DURATION_INT:
        case PARAMS_KEY_TTS_SPEED_INT:
        case PARAMS_KEY_TTS_SPLIT_SENTENCE_INT:
        case PARAMS_KEY_TTS_VOLUME_INT:
        case PARAMS_KEY_TTS_WITH_FRONTEND_INT:
        case PARAMS_KEY_TTS_WITH_TIMESTAMP_INT:
        case PARAMS_KEY_TTS_WORK_MODE_INT:
        case PARAMS_KEY_UP_CHANNEL_NUM_INT:
        case PARAMS_KEY_VAD_MAX_MUSIC_DURATION_INT:
        case PARAMS_KEY_VAD_MAX_SPEECH_DURATION_INT:
        case PARAMS_KEY_VOICECLONE_CONN_TIMEOUT_INT:
        case PARAMS_KEY_VOICECLONE_RECV_TIMEOUT_INT:
        case PARAMS_KEY_VOICECLONE_TASKID_INT:
        case PARAMS_KEY_VOICECLONE_TEXT_SEQ_INT:
        case PARAMS_KEY_VOICECONV_REQUEST_INTERVAL_INT:
        case PARAMS_KEY_VOICECONV_RESULT_SAMPLE_RATE_INT:
        case PARAMS_KEY_WEAVE_CHANNEL_NUM_INT:
          engine.setOptionInt(key, options.getInt(key));
          break;
        case PARAMS_KEY_TTS_PITCH_RATIO_DOUBLE:
        case PARAMS_KEY_TTS_SPEED_RATIO_DOUBLE:
        case PARAMS_KEY_TTS_VOLUME_RATIO_DOUBLE:
          engine.setOptionDouble(key, options.getDouble(key));
          break;
        default: throw new IllegalArgumentException("Unknown Android SDK option: " + key);
      }
    }
  }

  private void onMessage(Task task, int code, String data) {
    if (active != task) return;
    try {
      switch (code) {
        case MESSAGE_TYPE_ENGINE_START:
          if (task.tts && !task.started) {
            task.started = true;
            directive(task, DIRECTIVE_EVENT_START_SESSION, "");
          } else if (!task.tts) ready(task, "ready", code, data);
          break;
        case MESSAGE_TYPE_EVENT_SESSION_STARTED: ready(task, "ready", code, data); break;
        case MESSAGE_TYPE_RECORDER_BEGIN: emit(task, "recordingStarted", code, data); break;
        case MESSAGE_TYPE_RECORDER_END: emit(task, "inputEnded", code, data); break;
        case MESSAGE_TYPE_PARTIAL_RESULT: emit(task, "partialResult", code, data); break;
        case MESSAGE_TYPE_VOLUME_LEVEL: emit(task, "volume", code, data); break;
        case MESSAGE_TYPE_FINAL_RESULT: terminal(task, "finalResult", code, data); break;
        case MESSAGE_TYPE_TTS_START_PLAYING: emit(task, "playbackStarted", code, data); break;
        case MESSAGE_TYPE_TTS_FINISH_PLAYING:
          task.playEnded = true;
          if (task.synthesisEnded) terminal(task, "playbackFinished", code, data);
          break;
        case MESSAGE_TYPE_EVENT_SESSION_FINISHED:
          task.synthesisEnded = true;
          emit(task, "synthesisFinished", code, data);
          if (task.playEnded) terminal(task, "playbackFinished", code, data);
          break;
        case MESSAGE_TYPE_ENGINE_STOP:
        case MESSAGE_TYPE_ENGINE_ERROR:
        case MESSAGE_TYPE_EVENT_SESSION_FAILED: terminal(task, "error", code, data); break;
        default: break;
      }
    } catch (Exception error) {
      terminal(task, "error", code, "");
    }
  }

  private void ready(Task task, String event, int code, String data) {
    if (task.start == null) return;
    task.start.resolve(null);
    task.start = null;
    emit(task, event, code, data);
  }

  private void terminal(Task task, String event, int code, String data) {
    close(task, "E_NATIVE");
    emit(task, event, code, data);
  }

  private void close(Task task, String code) {
    if (active != task) return;
    active = null;
    if (task.start != null) task.start.reject(code, "Speech task ended before becoming ready");
    task.start = null;
    task.engine.destroyEngine();
  }

  private void emit(Task task, String type, int code, String data) {
    if (!getReactApplicationContext().hasActiveReactInstance()) return;
    WritableMap payload = Arguments.createMap();
    payload.putInt("nativeCode", code);
    payload.putString("data", data);
    WritableMap event = Arguments.createMap();
    event.putString("instanceId", task.instanceId);
    event.putString("taskId", task.taskId);
    event.putString("type", type);
    event.putMap("payload", payload);
    getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit("RNVolcengineSpeechEvent", event);
  }

  private static String json(ReadableMap payload) {
    return payload == null ? "" : new JSONObject(payload.toHashMap()).toString();
  }

  private static void directive(Task task, int directive, String data) {
    check(task.engine.sendDirective(directive, data));
  }

  private static void check(int result) {
    if (result != ERR_NO_ERROR) throw new IllegalStateException("Speech SDK error " + result);
  }

  @Override
  public void invalidate() {
    queue.execute(() -> {
      if (active != null) close(active, "E_DESTROYED");
    });
    super.invalidate();
  }
}
