

#import "UIImage+RRAPI.h"

@implementation UIImage (RRAPI)

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f,size.width,size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByScalingToWidth:(CGFloat)width {
    if (self.size.width <= width) {
        UIGraphicsBeginImageContext(self.size);
        [self drawInRect:CGRectMake(0.0, 0.0, self.size.width, self.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        //return self;
    }
    else {
        CGFloat height = width * self.size.height / self.size.width;
        CGSize newTargetsize = CGSizeMake(width, height);
        UIGraphicsBeginImageContext(newTargetsize);
        [self drawInRect:CGRectMake(0.0, 0.0, newTargetsize.width, newTargetsize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
    UIGraphicsBeginImageContext(targetSize);
    [self drawInRect:CGRectMake(0.0, 0.0, targetSize.width, targetSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)imageByScalingInSize:(CGSize)targetSize
{
    if(self.size.width <= targetSize.width && self.size.height <= targetSize.height)
    {
        UIGraphicsBeginImageContext(self.size);
        //UIGraphicsBeginImageContextWithOptions(newTargetsize, NO, 0.0);
        [self drawInRect:CGRectMake(0.0, 0.0, self.size.width, self.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    else
    {
        CGSize newTargetsize = self.size;
        CGFloat originalRatio = self.size.width / self.size.height;
        CGFloat inSizeRatio = targetSize.width / targetSize.height;
        if(originalRatio > inSizeRatio)
        {
            newTargetsize.width = targetSize.width;
            newTargetsize.height = (self.size.height / self.size.width) * newTargetsize.width;
        }
        else
        {
            newTargetsize.height = targetSize.height;
            newTargetsize.width = (self.size.width / self.size.height) * newTargetsize.height;
        }
        
        UIGraphicsBeginImageContext(newTargetsize);
        //UIGraphicsBeginImageContextWithOptions(newTargetsize, NO, 0.0);
        [self drawInRect:CGRectMake(0.0, 0.0, newTargetsize.width, newTargetsize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

//- (UIImage *)imageByThumbnailImageSize:(CGSize)size
//{
//    UIImage *targetImage = nil;
//    if(self.size.width/self.size.height > size.width/size.height)
//    {
//        CGFloat height = size.height * 2.0;
//        if(![UIDevice deviceIsRetina])
//        {
//            height = size.height;
//        }
//        CGFloat width = self.size.width / (self.size.height / height);
//        UIImage *processedImage = [self imageByScalingToSize:CGSizeMake(width, height)];
//        width = size.width * 2.0;
//        if(![UIDevice deviceIsRetina])
//        {
//            width = size.width;
//        }
//        CGRect cropFrame = CGRectMake((processedImage.size.width-width)/2.0, 0.0, width, height);
//        CGImageRef cropImageRef = CGImageCreateWithImageInRect(processedImage.CGImage, cropFrame);
//        targetImage = [UIImage imageWithCGImage:cropImageRef];
//        CGImageRelease(cropImageRef);
//    }
//    else
//    {
//        CGFloat width = size.width * 2.0;
//        if(![UIDevice deviceIsRetina])
//        {
//            width = size.width;
//        }
//        CGFloat height = self.size.height / (self.size.width / width);
//        UIImage *processedImage = [self imageByScalingToSize:CGSizeMake(width, height)];
//        height = size.height * 2.0;
//        if(![UIDevice deviceIsRetina])
//        {
//            height = size.height;
//        }
//        CGRect cropFrame = CGRectMake(0.0, (processedImage.size.height-height)/2.0, width, height);
//        CGImageRef cropImageRef = CGImageCreateWithImageInRect(processedImage.CGImage, cropFrame);
//        targetImage = [UIImage imageWithCGImage:cropImageRef];
//        CGImageRelease(cropImageRef);
//    }
//    
//    return targetImage;
//}

- (UIImage *)imageByCompressionQuality:(CGFloat)compressionQuality
{
    NSData *imageData = UIImageJPEGRepresentation(self, compressionQuality);
    return [UIImage imageWithData:imageData];
}

- (BOOL)writeToFile:(NSString *)path forRepresentation:(CGFloat)representation
{
    NSData *imageData = UIImageJPEGRepresentation(self, representation);
    BOOL result = [imageData writeToFile:path atomically:YES];
    if (!result) {
        NSLog(@"UIImage: writeToFile fail");
    }
    return result;
}

- (UIImage *)imageWithCropRect:(CGRect)rect
{
    CGImageRef cropImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *cropImage = [UIImage imageWithCGImage:cropImageRef];
    CGImageRelease(cropImageRef);
    
    return cropImage;
}

- (UIImage *)scaleProportionalToSize: (CGSize)size
{
    float widthRatio = size.width/self.size.width;
    float heightRatio = size.height/self.size.height;
    
    if(widthRatio > heightRatio)
    {
        size=CGSizeMake(self.size.width*heightRatio,self.size.height*heightRatio);
    } else {
        size=CGSizeMake(self.size.width*widthRatio,self.size.height*widthRatio);
    }
    
    return [self imageByScalingToSize:size];
}

- (UIImage *)fixOrientationImage {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)resizedImage:(NSString *)name left:(CGFloat)left top:(CGFloat)top
{
    UIImage *image = [self imageNamed:name];
    
    return [image stretchableImageWithLeftCapWidth:image.size.width * left topCapHeight:image.size.height * top];
}


@end
