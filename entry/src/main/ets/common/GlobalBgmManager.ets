import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'GlobalBgmManager';

/**
 * BGM 播放状态
 */
export interface BgmPlayState {
  isPlaying: boolean;
  isPaused: boolean;
}

/**
 * 全局背景音乐管理器（单例）
 *
 * 职责：
 * 1. 持有唯一的 AVPlayer 实例，确保全 App 只播放一份背景音乐
 * 2. 播放 rawfile/bgm_calm_ambient.mp3（Calm Ambient — leberch / Pixabay）
 * 3. 循环播放
 * 4. 暂停 / 恢复 / 停止并释放
 * 5. 设置音量（默认低音量 0.20）
 * 6. 页面切换不重复创建播放器
 */
export class GlobalBgmManager {
  private static instance: GlobalBgmManager | null = null;
  private player: media.AVPlayer | null = null;
  private isPlaying: boolean = false;
  private isPaused: boolean = false;
  private isInitialized: boolean = false;
  private isPrepared: boolean = false;
  private isPreparing: boolean = false;
  private playRequested: boolean = false;
  private volumeValue: number = 0.20;
  private rawFileName: string = 'bgm_calm_ambient.mp3';
  private context: common.UIAbilityContext | null = null;
  private isMusicEnabled: boolean = true;
  private isBackgroundPaused: boolean = false;

  /**
   * 获取单例
   */
  static getInstance(): GlobalBgmManager {
    if (!GlobalBgmManager.instance) {
      GlobalBgmManager.instance = new GlobalBgmManager();
    }
    return GlobalBgmManager.instance;
  }

  /**
   * 从 PreferenceStore 加载 bgm_enabled 持久化偏好
   * 应在 init() 之前调用，确保初始化阶段就能知道用户的开关状态
   * @param context UIAbilityContext
   */
  async loadPreference(context: common.UIAbilityContext): Promise<void> {
    try {
      const prefModule = await import('../data/PreferenceStore');
      const PreferenceStore = prefModule.PreferenceStore;
      const enabled: boolean = await PreferenceStore.getBoolean('bgm_enabled', true, context);
      this.isMusicEnabled = enabled;
      hilog.info(0x0000, TAG, 'loadPreference: bgm_enabled=%{public}s', String(enabled));
    } catch (err) {
      hilog.warn(0x0000, TAG, 'loadPreference failed, keep default: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 初始化播放器（仅在首次调用时创建 AVPlayer）
   * @param context UIAbilityContext（用于获取 rawfile 资源描述符）
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.isInitialized || this.player !== null) {
      hilog.info(0x0000, TAG, 'init: player already initialized, skip');
      return;
    }
    if (this.isPreparing) {
      hilog.info(0x0000, TAG, 'init: already preparing, skip');
      return;
    }
    this.isPreparing = true;
    this.context = context;

    try {
      // 创建 AVPlayer 实例
      this.player = await media.createAVPlayer();
      hilog.info(0x0000, TAG, 'init: AVPlayer created');

      // 注册状态变化回调
      this.setupPlayerCallbacks();

      // 获取 rawfile 的文件描述符
      const fdObj: resourceManager.RawFileDescriptor = await context.resourceManager.getRawFd(this.rawFileName);

      // 构造 AVFileDescriptor
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: fdObj.fd,
        offset: fdObj.offset,
        length: fdObj.length
      };

      // 设置播放源
      this.player.fdSrc = avFileDescriptor;
      // 注意：设置完 fdSrc 后 AVPlayer 会持有 fd，由播放器管理其生命周期

      this.isInitialized = true;
      hilog.info(0x0000, TAG, 'init: fdSrc set successfully');
    } catch (err) {
      hilog.error(0x0000, TAG, 'init error: %{public}s', JSON.stringify(err));
      this.player = null;
      this.isInitialized = false;
    } finally {
      this.isPreparing = false;
    }
  }

  /**
   * 设置 AVPlayer 事件回调（状态机流转）
   */
  private setupPlayerCallbacks(): void {
    if (!this.player) {
      return;
    }

    // 状态变化监听
    this.player.on('stateChange', (state: string) => {
      hilog.info(0x0000, TAG, 'stateChange: %{public}s', state);
      switch (state) {
        case 'initialized':
          // 设置完 fdSrc 后自动进入 initialized，调用 prepare
          this.player?.prepare();
          break;
        case 'prepared':
          // 准备完成后设置循环播放和音量
          this.isPrepared = true;
          if (this.player) {
            this.player.loop = true;
            this.player.setVolume(this.volumeValue);
          }
          // 如果之前调用过 play()，且用户未关闭音乐，prepared 后自动播放
          if (this.playRequested && !this.isPlaying && this.isMusicEnabled) {
            this.player?.play();
          } else if (this.playRequested && !this.isMusicEnabled) {
            hilog.info(0x0000, TAG, 'prepared: music disabled, skip auto-play');
          }
          hilog.info(0x0000, TAG, 'prepared: ready to play, playRequested=%{public}s', String(this.playRequested));
          break;
        case 'playing':
          this.isPlaying = true;
          this.isPaused = false;
          hilog.info(0x0000, TAG, 'stateChange: playing');
          break;
        case 'paused':
          this.isPaused = true;
          hilog.info(0x0000, TAG, 'stateChange: paused');
          break;
        case 'completed':
          // 循环播放模式下理论上不会到这里，但作为兜底
          if (this.player) {
            this.player.loop = true;
          }
          hilog.info(0x0000, TAG, 'stateChange: completed');
          break;
        case 'stopped':
          this.isPlaying = false;
          hilog.info(0x0000, TAG, 'stateChange: stopped');
          break;
        case 'released':
          this.isPlaying = false;
          hilog.info(0x0000, TAG, 'stateChange: released');
          break;
        case 'error':
          hilog.error(0x0000, TAG, 'stateChange: error');
          break;
      }
    });

    // 错误处理
    this.player.on('error', (err) => {
      hilog.error(0x0000, TAG, 'player error: code=%{public}d, msg=%{public}s',
        err.code, err.message);
      // 出错后尝试重置
      try {
        this.player?.reset();
      } catch (e) {
        hilog.error(0x0000, TAG, 'reset after error failed');
      }
    });
  }

  /**
   * 播放背景音乐（如果尚未播放）
   * 幂等：多次调用不会叠加
   * 尊重 isMusicEnabled：用户关闭后不会自动播放
   */
  async play(): Promise<void> {
    if (!this.isMusicEnabled) {
      hilog.info(0x0000, TAG, 'play: music disabled by user, skip');
      return;
    }

    if (this.player === null) {
      hilog.warn(0x0000, TAG, 'play: player not initialized');
      return;
    }

    if (this.isPlaying && !this.isPaused) {
      hilog.info(0x0000, TAG, 'play: already playing, skip');
      return;
    }

    // 标记"想播放"——如果还没 prepared，等 prepared 回调自动播放
    this.playRequested = true;

    // 如果已经 prepared，直接播放；否则等 prepared 回调触发
    if (this.isPrepared) {
      try {
        this.player.setVolume(this.volumeValue);
        this.player.play();
        hilog.info(0x0000, TAG, 'play: started (already prepared)');
      } catch (err) {
        hilog.error(0x0000, TAG, 'play error: %{public}s', JSON.stringify(err));
      }
    } else {
      hilog.info(0x0000, TAG, 'play: deferred, waiting for prepared');
    }
  }

  /**
   * 暂停背景音乐（切后台时调用，或用户关闭开关时调用）
   * 幂等：多次调用不会叠加
   * 同步设置 isPaused=true 以避免状态机回调延迟导致的竞态
   */
  async pause(): Promise<void> {
    if (this.player === null) {
      return;
    }
    if (!this.isPlaying || this.isPaused) {
      return;
    }

    try {
      this.player.pause();
      // 同步标记暂停状态，不等 stateChange 回调，防止 resume() 在回调前被调用时误判
      this.isPaused = true;
      hilog.info(0x0000, TAG, 'pause: paused');
    } catch (err) {
      hilog.error(0x0000, TAG, 'pause error: %{public}s', JSON.stringify(err));
      // 暂停失败也要标记，避免开关卡死
      this.isPaused = true;
    }
  }

  /**
   * 恢复播放（回前台时调用，或用户开启开关时调用）
   * 尊重 isMusicEnabled：用户关闭后不会自动恢复
   * 同步设置 isPaused=false 以避免状态机回调延迟导致的竞态
   */
  async resume(): Promise<void> {
    if (!this.isMusicEnabled) {
      hilog.info(0x0000, TAG, 'resume: music disabled by user, skip');
      return;
    }

    if (this.player === null) {
      return;
    }
    if (!this.isPaused) {
      return;
    }

    try {
      this.player.setVolume(this.volumeValue);
      this.player.play();
      // 同步标记恢复状态，不等 stateChange 回调
      this.isPaused = false;
      hilog.info(0x0000, TAG, 'resume: resumed');
    } catch (err) {
      hilog.error(0x0000, TAG, 'resume error: %{public}s', JSON.stringify(err));
      // 恢复失败也要标记，避免开关卡死
      this.isPaused = false;
    }
  }

  /**
   * 停止并释放播放器（App 退出时调用）
   */
  async release(): Promise<void> {
    if (this.player === null) {
      return;
    }

    try {
      this.player.stop();
      this.player.reset();
      hilog.info(0x0000, TAG, 'release: player released');
    } catch (err) {
      hilog.error(0x0000, TAG, 'release error: %{public}s', JSON.stringify(err));
    } finally {
      this.player = null;
      this.isPlaying = false;
      this.isPaused = false;
      this.isInitialized = false;
    }
  }

  /**
   * 设置音量
   * @param vol 音量值 0.0 ~ 1.0
   */
  async setVolume(vol: number): Promise<void> {
    this.volumeValue = vol;
    if (this.player === null) {
      return;
    }

    try {
      this.player.setVolume(vol);
      hilog.info(0x0000, TAG, 'setVolume: %{public}f', vol);
    } catch (err) {
      hilog.error(0x0000, TAG, 'setVolume error: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 获取当前播放状态
   */
  getPlayState(): BgmPlayState {
    const state: BgmPlayState = { isPlaying: this.isPlaying, isPaused: this.isPaused };
    return state;
  }

  /**
   * 获取当前音量
   */
  getVolume(): number {
    return this.volumeValue;
  }

  /**
   * 获取是否已初始化
   */
  getIsInitialized(): boolean {
    return this.isInitialized;
  }

  /**
   * 获取背景音乐开关状态
   */
  getMusicEnabled(): boolean {
    return this.isMusicEnabled;
  }

  /**
   * 设置背景音乐开关状态
   * @param enabled true=开启，false=关闭
   */
  setMusicEnabled(enabled: boolean): void {
    if (this.isMusicEnabled === enabled) {
      return; // 状态未变，跳过，避免重复触发导致 Toggle 抖动
    }
    this.isMusicEnabled = enabled;
    if (!enabled) {
      // 关闭：pause 播放器（不 stop），保持 prepared 状态以便后续恢复
      this.pause();
      hilog.info(0x0000, TAG, 'setMusicEnabled: disabled, player paused');
    } else {
      // 开启后尝试恢复播放
      if (this.isInitialized && this.isPrepared && this.isPaused) {
        // 之前是暂停状态 → 恢复播放
        this.resume();
        hilog.info(0x0000, TAG, 'setMusicEnabled: enabled, resumed from pause');
      } else if (this.isInitialized && this.isPrepared && !this.isPlaying) {
        // 之前被 stop 过（isPaused=false 但 isPlaying=false）
        // 需要重新 play（内部会处理 prepared → playing 转换）
        this.play();
        hilog.info(0x0000, TAG, 'setMusicEnabled: enabled, restarting play (was stopped)');
      } else if (!this.isInitialized) {
        // 尚未初始化，标记为启用，后续 init 完成后由 play() 自动播放
        hilog.info(0x0000, TAG, 'setMusicEnabled: enabled, deferred (not initialized yet)');
      } else {
        hilog.info(0x0000, TAG, 'setMusicEnabled: enabled, no action needed');
      }
    }
  }

  /**
   * 停止播放（内部使用，用于关闭音乐时彻底停掉音频输出）
   */
  private stopPlayer(): void {
    if (this.player === null) {
      return;
    }
    try {
      this.player.stop();
      this.isPlaying = false;
      this.isPaused = false;
      this.playRequested = false;
      hilog.info(0x0000, TAG, 'stopPlayer: stopped');
    } catch (err) {
      hilog.error(0x0000, TAG, 'stopPlayer error: %{public}s', JSON.stringify(err));
    }
  }
}
