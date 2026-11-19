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

该配置仅调整模拟器的链接选项。iOS 模拟器中的语音模块会返回 `E_UNSUPPORTED`，豆包 TTS 和 ASR 请使用真机测试。

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
