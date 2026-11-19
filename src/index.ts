import { NativeEventEmitter, NativeModules } from 'react-native'

import { resolveNativeConfig } from './config'
import { createInstance } from './core'
import type { Bridge } from './core'
import type { AsrConfig, Recognizer, SpeechEvent, Synthesizer, TtsConfig } from './types'

export * from './types'
export { DEFAULT_ASR_CONFIG, DEFAULT_TTS_CONFIG } from './config'

function nativeModule() {
  const module = NativeModules.RNVolcengineSpeech
  if (!module) {
    throw new Error('E_NOT_LINKED: RNVolcengineSpeech is unavailable')
  }
  return module
}

const bridge: Bridge = {
  async invoke(operation, instanceId, taskId, kind, payload, config) {
    // Android Bridgeless requires all arguments declared by the native module.
    await nativeModule().invoke(
      operation,
      instanceId,
      taskId,
      kind,
      payload ?? null,
      config ?? null,
    )
  },
  subscribe(listener) {
    return new NativeEventEmitter(nativeModule()).addListener(
      'RNVolcengineSpeechEvent',
      event => listener(event as SpeechEvent),
    )
  },
}

export function createSynthesizer(config: TtsConfig): Synthesizer {
  const instance = createInstance(bridge, 'tts', resolveNativeConfig(config, 'tts'))

  return {
    ...instance,
    async speak(text, payload) {
      const taskId = await instance.start(payload)
      try {
        await instance.appendText(taskId, { req_params: { text } })
        await instance.finishInput(taskId)
        return taskId
      }
      catch (error) {
        await instance.cancel(taskId).catch(() => undefined)
        throw error
      }
    },
  }
}

export function createRecognizer(config: AsrConfig): Recognizer {
  const { start, finishInput, cancel, destroy, addListener } =
    createInstance(bridge, 'asr', resolveNativeConfig(config, 'asr'))

  return { start, finishInput, cancel, destroy, addListener }
}

export default { createSynthesizer, createRecognizer }
