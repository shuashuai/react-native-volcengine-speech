# SDK 官方文档核验记录

核验日期：2026-11-10（Asia/Shanghai）。仅使用火山官方来源；区分文档依据与二进制/设备验证。网页更新日期不等于 SDK 发布日期。

## 当前文档入口

| 来源 | URL | 本次证据状态 |
| --- | --- | --- |
| Android BiTTS SDK | https://docs.volcengine.com/docs/doubao-voice/bidirectional-streaming-tts-android-sdk-interface-documentation-1?lang=zh | 本次直接读取仅页面壳；官方搜索正文在前次核验明确列出0.0.15.0、seed-tts-2.0；页面显示2026-09-28更新，实施前补正文/包验证 |
| iOS BiTTS SDK | https://docs.volcengine.com/docs/DoubaoVoice/bidirectional-streaming-tts-ios-sdk-interface-documentation?lang=zh | 本次正文可读，明确0.0.15.0、TTS2.0资源、内置播放器、Session及FinishSession |
| Android ASR SDK | https://docs.volcengine.com/docs/doubao-voice/large-model-streaming-automatic-speech-recognition-android-sdk-interface?lang=zh | 本次正文可读，明确0.0.15.0、ASR2.0资源、内置录音机、音量、时长及输入选项 |
| iOS ASR SDK | https://docs.volcengine.com/docs/doubao-voice/large-model-streaming-automatic-speech-recognition-ios-sdk-interface?lang=zh | 本次直接读取仅页面壳；此前官方搜索正文明确流式结果、ASR2.0资源及内置录音；页面显示2026-09-28更新，实施前补正文/包验证 |

这些是新版大模型 SDK 专项入口，不采用旧“离在线语音合成”5.x文档作为TTS2.0依据，也不采用0.0.14.6.1-bugfix的非双向TTS组合。0.0.15.0是文档基线，尚未查询依赖仓库最新版本或下载二进制。

## 需求与依据

- TTS2.0及增量文本：新版BiTTS文档；支持文本流输入与音频流输出。
- 原生播放：iOS文档明确内置播放器默认启用；双端的实际播放结束与停止行为待实测。
- ASR实时识别：新版ASR文档明确音频/结果流式；输入结束与最终结果回调需按Demo验证。
- 录音和波形：Android正文明确内置录音及音量开关；iOS音量符号/范围需包内核对。
- 60秒上限：Android文档提供最大录音时长，单位ms；业务倒计时继续由宿主维护。
- 热词：通过ASR请求参数配置，具体资源权限和效果须样本验证。
- 不自行维护WebSocket：原生SDK负责网络，RN仅桥接方法和事件；不表示SDK不使用WebSocket。

## 未验证事项

SDK依赖可下载性、完整头文件/API符号、RN0.83互操作、ASR/BiTTS同包共存、16KB页面支持、Release构建、实际授权方式、实时URI、iOS音量、播放完成、打断延迟、资源释放均未实测。PRD第8/9节为实施与验收门槛。

官方网页存在正文动态加载和示例不完整情况；如果文档与实际SDK不一致，以核实后的包版本、官方Demo及技术支持结论更新记录，不凭旧文档补猜。


## 原生桥接初版验证

- Android 0.0.15.0 AAR 已下载并通过归档校验。Java 源码已使用实际 AAR 中的 classes.jar、Android API 36 和 RN 0.83.3 API jar 编译。
- iOS 0.0.15.0 Podspec 和官方 tar.xz 已下载。Objective-C 源码已使用实际头文件、iPhoneOS SDK 和宿主 RN 头文件通过语法检查。
- ASR 正常结束映射为 FinishTalking，取消销毁对应引擎。TTS 使用 StartSession、TaskRequest、FinishSession，播放和合成分别接收回调。
- 当前桥接保留原生参数键和请求 JSON 结构。完整逐字段类型、映射和参数验收仍待补齐，尤其是原生整数与浮点参数的区别和可选音频源。
- 初版全局一次只允许一个活动任务。完整宿主构建、RN 自动链接、实际录放、合成完成与播放结束的顺序、音量归一及识别数据解析仍需验证。

## 参数和 npm 打包检查

- 对照 Android AAR 的常量值和 iOS 头文件中的原生常量生成选项声明及 setter 映射。引擎选择保留在库内。Android 以实际键值为公开名称，iOS 以常量名称为公开名称。
- 官方请求 JSON 以原名和原结构传递。TTS 部分字段已有显式类型，完整 ASR/TTS 协议逐字段声明、值域和条件校验仍待补齐。
- 已执行 TypeScript 类型检查和编译、Android Java 编译、iOS Objective-C 语法检查及 npm pack dry-run。宿主链接、录放与参数生效待联调。
