import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { componentSnapshot } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DivinationRecord } from '../model/DivinationRecord';

const TAG: string = 'ShareImageService';

export class ShareImageService {
  static buildShareImageFileName(record: DivinationRecord): string {
    return 'xingkey_tarot_' + record.id + '.png';
  }

  static async saveSharePreviewToGallery(
    context: common.UIAbilityContext,
    componentId: string,
    record: DivinationRecord
  ): Promise<string> {
    const pixelMap: image.PixelMap = await componentSnapshot.get(componentId);
    const pngData: ArrayBuffer = await ShareImageService.packPixelMapToPng(pixelMap);
    return ShareImageService.savePngDataToGallery(context, pngData, ShareImageService.buildShareImageFileName(record));
  }

  private static async packPixelMapToPng(pixelMap: image.PixelMap): Promise<ArrayBuffer> {
    const packer: image.ImagePacker = image.createImagePacker();
    try {
      const options: image.PackingOption = {
        format: 'image/png',
        quality: 100
      };
      return await packer.packing(pixelMap, options);
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
      await ShareImageService.ensureAlbumPermission(context);
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

  private static async ensureAlbumPermission(context: common.UIAbilityContext): Promise<void> {
    const permissions: Permissions[] = ['ohos.permission.WRITE_IMAGEVIDEO'];
    const atManager = abilityAccessCtrl.createAtManager();
    const result = await atManager.requestPermissionsFromUser(context, permissions);
    const granted: boolean = result.authResults.length > 0 && result.authResults[0] === 0;
    if (!granted) {
      throw new Error('未获得相册保存权限');
    }
  }
}
