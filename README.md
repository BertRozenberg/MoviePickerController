# MoviePickerController
Provides a powerful MoviePicker which is very easy to use 

### Example
``` objective-c
           MoviePickerController  *moviePickerController = [[MoviePickerController alloc] init];
           moviePickerController.movieSelectedBlock = ^(MovieRecord *movieRecord) {
                if (movieRecord) {
                    // use the Selected Movie
                }
           };
           
		//Optional
           moviePickerController.movieCancelBlock = ^() {
            };
           moviePickerController.assetsFetchResult = assetsFetchResult;
           moviePickerController.firstFrame = 10;
           moviePickerController.show_playbutton = YES;
           moviePickerController.button_Size = 60.0;
           moviePickerController.button_Alpha = 0.3;
           moviePickerController.show_time = YES;
           moviePickerController.cell_height = 200.0;
           
           [self presentViewController:moviePickerController animated:YES completion:nil];
```

## Motivation
I needed a MoviePicker and didn't like the one iOS supplies. So, I wrote my own.
It turned out great, so I decided to share it with others. Feel free to use it.

## Installation
To add AST to your MoviePickerController:
-	Drag and drop the MoviePickerController directory to your project.
-	Add the frameworks AVFoundation, AVKit and Photos to your project.
-	Add the key NSPhotoLibraryUsageDescription to your info.plist

## Documentation
Using MoviePickerController is pretty easy.
-	Add #import "MoviePickerController.h" to the view controller from which you want 
	to call the MoviePickerController.
-	Ask the user for permission as soon as possible. From your AppDelegate or from your Main ViewController.
	For example:
``` objective-c
	- (void)viewDidLoad {
    		[super viewDidLoad];
		if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
		        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        		}];
    		}
	} 
```

When you want the user to select a movie, just initialize a MoviePickerController:
``` objective-c
           MoviePickerController  *moviePickerController = [[MoviePickerController alloc] init];
```

and add the movieSelectedBlock:

``` objective-c
           moviePickerController.movieSelectedBlock = ^(MovieRecord *movieRecord) {
                if (movieRecord) {
                    // use the Selected Movie
                }
           };
```

and present the controller:
``` objective-c
         [self presentViewController:moviePickerController animated:YES completion:nil];
```

That's all. If the user selects a movie the movieSelectedBlock will return the selected movie. 
Along the way moviePickerController gathers a lot of information about the selected movie. 
To give you access to that information moviePickerController returns a MovieRecord class. 
Check out MovieRecord.h for its properties.

## Optional Properties
After initializing the moviePickerController and before presenting is, you can modify its behavior a little. 
It's all optional.
-	movieCancelBlock</br>
	This block is called when the user selects Cancel from the moviePickerController. 
	Might be useful on the iPhone and is useless on the iPad (popover).
	
-	assetsFetchResult</br>
	If you allready have an assetsFetchResult, you cab hand it over to the moviePickerController. 
	Otherwise moviePickerController will do the fetch for you.
	
-	firstFrame</br>
	Often the first frame of a movie is just black which makes it hard to make a choice.
	For that reason moviePickerController will, by default, not use the first frame.
	It just picks a frame from a few seconds into the movie. The default is 5 seconds.

-	show_playbutton</br>
	When showing the available movies, moviePickerController adds a play button to each movie picture.
	By tapping the play button, the user can preview his choice.
	If you don't want to offer this option, specify NO to this option.
	Default is YES.

-	button_Size</br>
	The size of the above play button.
    Default is 60.0
    
-	button_Alpha</br>
	The transparency of the above play button.
    Default is 0.3

-	show_time</br>
	By default moviePickerController prints the duration of the movie to the bottom right of the picture.
	If you don't want to offer this option, specify NO to this option.
	Default is YES.

-	cell_height</br>
	Just to be complete, you can change the height of the table cells.
	Default is 200.0

## Demo Project
We've included a demo project which shows how to use moviePickerController 
both on the iPhone and as a popover on the iPad.

<img src="https://github.com/BertRozenberg/MoviePickerController/blob/master/DemoGifs/MoviePickerDemo1.gif" alt="moviePickerController Sample"/>

<img src="https://github.com/BertRozenberg/MoviePickerController/blob/master/DemoGifs/MoviePickerDemo2.gif" alt="moviePickerController Samble"/>

