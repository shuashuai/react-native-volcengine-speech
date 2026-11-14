# RN 火山语音 SDK 产品需求与 API 设计

版本：0.3 草案｜日期：2026-11-10｜状态：需求已整理，未实施

## 1. 目标

提供独立、可复用、可发布 npm 的 RN 原生桥接库，包名拟为 @code_shuai/react-native-volcengine-speech，仓库与 promoter-app 同级。参考抖音 SDK 的统一双端 API、显式参数模型、原生映射说明、独立测试和发布检查；不依赖宿主业务。

首个宿主为 React 19 / RN 0.83。替换现有腾讯 ASR/TTS，不保留新版腾讯回退。业务 JS 不自行建立 WebSocket，网络和音频处理由原生 Speech SDK 承担；SDK 内部仍使用网络长连接。

TTS 使用豆包 TTS 2.0，主要阅读完整消息及增量 AI 输出；ASR 支持现有按住说话，同时首版开放中间结果，为实时识别准备。无需为统一依赖牺牲能力。

## 2. SDK 选择与证据

采用新版大模型 Speech SDK 文档基线 0.0.15.0：Android speechengine_tob；iOS SpeechEngineToB。TTS 使用 BiTTS 引擎及 seed-tts-2.0；ASR 使用流式识别引擎及 ASR 2.0 资源。具体来源、正文可读状态及已知缺口见 SDK-VERIFICATION.md。

这是当前官方文档列出的实施基线，不宣称为仓库中最新发布版本。实施前必须检查实际可下载版本、头文件、Demo、变更说明及兼容性；不得回退到旧的 0.0.14.6.1-bugfix ASR+非双向 TTS 组合来冒充满足本需求。

文档层面能力匹配；运行时满足性只有通过第 9 节双端验收后才能确认。

## 3. 边界与分层

| 层次 | 职责 |
| --- | --- |
| 原生桥接 | 初始化、引擎实例、录音、播放、线程调度、原生事件、清理 |
| 通用 TS 层 | 参数校验、类型、任务标识、事件订阅、错误归一、生命周期 |
| 宿主业务 | 身份、凭证服务、权限提示、Toast、手势、倒计时、断句、Markdown 清理、消息队列 |

库中不出现 shop_id、messageId、自动发送消息、项目 service、Store、i18n 或全局弹层。音频默认留在原生侧。首版覆盖所选流式 ASR 和 TTS 引擎的参数及其生效所需的桥接能力。官方支持的音频输入源、播放器开关、PCM 回调等随对应参数实现。App 首期使用内置录音和播放。独立的录音文件转写服务、离线模型、声音复刻训练和端到端语音对话属于其他产品范围。

## 4. 通用 API 设计草案

统一 Android/iOS 公共接口，不要求逐字复制原生方法。API 为需求设计，尚非已实现承诺；原生符号必须以 SDK 包核实。

- createSynthesizer(config)：具名导出，创建 Synthesizer 逻辑实例。
- createRecognizer(config)：具名导出，创建 Recognizer 逻辑实例。
- 两种实例均提供 updateCredentials、addListener、destroy。
- native 初始化延迟至异步操作；创建逻辑实例不代表原生初始化成功。
- 首版每类最多一个活动任务；冲突返回 E_BUSY，不静默替换。逻辑实例不代表 SDK 已验证支持无限并发引擎。
- 不支持的能力返回 E_UNSUPPORTED；无法确认的能力为 unknown，不伪报支持。

分别声明 Synthesizer 与 Recognizer 类型，不暴露一个依赖 type 参数切换行为的通用引擎对象。相同语义使用相同名称：start 开始任务，finishInput 结束输入但继续等待输出，cancel 放弃任务，destroy 释放实例。appendText、speak 仅属于 TTS。TypeScript 与运行时均校验实例类型，不允许在 ASR 实例调用 TTS 方法。

这些是本库设计的 RN API，不是官方方法的逐字复制。官方基于 SpeechEngine、引擎类型参数和指令提供能力；桥接负责选择 ASR/BiTTS 引擎、原生实例及事件分发。文档必须逐项给出 RN API → 双端官方配置/指令/回调映射，映射尚未核实处明确标记，不能虚构同名原生方法。

```ts
import {
  createSynthesizer,
  createRecognizer,
} from '@code_shuai/react-native-volcengine-speech'

const tts = createSynthesizer(ttsConfig)
const asr = createRecognizer(asrConfig)

// 增量阅读：文本输入结束后，等待 playbackFinished 事件。
const ttsTaskId = await tts.start()
await tts.appendText(ttsTaskId, '第一段。')
await tts.appendText(ttsTaskId, '第二段。')
await tts.finishInput(ttsTaskId)

// 录音：松手结束输入，最终文字通过识别事件返回。
const asrTaskId = await asr.start()
await asr.finishInput(asrTaskId)

// 用户取消阅读或识别：分别终止对应实例的任务。
await tts.cancel(ttsTaskId)
await asr.cancel(asrTaskId)

await tts.destroy()
await asr.destroy()
```

示例中的 config 由调用方提供；正式 README 需补齐字段和事件订阅。tts 与 asr 的配置、任务标识和监听隔离；不能用另一实例的 taskId 操作当前实例。cancel 示例是用户取消时的独立路径，已完成任务不会重新进入取消状态。

### 4.1 公共配置

凭证使用互斥联合：新版 apiKey，或旧版 appId + token。宿主选择一种合法方式注入，不自动混用。不得将生产凭证写入源码、发布包或日志。尚未确认短期凭证机制，不承诺类似腾讯 STS 的授权。

资源 ID 按 TTS/ASR 独立配置；不把文档默认资源理解为账号已开通。uid、超时、日志等级按所选 SDK 支持范围开放。默认生产日志关闭音频和文本落盘。

所选豆包 TTS 2.0 与流式 ASR 2.0 在锁定 SDK 和协议版本中支持的配置及请求参数，全部纳入封装。覆盖初始化、鉴权、引擎配置、会话配置、各请求指令和嵌套 payload，包含必填、可选、平台专有以及满足特定条件才生效的字段。

参数命名使用官方原名。协议字段逐层保留原键名、大小写、嵌套结构、类型、枚举和值域，例如 `req_params`、`audio_params`、`speaker`、`speech_rate`。直接暴露的原生配置键使用官方对应名称，并记录 Android 与 iOS 的原生常量和映射。公共方法可以采用 RN 命名，官方参数保留各自的命名。可选参数缺省时遵循官方行为，显式传入 0、false、空值时按官方语义处理。

提供完整 TypeScript 类型与逐字段参数表，注明适用方法、平台、版本、必填性、默认值、单位、取值范围、互斥条件及文档来源。按官方文档、原生头文件和 Demo 核对覆盖范围。平台专有项注明适用平台，其他平台调用时明确返回 E_UNSUPPORTED。使用已核实的类型和映射支持参数，未知字段明确报错。文档与 SDK 不一致的字段记录证据并核实，纳入验收前解决。

### 4.2 TTS

| 方法 | 语义 |
| --- | --- |
| speak(text, options?) | 整段阅读：创建任务、输入文本并结束输入 |
| start(options?) | 建立一次增量阅读任务，准备好后返回 taskId |
| appendText(taskId, text) | 按提交顺序追加文本 |
| finishInput(taskId) | 结束文本输入；剩余音频继续合成和播放 |
| cancel(taskId) | 放弃任务，立即终止合成、清空待播内容并停止播放 |
| destroy() | 停止任务并释放原生实例和监听 |

TTS 配置和请求按第 4.1 节完整覆盖。内置播放器作为 App 阅读的默认方案。音频格式、采样率等参数按官方支持范围开放，默认值和平台限制逐项记录。

Promise 表示对应操作被接受/达到文档规定阶段；speak 返回不表示已播放完成。区分连接就绪、Session 就绪、输入结束、合成结束、实际播放结束。FinishSession 只结束输入，不等同 cancel；cancel 的底层停止指令须单独映射。SDK 文档提及无尾标点时可能等待后续文本，finishInput 必须触发剩余文本处理。

启动期间文本按有界队列串行提交；超限返回明确错误，不丢字。不在 RN UI 线程阻塞调用同步停止指令。新任务必须在前次原生停止已确认后启动。

事件：ready、playbackStarted、synthesisFinished、playbackFinished、cancelled、error。句级播放事件仅在可靠对应时开放，不把句结束当整条结束。整条播放结束的判定需以双端实际回调和缓冲行为验证。

### 4.3 ASR

| 方法 | 语义 |
| --- | --- |
| start(options?) | 开始录音识别，返回 taskId |
| finishInput(taskId) | 结束音频输入并继续接收最终结果，不立即销毁 |
| cancel(taskId) | 放弃任务、停止麦克风，屏蔽后续识别结果 |
| destroy() | 释放任务和录音资源 |

App 按住说话默认使用内置录音机。ASR 配置和请求按第 4.1 节完整覆盖，包括音量、最大时长、语言、热词和 VAD。最终结果超时属于等待保护，不冒充服务端超时。实时识别的时长仍受服务端限制，不能以 maxDuration=-1 承诺无限识别。

事件：recordingStarted、volume、partialResult、finalResult、inputEnded、cancelled、error。音量归一至 0～1 的映射依据双端实际值验证；支持节流。partial 是当前假设文本，可修订，不能盲目追加；final 按官方分句/最终语义解析，不把单个最终分句误判为整个任务结束。

停止录音的指令映射须验证是发送结束包并等待最终结果；若普通 stop 会直接终止，则不得将其用于 finishInput。空录音作为明确结果/错误归类，取消不返回成功识别结果。

## 5. 事件、状态和错误契约

所有事件包含 instanceId、taskId、type 及对应 payload；taskId 由库生成，旧任务回调不得影响新任务。监听返回 remove，destroy 自动移除，终态只产生一次。取消后不得补发成功终态。finishInput 的 Promise 仅确认输入结束操作被接受，最终输出通过事件返回；重复 finishInput 不重复发送结束指令。cancel 对同实例已结束任务幂等，不补发 cancelled；destroy 异步释放且幂等，释放中拒绝新任务，成功返回后不再派发事件。旧任务 cancel 不得影响新任务；其他过期 taskId 操作返回 E_INVALID_TASK。updateCredentials 仅在实例空闲时允许，活动任务期间返回 E_BUSY。

TTS：idle → starting → streaming → draining → completed；可进入 cancelled / failed。
ASR：idle → starting → recording → finalizing → completed；可进入 cancelled / failed。

错误至少区分 E_NOT_LINKED、E_INVALID_ARGUMENT、E_INVALID_TASK、E_UNSUPPORTED、E_BUSY、E_PERMISSION、E_AUTH、E_NETWORK、E_TIMEOUT、E_NATIVE、E_DESTROYED；包含 message、原生码和可用 logId。凭证和完整用户文本不进入错误日志。错误不自动触发可能重复录音或播报的重试。

音频焦点、来电/系统中断、蓝牙/耳机变化在原生侧安全处理并通知宿主；默认不承诺自动恢复。首版冲突行为明确，不能通过全局录放设置破坏宿主其他播放器。

## 6. 与 promoter-app 的适配

保留 useHoldToTalkAsr 的手势、权限提示、60 秒上限、最后 10 秒倒计时、上滑取消与松手等待；只在最终任务结果确认后发送一次。中间结果首版可不展示，但库必须提供。

保留流式自动 TTS 的 Markdown 清理、断句合并和消息队列。开始录音前由业务调用 tts.cancel 停止播报；切换消息先取消旧任务，再开始新任务。腾讯 STS 改为实际豆包授权接口，契约不得猜测。清理腾讯依赖前搜索全仓调用；旧 App 所需后端腾讯接口按客户端淘汰计划处理。

## 7. 工程与文档

独立目录包含 src、android、ios、example、tests、scripts、docs、podspec 和包配置。目标首先验证 RN 0.83/React 19，新架构桥接方案按宿主兼容验证选择；不把宽 peer 范围当测试矩阵。

提供 build、typecheck、test、release:check 和 prepublishOnly；发布 TS 编译产物、声明和原生源码，宿主编译原生部分。支持 npm 与本地 tgz 安装。不得未经授权发布 npm 或推送仓库。

README 按功能、安装、平台配置、快速开始、API/参数、事件、错误和平台差异编排；docs 记录 RN→官方 SDK 映射、版本来源与验证状态。示例不绑定 promoter-app，使用占位凭证并覆盖整段朗读、增量朗读、录音与实时文字。

## 8. 实施前必须完成的 SDK 检查

1. 下载/解析实际 0.0.15.0 依赖，确认 ASR 和 BiTTS 符号同时存在、SDK 来源与版本匹配。
2. 核对双端 Demo 的启动、Session、输入结束、停止、播放结束和销毁流程，补齐映射表。
3. 核对 ASR 实时 URI（当前 Android SDK 示例为空），从其关联的最新版协议页及 Demo 确认，禁止复制旧接口地址猜测。
4. 确认账号 TTS 2.0、ASR 2.0 权限、音色与可用凭证机制。不得假定支持短期 Token。
5. 检查 Android 16 KB 页面、ABI、依赖冲突、Release 混淆和 iOS 真机/模拟器架构、部署版本、Pod 冲突。
6. 验证 SDK 的线程和引擎并发限制；若不支持预期，调整内部实例实现，不隐藏限制。
7. 官方示例有拼写/不完整代码及存储权限示例，不逐字复制；按实际二进制和现代系统必要权限实现。

任何 P0 缺失都不能以空桥接、假成功或 JS 自建 WebSocket 替代，需记录阻塞和可行调整。

## 9. 验收

| 场景 | 通过标准 |
| --- | --- |
| 双端构建 | RN 宿主 Debug/Release 可构建，真机可运行 |
| TTS 2.0 | 实际使用对应资源和音色，整段中文与中英混读可听 |
| 增量阅读 | 文本追加有序、不漏句不重复；无尾标点输入也能结束播放 |
| 完成事件 | 文字发送完不提前显示播放完成，最终音频结束只回调一次 |
| 打断 | cancel 后停止出声；切换消息与快速连续点击不串线 |
| 当前 ASR | 按住录音、音量、松手最终结果、60秒上限与取消符合原体验 |
| 实时 ASR | 中间结果持续更新、修订正确、最终分句和任务结束不混淆 |
| 异常 | 空音频、拒绝权限、凭证失败、断网、超时后可再次使用 |
| 生命周期 | 页面销毁、前后台和音频中断不遗留录音、声音或监听 |
| 官方参数完整性 | 按平台、引擎和指令逐字段对照官方清单，验证原名、嵌套、类型、默认值及实际传参。测试覆盖 0、false、可选字段省略和平台不支持等边界 |
| 包交付 | tgz 可安装，TS 类型检查与发布检查通过，文档可照做 |

准确率、首音延迟、停止延迟、识别最终结果耗时在相同设备和网络记录样本，不在未测量前宣称性能提升。热词需有实际命中样本，不能仅检查参数存在。

## 10. 交付与计划

当前仅创建项目目录和文档，不实现 SDK、不修改 promoter-app、不发布包。

后续目标：第1天完成双端封装与业务接入，第2天真机调试并达到可提测；这是条件性目标，依赖账号、SDK 可构建和设备到位，不是完成保证。遇到 SDK 不支持、构建或授权问题及时记录实际影响。
