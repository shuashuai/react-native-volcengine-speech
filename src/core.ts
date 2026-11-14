import type {
  JsonObject,
  SpeechConfig,
  SpeechEvent,
  Subscription,
} from './types'

type Operation = 'start' | 'appendText' | 'finishInput' | 'cancel' | 'destroy'
type Engine = 'tts' | 'asr'

export interface Bridge {
  invoke(
    operation: Operation,
    instanceId: string,
    taskId: string | null,
    kind: Engine,
    payload?: JsonObject,
    config?: SpeechConfig,
  ): Promise<void>
  subscribe(listener: (event: SpeechEvent) => void): Subscription
}

let nextInstance = 0

export function createInstance(bridge: Bridge, kind: Engine, config: SpeechConfig) {
  const instanceId = `${kind}-${++nextInstance}`
  let nextTask = 0
  let activeTask: string | undefined
  let finish: Promise<void> | undefined
  let cancellation: Promise<void> | undefined
  let disposal: Promise<void> | undefined
  let subscription: Subscription | undefined
  const listeners = new Set<(event: SpeechEvent) => void>()

  function subscribe() {
    subscription ??= bridge.subscribe(event => {
      if (disposal || event.instanceId !== instanceId || event.taskId !== activeTask) {
        return
      }
      const terminal = event.type === 'error'
        || event.type === 'cancelled'
        || event.type === 'playbackFinished'
        || event.type === 'finalResult'
      if (terminal) {
        activeTask = undefined
      }
      for (const listener of [...listeners]) {
        listener(event)
      }
    })
  }

  async function start(payload?: JsonObject) {
    if (disposal) {
      throw new Error('E_DESTROYED')
    }
    if (activeTask || cancellation) {
      throw new Error('E_BUSY')
    }

    const taskId = `${instanceId}-${++nextTask}`
    activeTask = taskId
    finish = undefined

    try {
      subscribe()
      await bridge.invoke('start', instanceId, taskId, kind, payload, config)
      return taskId
    }
    catch (error) {
      if (activeTask === taskId) {
        activeTask = undefined
      }
      throw error
    }
  }

  async function appendText(taskId: string, payload: JsonObject) {
    if (disposal || taskId !== activeTask || finish || cancellation) {
      throw new Error('E_INVALID_TASK')
    }
    await bridge.invoke('appendText', instanceId, taskId, kind, payload)
  }

  async function finishInput(taskId: string) {
    if (disposal || taskId !== activeTask || cancellation) {
      throw new Error('E_INVALID_TASK')
    }
    finish ??= bridge.invoke('finishInput', instanceId, taskId, kind)
    return finish
  }

  async function cancel(taskId: string) {
    if (disposal || taskId !== activeTask) {
      return
    }
    cancellation ??= bridge.invoke('cancel', instanceId, taskId, kind)
      .then(() => {
        if (activeTask === taskId) {
          activeTask = undefined
        }
      })
      .finally(() => {
        cancellation = undefined
      })
    return cancellation
  }

  function destroy() {
    disposal ??= Promise.resolve().then(async () => {
      listeners.clear()
      subscription?.remove()
      if (subscription) {
        await bridge.invoke('destroy', instanceId, null, kind)
      }
      subscription = undefined
      activeTask = undefined
    })
    return disposal
  }

  function addListener(listener: (event: SpeechEvent) => void) {
    if (disposal) {
      throw new Error('E_DESTROYED')
    }
    listeners.add(listener)
    return { remove: () => { listeners.delete(listener) } }
  }

  return { start, appendText, finishInput, cancel, destroy, addListener }
}
