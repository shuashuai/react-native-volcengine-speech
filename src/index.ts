import { NativeEventEmitter, NativeModules } from 'react-native'

import { createInstance } from './core'
import type { Bridge } from './core'
import type { Recognizer, SpeechConfig, Synthesizer } from './types'

export * from './types'

function nativeModule() {
  const module = NativeModules.RNVolcengineSpeech
  if (!module) {
    throw new Error('E_NOT_LINKED: RNVolcengineSpeech is unavailable')
  }
  return module
}

const bridge: Bridge = {
  async invoke(...args) {
    await nativeModule().invoke(...args)
  },
  subscribe(listener) {
    return new NativeEventEmitter(nativeModule()).addListener(
      'RNVolcengineSpeechEvent',
      listener,
    )
  },
}

export function createSynthesizer(config: SpeechConfig): Synthesizer {
  const instance = createInstance(bridge, 'tts', config)

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

export function createRecognizer(config: SpeechConfig): Recognizer {
  const { start, finishInput, cancel, destroy, addListener } =
    createInstance(bridge, 'asr', config)

  return { start, finishInput, cancel, destroy, addListener }
}

export default { createSynthesizer, createRecognizer }
