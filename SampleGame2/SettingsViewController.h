//
//  SettingsViewController.h
//  SampleGame2
//
//  Created by Robert Prast on 4/20/18.
//  Copyright © 2018 Robert Prast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
@interface SettingsViewController : UIViewController

//Properties for Two segement buttons
@property (weak, nonatomic) IBOutlet UISegmentedControl *SoundSegement;
@property (weak, nonatomic) IBOutlet UISegmentedControl *MusicSegment;

//Functions to determine if music and sound should be on
+(Boolean) isSoundOn;
+(Boolean) isMusicOn;

@end
