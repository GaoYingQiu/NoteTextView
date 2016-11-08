

#import <UIKit/UIKit.h>

@interface UIImage (RRAPI)

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)imageByScalingToWidth:(CGFloat)width;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

- (UIImage *)imageByScalingInSize:(CGSize)targetSize;
//- (UIImage *)imageByThumbnailImageSize:(CGSize)size;
- (UIImage *)imageByCompressionQuality:(CGFloat)compressionQuality;
- (BOOL)writeToFile:(NSString *)path forRepresentation:(CGFloat)representation;
- (UIImage *)imageWithCropRect:(CGRect)rect;
- (UIImage *)scaleProportionalToSize: (CGSize)size;

- (UIImage *)fixOrientationImage;
+ (UIImage *)resizedImage:(NSString *)name left:(CGFloat)left top:(CGFloat)top;

@end
