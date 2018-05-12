//
//  SettingsViewController.m
//  SampleGame2
//
//  Created by Robert Prast on 4/20/18.
//  Copyright © 2018 Robert Prast. All rights reserved.
//

#import "SettingsViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface SettingsViewController ()

@end


@implementation SettingsViewController

Boolean soundOn = true;
Boolean musicOn = true;


//On view appeared, check the above boolean values and sets the segements to its repsective value
-(void) viewWillAppear:(BOOL)animated {
    if (soundOn) [_SoundSegement setSelectedSegmentIndex:0];
    else [_SoundSegement setSelectedSegmentIndex:1];
    if (musicOn) [_MusicSegment setSelectedSegmentIndex:0];
    else [_MusicSegment setSelectedSegmentIndex:1];
}

//Sound Segement Controller
- (IBAction)SoundToggle:(id)sender {
    //Check if sound was toggled on or off
    if (_SoundSegement.selectedSegmentIndex==0) {
        _SoundSegement.selectedSegmentIndex = 0;
        soundOn = true;
    } else if(_SoundSegement.selectedSegmentIndex==1) {
        _SoundSegement.selectedSegmentIndex = 1;
        soundOn = false;
    }
}

//Music Segement Controller
- (IBAction)MusicToggle:(id)sender {
    //Check if music was toggled on or off
    if (_MusicSegment.selectedSegmentIndex==0) {
        musicOn = true;
    } else if(_MusicSegment.selectedSegmentIndex==1) {
        musicOn = false;
    }
}

//Returns if sound should be on
+(Boolean) isSoundOn {
    return soundOn;
}
//Returns if music should be on
+(Boolean) isMusicOn {
    return musicOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
