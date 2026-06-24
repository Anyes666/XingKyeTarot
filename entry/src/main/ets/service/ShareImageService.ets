import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'ShareImageService';

export class ShareImageService {
  static buildShareImageFileName(recordId: string): string {
    return 'xingkey_tarot_' + recordId + '.png';
  }

  /**
   * 将 PixelMap 编码为 PNG 并保存到系统相册。
   * 截图逻辑在组件层完成（DivinationResultPage），此处只做编码+存储。
   */
  static async savePixelMapToGallery(
    context: common.UIAbilityContext,
    pixelMap: image.PixelMap,
    fileName: string
  ): Promise<string> {
    const pngData: ArrayBuffer = await ShareImageService.packPixelMapToPng(pixelMap);
    return ShareImageService.savePngDataToGallery(context, pngData, fileName);
  }

  private static async packPixelMapToPng(pixelMap: image.PixelMap): Promise<ArrayBuffer> {
    const packer: image.ImagePacker = image.createImagePacker();
    try {
      const options: image.PackingOption = {
        format: 'image/png',
        quality: 100
      };
      return await packer.packToData(pixelMap, options);
    } catch (err) {
      hilog.error(0x0000, TAG, 'Pack share image failed: %{public}s', JSON.stringify(err));
      throw new Error('生成分享图片失败');
    } finally {
      packer.release();
    }
  }

  private static async savePngDataToGallery(
    context: common.UIAbilityContext,
    pngData: ArrayBuffer,
    _fileName: string
  ): Promise<string> {
    try {
      const granted: boolean = await ShareImageService.ensureAlbumPermission(context);
      if (!granted) {
        hilog.warn(0x0000, TAG, 'Album permission denied');
        throw new Error('未获得相册保存权限');
      }
      const helper = photoAccessHelper.getPhotoAccessHelper(context);
      const uri: string = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
      const file: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
      try {
        fileIo.writeSync(file.fd, pngData);
      } finally {
        fileIo.closeSync(file);
      }
      hilog.info(0x0000, TAG, 'Share image saved to gallery: %{public}s', uri);
      return uri;
    } catch (err) {
      hilog.error(0x0000, TAG, 'Save share image failed: %{public}s', JSON.stringify(err));
      throw new Error('保存到相册失败');
    }
  }

  private static async ensureAlbumPermission(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const permissions: Permissions[] = ['ohos.permission.WRITE_IMAGEVIDEO'];
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(context, permissions);
      return result.authResults.length > 0 && result.authResults[0] === 0;
    } catch (err) {
      hilog.error(0x0000, TAG, 'Request album permission failed: %{public}s', JSON.stringify(err));
      return false;
    }
  }
}
