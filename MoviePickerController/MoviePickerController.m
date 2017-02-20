//
//  MoviePickerController.m
//  MoviePickerDemo
//
//  Created by Bert Rozenberg on 18-02-17.
//

#import "MoviePickerController.h"
#import <AVKit/AVKit.h>
#import "MovieViewCell.h"
#import "AVAsset+VideoOrientation.h"
#import "UIImage+Extra.h"

@interface MoviePickerController ()
@property (nonatomic, strong) MovieRecord *selectedMovieImage;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@end

@implementation MoviePickerController

-(instancetype)init {
    self = [super init];
    if (self != nil) {
        self.assetsFetchResult = nil;
        self.selectedMovieImage = nil;
        self.firstFrame = 5;
        self.show_time = YES;
        self.show_playbutton = YES;
        self.cell_height = 200.0;
        self.button_Size = 60.0;
        self.button_Alpha = 0.3;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.assetsFetchResult == nil) {
        self.assetsFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
    }
    self.images = [[NSMutableArray alloc] init];
    UIImage *placeHolder = [[[UIImage imageNamed:@"Placeholder"] grayscale] imageByApplyingAlpha:0.3];
    [self.assetsFetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MovieRecord *MImage = [[MovieRecord alloc]init];
        MImage.image = placeHolder;
        MImage.phAsset = obj;
        [self.images addObject:MImage];
    }];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(doneSelection)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelection)];
    [self retrieveImages];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.avPlayer != nil) {
        [self.avPlayer pause];
        [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    }
}

-(void)retrieveImages {
    for (__block PHAsset *thisAsset in self.assetsFetchResult) {
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.version = PHVideoRequestOptionsVersionCurrent;
        videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
        [[PHImageManager defaultManager] requestAVAssetForVideo:thisAsset options:videoRequestOptions resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            __block AVAsset *savedAsset = asset;
            AVURLAsset *assetURL = [AVURLAsset assetWithURL:((AVURLAsset *)asset).URL];
            __block NSNumber *size;
            [assetURL.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            
            NSString *str= [NSString stringWithFormat:@"%@",assetURL.URL];
            NSURL *url = [NSURL URLWithString:str];
            __block AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            CMTime time = CMTimeMake(self.firstFrame, 1);
            NSArray *times = [NSArray arrayWithObject:[NSValue valueWithCMTime:time]];
            [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
                if (result != AVAssetImageGeneratorSucceeded) {
                    NSLog(@"couldn't generate thumbnail, error:%@", error);
                } else {
                    UIImage *NewImage  = [[UIImage alloc] initWithCGImage:image];
                    
                    NSInteger degrees = [savedAsset videoOrientationDegrees];
                    if (degrees != 0) {
                        NewImage = [NewImage imageRotatedByDegrees:-degrees];
                    }
                    if (self.show_time) {
                        NewImage = [self drawTime:NewImage TimeStr:[self TimeFromCMTime:avAsset.duration]];
                    }
                    for (MovieRecord *image in self.images) {
                        if ([thisAsset.creationDate isEqualToDate:image.phAsset.creationDate]) {
                            image.image = NewImage;
                            image.avAsset = avAsset;
                            image.fileSize = size;
                            [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
                            break;
                        }
                    }
                }
            }];
        }];
    }
}

-(void)reloadTable {
    [self.tableView reloadData];
}

- (IBAction)cancelSelection {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.movieCancelBlock != nil)
        {
            self.movieCancelBlock();
        }
    }];
}

- (IBAction)doneSelection {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.movieSelectedBlock != nil)
        {
            self.movieSelectedBlock(self.selectedMovieImage);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.assetsFetchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableCellIdentifier = @"MoviePickerCell";
    MovieViewCell *cell = [tableView dequeueReusableCellWithIdentifier: TableCellIdentifier];
    if (cell == nil) {
        cell = [[MovieViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableCellIdentifier];
        CGRect rect = CGRectMake(5, 5, self.tableView.frame.size.width - 10, self.cell_height - 10);
        cell.imageView = [[UIImageView alloc] initWithFrame:rect];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell addSubview:cell.imageView];
        if (self.show_playbutton) {
            cell.playButton = [[UIButton alloc] initWithFrame:CGRectMake((rect.size.width - self.button_Size)/2, (rect.size.height - self.button_Size)/2, self.button_Size, self.button_Size)];
            UIImage *playImage = [[UIImage imageNamed:@"Play"] imageByApplyingAlpha:self.button_Alpha];
            [cell.playButton setBackgroundImage:playImage forState:UIControlStateNormal];
            [cell.playButton addTarget:nil action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:cell.playButton];
        }
    }
    NSUInteger row = [indexPath row];
    MovieRecord *img = [self.images objectAtIndex:row];
    cell.imageView.image = img.image;
    cell.playButton.tag = row;
    cell.playButton.hidden = (img.avAsset == nil);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cell_height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    NSInteger row = [indexPath row];
    MovieRecord *image = [self.images objectAtIndex:row];
    self.selectedMovieImage = image;
}

- (UIImage *)drawTime: (UIImage *) Image TimeStr:(NSString *) timeStr {
    CGFloat minSize = MIN(Image.size.height,Image.size.width);
    UIFont *thisFont = [UIFont systemFontOfSize:minSize/7];
    NSDictionary *attributes = @{
                                 NSFontAttributeName:thisFont,
                                 NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSStrokeColorAttributeName:[UIColor whiteColor],
                                 NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-2.0]
                                 };
    NSAttributedString *str     = [[NSAttributedString alloc] initWithString:timeStr attributes:attributes];
    CGSize strSize  = [str size];
    CGPoint location = CGPointMake(Image.size.width - (strSize.width + 10), Image.size.height - (strSize.height + 3));
    UIGraphicsBeginImageContext(Image.size);
    [Image drawInRect:CGRectMake(0,0,Image.size.width,Image.size.height)];
    [[UIColor whiteColor] set];
    [timeStr drawAtPoint:location withAttributes:attributes];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)playMovie:(UIButton *)sender {
    NSInteger row = sender.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    MovieRecord *image = [self.images objectAtIndex:row];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:image.avAsset];
    
    if (!self.avPlayer) {
        self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    } else {
        [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
    }
    self.avPlayer.allowsExternalPlayback = NO;
    if (!self.playerViewController) {
        self.playerViewController = [[AVPlayerViewController alloc] init];
        self.playerViewController.view.frame = self.view.frame;
        [self.view addSubview: self.playerViewController.view];
    }
    [self.avPlayer seekToTime:CMTimeMake(0, 1)];
    self.playerViewController.allowsPictureInPicturePlayback = NO;
    self.playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.playerViewController.player = self.avPlayer;
    [self.playerViewController.player play];
    [self.navigationController pushViewController:self.playerViewController animated:NO];
}

-(NSString *)TimeFromCMTime:(CMTime)cmtime {
    float videoDurationSeconds = CMTimeGetSeconds(cmtime);
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:videoDurationSeconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString* result = [dateFormatter stringFromDate:date];
    return result;
}


@end
