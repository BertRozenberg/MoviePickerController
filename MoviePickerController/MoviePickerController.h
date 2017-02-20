//
//  MoviePickerController.h
//  MoviePickerDemo
//
//  Created by Bert Rozenberg on 18-02-17.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "MovieRecord.h"

@class MoviePickerController;

typedef void (^MovieSelectedBlock)(MovieRecord *movieRecord);
typedef void (^MovieCancelBlock)();

@interface MoviePickerController : UITableViewController

@property (nonatomic, copy) MovieSelectedBlock movieSelectedBlock;
@property (nonatomic, copy) MovieCancelBlock movieCancelBlock;

@property (nonatomic, assign) NSInteger firstFrame;
@property (nonatomic, assign) BOOL show_playbutton;
@property (nonatomic, assign) BOOL show_time;
@property (nonatomic, assign) CGFloat cell_height;
@property (nonatomic, assign) CGFloat button_Size;
@property (nonatomic, assign) CGFloat button_Alpha;

@property (nonatomic, strong) PHFetchResult *assetsFetchResult;

@end
