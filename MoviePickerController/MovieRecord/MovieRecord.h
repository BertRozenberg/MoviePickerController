//
//  MovieRecord.h
//
//  Created by Bert Rozenberg on 08-01-17.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface MovieRecord : NSObject
{
    UIImage *image;
    PHAsset *phAsset;
    AVURLAsset *avAsset;
    NSNumber *fileSize;
}

@property (strong) UIImage *image;
@property (strong) PHAsset *phAsset;
@property (strong) AVURLAsset *avAsset;
@property (strong) NSNumber *fileSize;

@end
