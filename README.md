# @code_shuai/react-native-volcengine-speech

React Native 火山语音库，支持豆包 TTS 2.0 整段与增量朗读、流式 ASR 录音与识别事件。Android 和 iOS 均使用火山 SpeechEngine 0.0.15.0。

| 功能 | Android / iOS |
| --- | --- |
| 朗读 | 整段输入、追加文本、结束输入、取消、播放事件 |
| 识别 | 内置录音、结束输入、取消、中间与最终结果、音量事件 |
| 引擎选项 | 按平台使用官方键和原生类型 |
| 运行限制 | 全局一次一个活动任务，冲突返回 E_BUSY |

宿主链接、事件时序、录放和完整参数生效情况待真机验证。[验证记录](docs/SDK-VERIFICATION.md)

## 下载安装

发布后使用 `npm install @code_shuai/react-native-volcengine-speech` 或 Yarn 对应命令。开发期间在 SDK 目录执行 `npm install` 和 `npm pack`，再在宿主中安装生成的 tgz。目标宿主为 React 19 / RN 0.83，SDK 构建使用 Node.js 20 或以上。

Android 从火山 Maven 仓库解析 `speechengine_tob:0.0.15.0`。iOS 在 Podfile 添加官方 Specs 源，再执行 `pod install`。

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/volcengine/volcengine-specs.git'
```

SpeechEngineToB 0.0.15.0 缺少 x86_64 iOS 模拟器链接所需的原生符号。需要在模拟器上运行宿主 App 时，在 Podfile 加入以下配置。项目已有 `post_integrate` 时，把调用加进已有的回调。

```ruby
require_relative '../node_modules/@code_shuai/react-native-volcengine-speech/scripts/ios-simulator'

post_integrate do |installer|
  VolcengineSpeech.exclude_simulator_libraries(installer)
end
```

该配置仅排除模拟器无法链接的官方二进制库。模拟器 ASR 使用 `AVAudioEngine` 录音并通过豆包官方 WebSocket 协议连接，保持 `createRecognizer/start/finishInput/cancel/destroy` 与结果、音量事件接口一致；iOS 真机仍使用 SpeechEngine。模拟器 TTS 同样通过官方双向流式 WebSocket 合成，使用 `AVAudioEngine/AVAudioPlayerNode` 播放。可通过原生模块常量 `supportsAsr`、`supportsTts` 、`asrImplementation` 和 `ttsImplementation` 区分模拟器能力。

模拟器 ASR 当前支持 API Key 鉴权、`resource_id`、`asr_address`、`asr_uri`、`asr_language`、`enable_get_volume`、`asr_req_params` 及 `start(payload)` 请求参数（含热词/替换词 `corpus`）。仅支持内置录音机，固定输出 16 kHz / 16 bit / 单声道 PCM；其他 SpeechEngine 专属选项不在模拟器适配范围内。`start(payload)` 的字段优先于 `asr_req_params`，二者均作为协议 `request` 对象，不额外套 `request`。模拟器与真机走不同的底层实现，发布前仍需验证真机。

模拟器验证：

1. 配置 Simulator 的音频输入为 Mac 麦克风，允许 Simulator 使用麦克风；App 内仍需申请录音权限。
2. 正常启动 App 并登录，调用与真机相同的 ASR API。API Key 只从宿主内存传入，不写入源码或日志。
3. 按住说话，松手调用 `finishInput`；应先收到 `inputEnded`，再收到 `finalResult`。音频结束标志与识别结果完成是不同阶段。
4. 验证上滑取消、再次开始、网络失败和无录音权限。取消/销毁后旧连接结果不会发送到新任务。
5. Xcode 控制台筛选 `VolcengineSimulatorAsr`，检查连接、结束输入、最终结果或错误码；日志不包含凭证、识别正文或音频。连接超时 10 秒，提交结束后等待结果最多 15 秒。

模拟器 TTS 保持 `start → appendText（可多次）→ finishInput` 接口，收到音频即开始播放。`synthesisFinished` 代表服务端合成结束；只有最后一段 PCM 的 `DataPlayedBack` 回调完成后才发出 `playbackFinished`。取消/销毁立即停止音频并忽略旧任务回调，与 ASR 共用单任务互斥。

模拟器 TTS 当前支持 API Key、`resource_id`、`tts_address`、`tts_uri`，并透传 `start({ req_params })` 的音色、语速、音量、附加配置等服务端参数。使用内置播放器，音频格式为单声道 16 bit PCM，默认 24 kHz，支持官方列出的采样率；显式请求 MP3/Opus 或关闭内置播放器会返回 `E_UNSUPPORTED`。其他 SpeechEngine 专属选项不在模拟器适配范围内。连接/会话启动超时 15 秒，正在等待读取消息时，60 秒无响应会超时；播放队列积累到约 20 秒时暂停接收，消耗到约 10 秒时恢复，避免长回复因合成快于播放而超限。异常单包/本地待播放缓存硬上限两分钟。

模拟器声音偏小时，先检查 Mac 音量和模拟器自身音量（选中模拟器窗口后按 `⌘↑`，或使用 Device → Sound → Increase Volume）；SDK 不强制改变系统音量。

验证 TTS 时先点播已有回复，确认能出声且读完后动画停止，再验证增量文本播报、播放中停止、重复播放与切换到录音。控制台筛选 `VolcengineSimulatorTts`，应依次看到 `sessionStarted`、`playbackStarted`、`synthesisFinished`、`playbackFinished`；日志不输出朗读正文、音频或密钥。

接入后重新构建 App。ASR 需要宿主申请麦克风权限，iOS 还需提供 `NSMicrophoneUsageDescription`。凭证由宿主注入。

## 用法

```ts
import { createSynthesizer } from '@code_shuai/react-native-volcengine-speech'

const tts = createSynthesizer({
  api_key: apiKey,
  resource_id: 'seed-tts-2.0',

})
const subscription = tts.addListener(event => {
  if (event.type === 'playbackFinished') {
    // 更新播报状态
  }
})

await tts.speak('你好。', {
  req_params: { speaker: speakerId },
})

// 页面释放时
subscription.remove()
await tts.destroy()
```

鉴权、地址和模型资源由宿主传入，iOS 和 Android 共用同一份配置。TTS 2.0 的资源标识为 `seed-tts-2.0`。增量朗读使用 `start(payload)` 后调用 `appendText(taskId, { req_params: { text } })`，最后调用 `finishInput(taskId)`。

```ts
import { createRecognizer } from '@code_shuai/react-native-volcengine-speech'

const asr = createRecognizer({
  api_key: apiKey,
  resource_id: asrResourceId,

})
const subscription = asr.addListener(event => {
  if (event.type === 'partialResult' || event.type === 'finalResult') {
    // event.payload?.data 为 SDK 回调的原始文本
  }
})
const taskId = await asr.start({ show_utterances: true })
// 松手时
await asr.finishInput(taskId)
// 上滑取消时，调用 asr.cancel(taskId)
```

## API 与参数

| 方法 | 参数与返回值 |
| --- | --- |
| createSynthesizer | TtsConfig，返回 TTS 实例 |
| createRecognizer | AsrConfig，返回 ASR 实例 |
| tts.speak | text 和 TtsSessionPayload，返回 Promise<string> |
| tts.start | TtsSessionPayload，返回任务 ID |
| tts.appendText | taskId 和 TtsTaskPayload，等待提交完成 |
| asr.start | 可选 ASR 请求参数对象，返回任务 ID |
| finishInput | taskId，提交结束输入指令，继续等待输出 |
| cancel | taskId，取消对应任务 |
| addListener | 事件回调，返回可移除订阅 |
| destroy | 释放任务与订阅，返回 Promise<void> |

- 公共参数在顶层传一次，SDK 根据[初始化选项表](docs/NATIVE-OPTIONS.md)映射到两端的原生字段。
- 平台专用字段可传入 `android` 或 `ios`；这两组也是旧版配置的兼容入口。同一参数同时出现在顶层和平台配置时，以平台配置为准。
- TTS 会话、TTS 文本任务和 ASR 请求保留官方 JSON 名称、层级及值，包括 `req_params`、`audio_params`、`speech_rate`、`corpus`。官方定义为 JSON 字符串的字段仍传字符串。
- 事件包含 `instanceId`、`taskId`、`type` 及可选的 `payload`。目前 payload 保留原生 `nativeCode` 和 `data`。TTS 与 ASR 的完成事件分别为 `playbackFinished` 和 `finalResult`。
- 常见错误包括 `E_NOT_LINKED`、`E_BUSY`、`E_INVALID_TASK`、`E_INVALID_ARGUMENT`、`E_TIMEOUT` 和 `E_NATIVE`。

官方参考：[TTS 请求协议](https://docs.volcengine.com/docs/doubao-voice/bidirectional-streaming-text-to-speech-websocket?lang=zh) · [流式 ASR SDK](https://docs.volcengine.com/docs/doubao-voice/large-model-streaming-automatic-speech-recognition-android-sdk-interface?lang=zh)

## npm 发布

`npm run release:check` 执行类型检查、编译、产物检查和打包预览。通过后可生成本地包，或由维护者执行 `npm publish --tag next` 发布测试版。

## 初始化默认值

调用方省略字段或传入 `undefined` 时使用下列 SDK 默认值。显式传入的 `false`、`0`、空字符串均保留；平台配置覆盖顶层配置，顶层配置覆盖默认值。旧平台配置也会获得默认值。

| 能力 | 字段 | 默认值 |
| --- | --- | --- |
| TTS | tts_address | wss://openspeech.bytedance.com |
| TTS | tts_uri | /api/v3/tts/bidirection |
| TTS | tts_enable_player | true |
| TTS | tts_conn_timeout | 10000（毫秒） |
| TTS | debug_path、tts_audio_path | 空字符串 |
| TTS | request_headers | '{}'（JSON 字符串） |
| TTS | enable_player_audio_callback | false |
| ASR | asr_address | wss://openspeech.bytedance.com |
| ASR | asr_uri | /api/v3/sauc/bigmodel_nostream |
| ASR | protocol_type | 1 |
| ASR | recorder_data_source_type | Recorder |
| ASR | enable_get_volume | true |

ASR 默认使用当前整段输入的流式接口；需要实时中间结果时，仍需显式配置对应的 `asr_uri` 及请求参数。默认服务路径不是所有模型通用的配置，切换服务时请同时核对地址、路径与资源。

SDK 不默认填入 `api_key`、`resource_id` 或音色 `speaker`，避免替调用方选择账号、计费资源或音色。宿主继续显式提供这些值。可导入只读的 `DEFAULT_TTS_CONFIG` 和 `DEFAULT_ASR_CONFIG` 查看默认配置。
