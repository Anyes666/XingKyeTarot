import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri } from '@kit.CoreFileKit';

/**
 * 保存图片操作结果（含诊断字段）
 */
export interface SaveImageResult {
  success: boolean;
  savedToAlbum: boolean;
  savedUri: string;
  message: string;
  stage: string;        // 'start'|'capture'|'pack'|'createAsset'|'openAsset'|'writeAsset'|'closeAsset'|'permission'|'cancel'|'cleanup'|'unknown'
  errorCode: string;    // BusinessError.code 字符串，无则空
  errorMessage: string; // BusinessError.message 或 err 字符串化
}

/**
 * 分享图保存服务
 *
 * 保存流程（每步独立 try/catch + 日志）：
 * 1. pack — PixelMap 编码为 PNG ArrayBuffer
 * 2. createAsset — 通过 showAssetsCreationDialog 创建相册资源（用户确认授权）
 * 3. writeAsset — 将 PNG 数据写入临时文件供系统读取
 * 4. cleanup — 清理临时文件
 *
 * 截图 API：UIContext.getComponentSnapshot().get()
 * 图片编码 API：image.createImagePacker().packToData(pixelMap, options)
 * 相册保存 API：photoAccessHelper.showAssetsCreationDialog(srcUris, configs)
 */
export class ShareImageService {
  /**
   * 根据记录 ID 生成分享图片文件名
   */
  static buildShareImageFileName(recordId: string): string {
    return 'xingkey_tarot_' + recordId + '.png';
  }

  /**
   * 安全提取错误的 code 和 message
   *
   * BusinessError 是 @kit.BasicServicesKit 的标准接口，可用 as 强转。
   * 如果强转失败，fallback 用 JSON.stringify。
   *
   * @param err - 捕获到的错误对象
   * @returns [code, message] 字符串数组
   */
  private static extractError(err: Object): string[] {
    let code: string = '';
    let msg: string = '';
    try {
      const businessErr: BusinessError = err as BusinessError;
      if (businessErr.code !== undefined && businessErr.code !== null) {
        code = String(businessErr.code);
      }
      if (businessErr.message !== undefined && businessErr.message !== null) {
        msg = businessErr.message;
      }
    } catch (_e) {
      // as 强转失败，fallback
    }
    if (code === '' || msg === '') {
      try {
        const str: string = JSON.stringify(err);
        if (code === '') {
          code = str;
        }
        if (msg === '') {
          msg = str;
        }
      } catch (_e2) {
        // ignore
      }
    }
    const result: string[] = [code, msg];
    return result;
  }

  /**
   * 构建失败的 SaveImageResult
   *
   * @param stage - 失败阶段
   * @param code - 错误码
   * @param msg - 错误信息
   * @param userMessage - 给用户看的 Toast 文案
   * @returns SaveImageResult
   */
  private static buildFailResult(
    stage: string,
    code: string,
    msg: string,
    userMessage: string
  ): SaveImageResult {
    const result: SaveImageResult = {
      success: false,
      savedToAlbum: false,
      savedUri: '',
      message: userMessage,
      stage: stage,
      errorCode: code,
      errorMessage: msg
    };
    return result;
  }

  /**
   * 将 PixelMap 打包为 PNG 并保存到系统相册，返回结构化结果（含诊断字段）
   *
   * 使用 showAssetsCreationDialog 方式保存：
   * 1. pack PixelMap → PNG ArrayBuffer
   * 2. 将 PNG 写入 cacheDir 临时文件
   * 3. 调用 showAssetsCreationDialog 让用户确认保存
   * 4. 系统自动将临时文件复制到相册
   * 5. 清理临时文件
   *
   * @param context - UIAbilityContext
   * @param pixelMap - 截图得到的 PixelMap
   * @param fileName - 文件名
   * @returns SaveImageResult 结构化结果
   */
  static async savePixelMapToGalleryWithResult(
    context: common.UIAbilityContext,
    pixelMap: image.PixelMap,
    fileName: string
  ): Promise<SaveImageResult> {
    console.info('[ShareImage] start save');

    // ── 阶段 1: pack — PixelMap 编码为 PNG ──
    let pngData: ArrayBuffer;
    try {
      const packer: image.ImagePacker = image.createImagePacker();
      try {
        const options: image.PackingOption = { format: 'image/png', quality: 100 };
        pngData = await packer.packToData(pixelMap, options);
      } finally {
        packer.release();
      }
      console.info('[ShareImage] pack success, length=' + pngData.byteLength);
    } catch (err) {
      const extracted: string[] = ShareImageService.extractError(err);
      const code: string = extracted[0];
      const msg: string = extracted[1];
      console.error('[ShareImage] failed at pack, code=' + code + ', message=' + msg);
      return ShareImageService.buildFailResult('pack', code, msg, '保存失败，请稍后再试');
    }

    // ── 阶段 2: writeAsset — 将 PNG 写入临时文件 ──
    let tempFilePath: string;
    try {
      const cacheDir: string = context.cacheDir;
      tempFilePath = cacheDir + '/' + fileName;
      const tempFile: fileIo.File = fileIo.openSync(
        tempFilePath,
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC
      );
      try {
        fileIo.writeSync(tempFile.fd, pngData);
        console.info('[ShareImage] write temp file success, path=' + tempFilePath);
      } finally {
        fileIo.closeSync(tempFile);
      }
    } catch (err) {
      const extracted: string[] = ShareImageService.extractError(err);
      const code: string = extracted[0];
      const msg: string = extracted[1];
      console.error('[ShareImage] failed at writeAsset, code=' + code + ', message=' + msg);
      return ShareImageService.buildFailResult('writeAsset', code, msg, '保存失败，请稍后再试');
    }

    // ── 阶段 3: dialog — 通过 showAssetsCreationDialog 创建相册资源 ──
    let destUri: string;
    try {
      // 3.1 验证临时文件存在且大小>0
      let tempFileSize: number = 0;
      try {
        const stat: fileIo.Stat = fileIo.statSync(tempFilePath);
        tempFileSize = stat.size;
        console.info('[ShareImage] tempPath=' + tempFilePath);
        console.info('[ShareImage] temp file size=' + tempFileSize);
      } catch (statErr) {
        const statExtracted: string[] = ShareImageService.extractError(statErr);
        console.error('[ShareImage] stat temp file failed, code=' + statExtracted[0] + ', message=' + statExtracted[1]);
        return ShareImageService.buildFailResult('emptyTempFile', statExtracted[0], statExtracted[1], '保存失败，请稍后再试');
      }
      if (tempFileSize <= 0) {
        console.error('[ShareImage] temp file size <= 0, path=' + tempFilePath);
        return ShareImageService.buildFailResult('emptyTempFile', '', 'temp file size is 0', '保存失败，请稍后再试');
      }

      // 3.2 用 fileUri.getUriFromPath 把 path 转成 file:// URI
      const tempFileUri: string = fileUri.getUriFromPath(tempFilePath);
      console.info('[ShareImage] tempFileUri=' + tempFileUri);
      const srcUris: string[] = [tempFileUri];

      // 3.3 PhotoCreationConfig 最小化（先不加 title/subtype/displyName）
      const config: photoAccessHelper.PhotoCreationConfig = {
        fileNameExtension: 'png',
        photoType: photoAccessHelper.PhotoType.IMAGE
      };
      const configs: photoAccessHelper.PhotoCreationConfig[] = [config];

      // 3.4 调用 showAssetsCreationDialog
      const helper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      console.info('[ShareImage] dialog start, srcUris.length=' + srcUris.length + ', configs.length=' + configs.length);
      const savedUris: string[] =
        await helper.showAssetsCreationDialog(srcUris, configs);

      if (savedUris && savedUris.length > 0) {
        destUri = savedUris[0];
        console.info('[ShareImage] dialog success, savedUris.length=' + savedUris.length + ', destUri=' + destUri);
      } else {
        // 用户取消或无返回 URI
        console.info('[ShareImage] dialog cancelled by user (savedUris empty)');
        ShareImageService.cleanupTempFile(tempFilePath);
        const cancelResult: SaveImageResult = {
          success: false,
          savedToAlbum: false,
          savedUri: '',
          message: '已取消保存',
          stage: 'cancel',
          errorCode: '',
          errorMessage: 'User cancelled showAssetsCreationDialog'
        };
        return cancelResult;
      }
    } catch (err) {
      const extracted: string[] = ShareImageService.extractError(err);
      const code: string = extracted[0];
      const msg: string = extracted[1];
      console.error('[ShareImage] failed at dialog, code=' + code + ', message=' + msg);
      console.error('[ShareImage] dialog failed tempPath=' + tempFilePath + ', tempFileUri see above, context=' + (context ? 'valid' : 'null'));
      ShareImageService.cleanupTempFile(tempFilePath);

      if (code === '139' || code === '1400001' || code === '201' || msg.includes('permission') || msg.includes('Permission')) {
        return ShareImageService.buildFailResult(
          'permission', code, msg,
          '需要允许保存图片权限后才能保存分享卡'
        );
      }
      // 用户 Toast 中带上 errorCode 方便真机定位
      const userTip: string = '保存失败：dialog:' + code;
      return ShareImageService.buildFailResult('dialog', code, msg, userTip);
    }

    // ── 阶段 4: copy — 将临时文件内容复制到目标 URI（关键步骤！）──
    // showAssetsCreationDialog 只返回目标 URI，不会自动复制文件内容
    try {
      console.info('[ShareImage] copy start, tempPath=' + tempFilePath + ', destUri=' + destUri);
      const srcFile: fileIo.File = fileIo.openSync(
        tempFilePath,
        fileIo.OpenMode.READ_ONLY
      );
      try {
        const destFile: fileIo.File = fileIo.openSync(
          destUri,
          fileIo.OpenMode.WRITE_ONLY
        );
        try {
          await fileIo.copyFile(srcFile.fd, destFile.fd);
          console.info('[ShareImage] copy success');
        } finally {
          fileIo.closeSync(destFile);
        }
      } finally {
        fileIo.closeSync(srcFile);
      }
    } catch (err) {
      const extracted: string[] = ShareImageService.extractError(err);
      const code: string = extracted[0];
      const msg: string = extracted[1];
      console.error('[ShareImage] failed at copy, code=' + code + ', message=' + msg);
      ShareImageService.cleanupTempFile(tempFilePath);
      return ShareImageService.buildFailResult('copy', code, msg, '保存失败，请稍后再试');
    }

    // ── 阶段 5: cleanup — 清理临时文件 ──
    ShareImageService.cleanupTempFile(tempFilePath);

    console.info('[ShareImage] save success');
    const successResult: SaveImageResult = {
      success: true,
      savedToAlbum: true,
      savedUri: destUri,
      message: '图片已保存到相册',
      stage: 'success',
      errorCode: '',
      errorMessage: ''
    };
    return successResult;
  }

  /**
   * 清理临时文件（静默失败）
   *
   * @param filePath - 临时文件路径
   */
  private static cleanupTempFile(filePath: string): void {
    try {
      if (fileIo.accessSync(filePath)) {
        fileIo.unlinkSync(filePath);
        console.info('[ShareImage] cleanup temp file success, path=' + filePath);
      }
    } catch (err) {
      console.error('[ShareImage] cleanup temp file failed: ' + JSON.stringify(err));
    }
  }
}
