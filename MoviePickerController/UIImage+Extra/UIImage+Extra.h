//
//  UIImage+Extra.h
//  MoviePicker
//
//  Created by Bert Rozenberg on 18-02-17.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extra)

- (UIImage *)grayscale;
- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha ;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
