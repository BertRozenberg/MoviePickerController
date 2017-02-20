//
//  MainViewController.m
//  MoviePickerDemo
//
//  Created by Bert Rozenberg on 18-02-17.
//

#import "MainViewController.h"
#import "MoviePickerController.h"
#import <AVKit/AVKit.h>

@interface MainViewController ()
@property (strong, nonatomic) MoviePickerController *moviePickerController;
@property (nonatomic, strong) AVPlayerViewController *avPlayerViewController;
@property (nonatomic, strong) AVPlayer *avPlayer;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        }];
    }
}

- (IBAction)selectMovie:(UIButton *)sender {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
        if ([assetsFetchResult count] == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Movies Available" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOK  = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:actionOK];
            alertController.popoverPresentationController.sourceView = self.view;
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            __weak typeof(self) weakSelf = self;
            if (!self.moviePickerController) {
                self.moviePickerController = [[MoviePickerController alloc] init];
            }

                //The movieSelectedBlock returns the MovieRecord of the selected movie.
                //Check out MovieRecord.h for the properties of such a MovieRecord
            self.moviePickerController.movieSelectedBlock = ^(MovieRecord *movieRecord) {
                if (movieRecord) {
                    [weakSelf playMovie:movieRecord];
                }
            };

                //The movieCancelBlock is called when the user selected cancel in the moviePickerController.
                //Most of the time this block is pretty useless.
            self.moviePickerController.movieCancelBlock = ^() {
                
            };
            
                //If you allready have an assetsFetchResult, hand it over to the moviePickerController
                //Otherwise moviePickerController will do the fetch for you.
            self.moviePickerController.assetsFetchResult = assetsFetchResult;
            
                //Specify which frame moviePickerController should display
                //Default is the frame at 5 seconds into the movie
            self.moviePickerController.firstFrame = 10;
            
                //Spcify if the play-button (which offers the option to preview the movies) is visible.
                //Default is YES
            self.moviePickerController.show_playbutton = YES;
            
                //Specify the size of the square playbutton.
                //Default is 60.0
            self.moviePickerController.button_Size = 60.0;
            
                //Specify the transparency of the playbutton
                //Default = 0.3
            self.moviePickerController.button_Alpha = 0.3;
            
                //Spcify if the duration of the movie is printed in the right bottom corner
                //Default is YES
            self.moviePickerController.show_time = YES;
            
                //Specify the height of the table cells.
                //Default is 200.0
            self.moviePickerController.cell_height = 200.0;
            
            [self.moviePickerController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionTop  animated:YES];
            UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:self.moviePickerController];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                navC.modalPresentationStyle= UIModalPresentationPopover;
                navC.preferredContentSize = CGSizeMake(300.0, 600.0);
                UIPopoverPresentationController *popController = [navC popoverPresentationController];
                popController.backgroundColor = [UIColor grayColor];
                popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                popController.sourceView = sender;
                popController.sourceRect = sender.bounds;
            }
            [self presentViewController:navC animated:YES completion:nil];
        }
    }
}

-(void)playMovie:(MovieRecord *) mRec {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:mRec.avAsset];
    self.avPlayerViewController = [[AVPlayerViewController alloc] init];
    if (!self.avPlayer) {
        self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    } else {
        [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
    }
    self.avPlayer.allowsExternalPlayback = NO;
    if (!self.avPlayerViewController ) {
        self.avPlayerViewController  = [[AVPlayerViewController alloc] init];
        self.avPlayerViewController.view.frame = self.view.frame;
        [self.view addSubview: self.avPlayerViewController.view];
    }
    [self.avPlayer seekToTime:CMTimeMake(0, 1)];
    self.avPlayerViewController.allowsPictureInPicturePlayback = NO;
    self.avPlayerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    self.avPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.avPlayerViewController.player = self.avPlayer;
    [self.avPlayerViewController.player play];
    [self presentViewController:self.avPlayerViewController animated:YES completion:nil];
}


@end
