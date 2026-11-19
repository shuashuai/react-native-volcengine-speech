import type { NativeSpeechConfig } from './config'

export type { AsrConfig, TtsConfig } from './config'
export type { AndroidNativeOptions, IosNativeOptions } from './nativeOptions'

export type JsonValue =
  | null
  | boolean
  | number
  | string
  | readonly JsonValue[]
  | JsonObject

export interface JsonObject {
  readonly [key: string]: JsonValue | undefined
}

export interface TtsSessionPayload extends JsonObject {
  readonly req_params: JsonObject & {
    readonly speaker: string
    readonly model?: string
    readonly additions?: string
    readonly audio_params?: JsonObject & {
      readonly format?: string
      readonly sample_rate?: number
      readonly bit_rate?: number
      readonly speech_rate?: number
      readonly loudness_rate?: number
      readonly enable_subtitle?: boolean
    }
  }
}

export interface TtsTaskPayload extends JsonObject {
  readonly req_params: JsonObject & {
    readonly text: string
  }
}

/** @deprecated Use TtsConfig or AsrConfig for shared initialization options. */
export type SpeechConfig = NativeSpeechConfig

export type SpeechEventType =
  | 'ready'
  | 'playbackStarted'
  | 'synthesisFinished'
  | 'playbackFinished'
  | 'recordingStarted'
  | 'inputEnded'
  | 'volume'
  | 'partialResult'
  | 'finalResult'
  | 'cancelled'
  | 'error'

export interface SpeechEvent {
  readonly instanceId: string
  readonly taskId: string
  readonly type: SpeechEventType
  readonly payload?: JsonObject
}

export interface Subscription {
  remove(): void
}

interface SpeechInstance {
  addListener(listener: (event: SpeechEvent) => void): Subscription
  finishInput(taskId: string): Promise<void>
  cancel(taskId: string): Promise<void>
  destroy(): Promise<void>
}

export interface Synthesizer extends SpeechInstance {
  start(payload: TtsSessionPayload): Promise<string>
  speak(text: string, payload: TtsSessionPayload): Promise<string>
  appendText(taskId: string, payload: TtsTaskPayload): Promise<void>
}

export interface Recognizer extends SpeechInstance {
  start(payload?: JsonObject): Promise<string>
}
