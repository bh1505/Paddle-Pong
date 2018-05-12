//
//  GameViewController.h
//  SampleGame2
//
//  Created by Robert Prast on 4/20/18.
//  Copyright © 2018 Robert Prast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>



@interface GameViewController : UIViewController <SCNPhysicsContactDelegate> {
    AVAudioPlayer *audioPlayer;
}
//For Accerlemoter Data
@property (strong, nonatomic) CMMotionManager *motionManager;
@property float accX;
@property float accY;
@property float accZ;

@property (nonatomic, retain) UILabel *scoreLabel; /*label for the current score*/

//labels to appear when Game Over
@property (nonatomic, retain) UILabel *endLabel;
@property (nonatomic, retain) UILabel *restartLabel;
@property (nonatomic, retain) UILabel *gameoverLabel;

//array to hold images for each powerUp/powerDown
@property (strong, nonatomic) NSArray *powerUps;
-(void) endGame;
@end
