//
//  ImageScaling.m
//  StillWaitin
//
//

#import "ImageScaling.h"

UIImage *UIImageScaledToSizeWithSameAspectRatio(UIImage *image, CGSize targetSize) {
  CGSize imageSize = image.size;
  CGFloat width = imageSize.width;
  CGFloat height = imageSize.height;
  CGFloat targetWidth = targetSize.width;
  CGFloat targetHeight = targetSize.height;
  CGFloat scaleFactor = 0.0;
  CGFloat scaledWidth = targetWidth;
  CGFloat scaledHeight = targetHeight;
  CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

  if (CGSizeEqualToSize(imageSize, targetSize) == NO)
  {
    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;

    if (widthFactor > heightFactor) {
      scaleFactor = widthFactor;  // scale to fit height
    } else {
      scaleFactor = heightFactor; // scale to fit width
    }

    scaledWidth = width * scaleFactor;
    scaledHeight = height * scaleFactor;

    // center image
    if (widthFactor > heightFactor) {
      thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
    } else if (widthFactor < heightFactor) {
      thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
  }

  CGImageRef imageRef = [image CGImage];
  CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
  CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
  size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);

  CGContextRef bitmap;
  if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationDown) {
    bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, bitsPerComponent, targetWidth*bitsPerComponent, colorSpaceInfo, bitmapInfo);
  } else {
    bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, bitsPerComponent, targetWidth*bitsPerComponent, colorSpaceInfo, bitmapInfo);
  }

  // error in creating context
  if (!bitmap)
  {
    printf("Error in creating context");
    return NULL;
  }

  // In the right or left cases, we need to switch scaledWidth and scaledHeight,
  // and also the thumbnail point
  if (image.imageOrientation == UIImageOrientationLeft)
  {
    thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
    CGFloat oldScaledWidth = scaledWidth;
    scaledWidth = scaledHeight;
    scaledHeight = oldScaledWidth;

    CGContextRotateCTM( bitmap, 90 * (3.1415927 / 180.0) );
    CGContextTranslateCTM(bitmap, 0, -targetHeight);
  }
  else if (image.imageOrientation == UIImageOrientationRight)
  {
    thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
    CGFloat oldScaledWidth = scaledWidth;
    scaledWidth = scaledHeight;
    scaledHeight = oldScaledWidth;

    CGContextRotateCTM( bitmap, -90 * (3.1415927 / 180.0) );
    CGContextTranslateCTM(bitmap, -targetWidth, 0);
  }
  else if (image.imageOrientation == UIImageOrientationUp)
  {
    // NOTHING
  }
  else if (image.imageOrientation == UIImageOrientationDown)
  {
    CGContextTranslateCTM(bitmap, targetWidth, targetHeight);
    CGContextRotateCTM( bitmap, -180 * (3.1415927 / 180.0) );
  }

  CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
  CGImageRef ref = CGBitmapContextCreateImage(bitmap);
  UIImage* newImage = [UIImage imageWithCGImage: ref];

  CGContextRelease(bitmap);
  CGImageRelease(ref);

  return newImage;
}
