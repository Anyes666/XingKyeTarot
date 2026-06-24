import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { fileUri } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'ImageUtil';

export class ImageUtil {
  static async savePixelMapToCache(context: Context, pixelMap: image.PixelMap, fileName: string): Promise<string> {
    const cacheDir: string = context.cacheDir;
    const filePath: string = `${cacheDir}/${fileName}`;

    const packer: image.ImagePacker = image.createImagePacker();
    const packOpts: image.PackingOption = {
      format: 'image/png',
      quality: 90
    };

    try {
      const data: ArrayBuffer = await packer.packToData(pixelMap, packOpts);
      const file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(file.fd, data);
      fileIo.closeSync(file);
      hilog.info(0x0000, TAG, 'Share image saved to: %{public}s', filePath);
      return filePath;
    } catch (err) {
      hilog.error(0x0000, TAG, 'Failed to save share image: %{public}s', JSON.stringify(err));
      throw new Error('保存分享图失败');
    } finally {
      packer.release();
    }
  }

  static getShareableUri(filePath: string): string {
    try {
      const uri: string = fileUri.getUriFromPath(filePath);
      return uri;
    } catch (err) {
      return filePath;
    }
  }
}
