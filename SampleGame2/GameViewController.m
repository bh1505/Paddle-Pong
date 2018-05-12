//
//  GameViewController.m
//  SampleGame2
//
//  Created by Robert Prast on 4/20/18.
//  Copyright © 2018 Robert Prast. All rights reserved.
//

#import "GameViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SettingsViewController.h"

@implementation GameViewController {
    //sound IDs
    SystemSoundID pongSoundID;
    SystemSoundID powerUpSoundID;
    SystemSoundID spkieSoundID;
}
//Global Variables

//Scene and Camera declariation
SCNScene *scene;
SCNNode *cameraNode;
//declare Ball node
SCNGeometry *ball;
SCNNode *ballNode;
//declare Paddle node
SCNScene *paddle;
SCNNode *paddleNode;
//declare lighting node
SCNNode *lightNode;
SCNView *scnView;
//declare Handle node
SCNBox *handle;
SCNNode *handleNode;

float x=0;
@synthesize scoreLabel;
@synthesize endLabel;
@synthesize restartLabel;
@synthesize gameoverLabel;
@synthesize powerUps;
int count = 0; /*current score*/
Boolean mulitplier = false; /*is 2x multiplier activated*/

int writeOnce=1; //Variable to ensure you only write the current score once to highscore list



- (void)viewDidLoad
{
    [super viewDidLoad];
    x=x+1;
    //load images of powerUps/powerDowns
    self.powerUps = @[[UIImage imageNamed:@"two"],
                      [UIImage imageNamed:@"fast"],
                      [UIImage imageNamed:@"slow"],
                      [UIImage imageNamed:@"spike"]];
    
    
    //Setup Core Motion for Accerlemoter
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .05;
    self.motionManager.gyroUpdateInterval = 1/60;
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
     
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        
                                        [self outputRotationData:gyroData.rotationRate];
                                        
                                    }];
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error)
     {
         [self outputAccelertionData:accelerometerData.acceleration];
         if(error){
             NSLog(@"%@", error);
         }
     }
     ];
    
    //Init score label
    self.scoreLabel = [ [UILabel alloc ] initWithFrame:CGRectMake((self.view.bounds.size.width / 2 - 25), 15.0, 50.0, 43.0) ];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel.textColor = [UIColor whiteColor];
    self.scoreLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
    [self.view addSubview:self.scoreLabel];
    self.scoreLabel.text = [NSString stringWithFormat: @"%d", count];
    
    
    // create a new scene
    scene = [SCNScene scene];
    scene.physicsWorld.contactDelegate = self;
    scene.background.contents = [UIImage imageNamed:@"bg"];
    
    // create and add a camera to the scene
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.camera.zFar = 200;
    cameraNode.camera.zNear = 3;
    cameraNode.position = SCNVector3Make(0, 30, 0);
    cameraNode.eulerAngles = SCNVector3Make(-M_PI/2, 0, 0);
    
    // create and add a light to the scene
    lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 100, 0);
    lightNode.eulerAngles=SCNVector3Make(0,0, -M_PI/2);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor grayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    //Init ball with its properties
    ball = [SCNSphere sphereWithRadius:1];
    ball.materials.firstObject.diffuse.contents = [UIColor whiteColor];
    ballNode = [SCNNode nodeWithGeometry:ball];
    ballNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
    ballNode.physicsBody.restitution = 1;
    ballNode.physicsBody.affectedByGravity = YES;
    ballNode.physicsBody.damping = 0.5;
    ballNode.physicsBody.friction = 0;
    ballNode.physicsBody.mass=10.0;
    ballNode.position = SCNVector3Make(0.0, 35, 0.0);
    //detect collisions
    ballNode.physicsBody.contactTestBitMask = ballNode.physicsBody.collisionBitMask;
    ballNode.castsShadow=1;
    [scene.rootNode addChildNode:ballNode];
    
    //Init paddle with its properties
    paddle = [SCNScene sceneNamed:@"art.scnassets/Ping-pong_racket.scn"];
    paddleNode = [paddle.rootNode childNodeWithName:@"obj_0" recursively:false];
    paddleNode.eulerAngles = SCNVector3Make(-M_PI/2, 0, -M_PI/2);
    paddleNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:nil];
    paddleNode.physicsBody.restitution = 2.0;
    paddleNode.physicsBody.friction = 0;
    paddleNode.position = SCNVector3Make(-2, 0, 15);
    [paddleNode runAction:[SCNAction rotateByX:.05 y:0 z:M_PI/2 duration:0.0]];
    [scene.rootNode addChildNode:paddleNode];
    [paddleNode runAction:[SCNAction fadeInWithDuration:1.0]];
    
    //Attach a handle to the paddle
    handle = [SCNBox boxWithWidth:2 height:5 length:.5 chamferRadius:1.2];
    handle.materials.firstObject.diffuse.contents = [UIColor darkGrayColor];
    handleNode =  [SCNNode nodeWithGeometry:handle];
    handleNode.position = SCNVector3Make(4, 20, 0.0);
    [paddleNode addChildNode:handleNode];
    [handleNode runAction:[SCNAction fadeInWithDuration:1.0]];
    
    //Init end label
    self.endLabel = [ [UILabel alloc ] initWithFrame:CGRectMake((self.view.bounds.size.width / 2)-180, (self.view.bounds.size.height/2)-30, 150 ,100) ];
    self.endLabel.textAlignment = NSTextAlignmentCenter;
    self.endLabel.textColor = [UIColor whiteColor];
    self.endLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(24.0)];
    [self.view addSubview:self.endLabel];
    self.endLabel.text = [NSString stringWithFormat: @"End"];
    self.endLabel.hidden=TRUE;
    self.endLabel.tag=8;
    self.endLabel.userInteractionEnabled = NO;
    
    //Init restart Label
    self.restartLabel = [ [UILabel alloc ] initWithFrame:CGRectMake((self.view.bounds.size.width / 2)+30, (self.view.bounds.size.height/2)-30, 150 ,100) ];
    self.restartLabel.textAlignment = NSTextAlignmentCenter;
    self.restartLabel.textColor = [UIColor whiteColor];
    self.restartLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(22.0)];
    [self.view addSubview:self.restartLabel];
    self.restartLabel.text = [NSString stringWithFormat: @"Restart"];
    self.restartLabel.hidden=TRUE;
    self.restartLabel.tag=9;
    self.restartLabel.userInteractionEnabled = NO;
    
    //init GAMEOVER LABEL
    self.gameoverLabel = [ [UILabel alloc ] initWithFrame:CGRectMake((self.view.bounds.size.width / 2)-100, (self.view.bounds.size.height/2)-120, 200 ,100) ];
    self.gameoverLabel.textAlignment = NSTextAlignmentCenter;
    self.gameoverLabel.textColor = [UIColor whiteColor];
    self.gameoverLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    [self.view addSubview:self.gameoverLabel];
    self.gameoverLabel.text = [NSString stringWithFormat: @"GAME OVER"];
    self.gameoverLabel.hidden=TRUE;
    self.gameoverLabel.userInteractionEnabled = NO;
    
    //SCENE
    // retrieve the SCNView
    scnView = (SCNView *)self.view;

    // set the scene to the view
    scnView.scene = scene;
    
    // configure the view
    scnView.backgroundColor = [UIColor orangeColor];
    count=0;
    
    //Play background music if setting is on
    if ([SettingsViewController isMusicOn]){
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"techno" ofType:@"wav"]];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        audioPlayer.numberOfLoops = -1;
        audioPlayer.volume = 0.5;
        audioPlayer.enableRate = true;
        [audioPlayer play];
    }
}


-(void) endGame{
    {
        //Pause game, and then check if the current score should be inserted into the highscores array
        scene.paused=true;
        if ([SettingsViewController isMusicOn]) [audioPlayer stop];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *sortedValues = [NSMutableArray array];
        for(id a in [defaults arrayForKey:[NSString stringWithFormat:@"values"]]){
            [sortedValues addObject:a];
        }
        //NSLog(@"%@",sortedValues);
        //NSLog(@"%lu", (unsigned long)sortedValues.count);
        [sortedValues addObject:[NSNumber numberWithInteger:count]];
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
        sortedValues = (NSMutableArray*)[sortedValues sortedArrayUsingDescriptors:@[sd]];
        NSArray* slicedArray = [sortedValues subarrayWithRange:NSMakeRange(0, 10)];
        //Check if writeOnce is true, and then write to array
        if(writeOnce==1){
            //NSLog(@"WRITING VLAUES");
            [defaults setObject:slicedArray forKey:@"values"];
            writeOnce=0;
            //NSLog(@"%@",sortedValues);
        }
        [defaults synchronize];

        //Bring forward the end game and restart game label, but must do so in the main thread
        //We use the labels as buttons, so we must enable user interaction to detect touches
        dispatch_async(dispatch_get_main_queue(), ^{
            self.endLabel.hidden=FALSE;
            self.endLabel.userInteractionEnabled=TRUE;
            self.restartLabel.hidden=FALSE;
            self.restartLabel.userInteractionEnabled=TRUE;
            self.gameoverLabel.hidden=FALSE;
        });
        }
    
}

//Function that detects contact between different nodes in the Scene
-(void) physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(nonnull SCNPhysicsContact *)contact {
    SCNPhysicsBody *firstBody = contact.nodeA.physicsBody;
    SCNPhysicsBody *secondBody = contact.nodeB.physicsBody;
    //if ball bounces on paddle
    if ( firstBody == paddleNode.physicsBody || secondBody == paddleNode.physicsBody){
        //if 2x multiplier is activated
        if (mulitplier) count += 2;
        else count ++;
        //play sound effect
        if([SettingsViewController isSoundOn])[self playPongSound];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scoreLabel.text = [NSString stringWithFormat: @"%d", count];
        });
        //every three bounces there is a 50% chance a powerUp/PowerDown is generated
        if (count % 3 == 0) {
            int r = arc4random_uniform(100);
            //50/50 chance that power up is generated
            if (r > 49) {
                int ranX;
                int ranY;
                //generate a random position on the screen
                if (r > 74) {
                    ranX = arc4random_uniform(7);
                    ranY = arc4random_uniform(12);
                } else {
                    ranX = -1 * arc4random_uniform(7);
                    ranY = -1 * arc4random_uniform(12);
                }
                //make power up appear
                int randImg = arc4random_uniform(4);
                UIImage *obj = [self.powerUps objectAtIndex:randImg];
                SCNNode *powerUp = [SCNNode nodeWithGeometry: [SCNPlane planeWithWidth:2 height:4] ];
                //name the powerUP node
                if (randImg == 0) powerUp.name = @"two";
                else if (randImg == 1) powerUp.name = @"fast";
                else if (randImg == 2) powerUp.name = @"slow";
                else if (randImg == 3) powerUp.name = @"spike";
                powerUp.geometry.materials.firstObject.diffuse.contents = obj;
                powerUp.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:nil];
                powerUp.eulerAngles = SCNVector3Make(-M_PI/2, 0, 0);
                powerUp.position = SCNVector3Make(ranX, 9, ranY);
                //if not a spike, ball can pass through
                if (![powerUp.name isEqualToString:@"spike"]) powerUp.physicsBody.collisionBitMask = 0;
                //make the powerUps pulsate
                NSArray *scaleSeq = @[ [SCNAction scaleTo:1.2 duration:0.7], [SCNAction scaleTo:0.9 duration:0.7] ];
                [powerUp runAction:[SCNAction repeatActionForever:[SCNAction sequence:scaleSeq]]];
                [scene.rootNode addChildNode:powerUp];
                //make it disappear after 12 seconds
                double delayInSeconds = 12.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [powerUp removeFromParentNode];
                });
            }
            
        }
        //a power up or obstacle has been hit by the ball
    } else {
        Boolean spike = false;
        //2X MULTIPLIER
        if ( ([contact.nodeA.name isEqualToString:@"two"] && contact.nodeB.physicsBody == ballNode.physicsBody)
            || ([contact.nodeB.name isEqualToString:@"two"] && contact.nodeA.physicsBody == ballNode.physicsBody) ){
            if([SettingsViewController isSoundOn])[self playPowerUpSound];
            //if multiplier has been activated, count goes up by two for each bounce
            mulitplier = true;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scoreLabel.textColor = [UIColor greenColor];
            });
            //power up lasts for 12 seconds
            double delayInSeconds = 12.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                mulitplier = false;
                self.scoreLabel.textColor = [UIColor whiteColor];
            });
            //SPIKE
        } else if ( ([contact.nodeA.name isEqualToString:@"spike"] && contact.nodeB.physicsBody == ballNode.physicsBody) || ([contact.nodeB.name isEqualToString:@"spike"] && contact.nodeA.physicsBody == ballNode.physicsBody) ) {
            //make the ball stick to the spike and GAME OVER
            spike = true;
            if([SettingsViewController isSoundOn])[self playSpikeSound];
            scene.physicsWorld.speed = 0;
            [self endGame];
            //SLOW POWERUP
        } else if ( ([contact.nodeA.name isEqualToString:@"slow"] && contact.nodeB.physicsBody == ballNode.physicsBody) || ([contact.nodeB.name isEqualToString:@"slow"] && contact.nodeA.physicsBody == ballNode.physicsBody) ) {
            if([SettingsViewController isSoundOn]) [self playPowerUpSound];
            //slow down the music
            [audioPlayer setRate:0.75];
            scene.physicsWorld.speed = 0.75;
            double delayInSeconds = 12.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                scene.physicsWorld.speed = 1.0;
                [audioPlayer setRate:1];
            });
            //FAST PowerDown
        } else if ( ([contact.nodeA.name isEqualToString:@"fast"] && contact.nodeB.physicsBody == ballNode.physicsBody) || ([contact.nodeB.name isEqualToString:@"fast"] && contact.nodeA.physicsBody == ballNode.physicsBody) ) {
            if([SettingsViewController isSoundOn])[self playPowerUpSound];
            //speed up music
            [audioPlayer setRate:1.25];
            scene.physicsWorld.speed = 2.0;
            double delayInSeconds = 12.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                scene.physicsWorld.speed = 1.0;
                [audioPlayer setRate:1];
            });
        }
        
        //Make the powerUp/PowerDown disappear if it is not a spike
        if (!spike) {
            if (contact.nodeA.physicsBody != ballNode.physicsBody) [contact.nodeA removeFromParentNode];
            else [contact.nodeB removeFromParentNode];
        }
        
    }
}

//Various functions to play in game sounds
-(void) playPongSound {
    if (pongSoundID == 0) {
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"pong_01" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &pongSoundID);
    }
    AudioServicesPlaySystemSound(pongSoundID);
}
-(void) playPowerUpSound {
    if (powerUpSoundID == 0) {
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"gameStart" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &powerUpSoundID);
    }
    AudioServicesPlaySystemSound(powerUpSoundID);
}
-(void) playSpikeSound {
    if (spkieSoundID == 0) {
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"playerHit" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &spkieSoundID);
    }
    AudioServicesPlaySystemSound(spkieSoundID);
}


//Prepare for segue overwrite for when we exit the game scene and return to the main menu
//We do this segue programatically and therefore opted to overwrite the prepare function
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MainMenuScreen"])
    {
          [segue destinationViewController];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

//Called Accerlerometer Function that will be called every nth second, determined in our core motion setup
//We set the properties of AccX, Y, and Z to their repsective output values
-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    self.accX= acceleration.x;
    self.accY=acceleration.y;
    self.accZ=acceleration.z;
    float scale=2.5;
    
    //Set the paddle nodes to equal its current position, plus the acclermoters values (scaled for smoothness)
    paddleNode.position=SCNVector3Make(paddleNode.position.x+self.accX*scale, paddleNode.position.y,paddleNode.position.z-self.accY*scale-1.0);
    
    //Here we elected to not have the camera follow with the paddle as the center, and thus limits the play field to the original screen size
    //cameraNode.position=SCNVector3Make(ballNode.position.x, ballNode.position.y,ballNode.position.z);

}
-(void)outputRotationData:(CMRotationRate)rotation

{
    if(ballNode.presentationNode.position.y<paddleNode.presentationNode.position.y-4){
            [self endGame];
    }
}



//This handles when a user touches either game end or game restart label
//Game restart will hide the two labels, reset the count, core motion and writeOnce and then calls viewDidLoad to re-init the game
//Game end resets the values in the main queue (so on reload the values are 0) and then programmtically segues to the Main Screen
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    UITouch *touch = [touches anyObject];
    if(touch.view == self.endLabel){
         dispatch_async(dispatch_get_main_queue(), ^{
             count=0;
             writeOnce=1;
             self.motionManager = [[CMMotionManager alloc] init];
        [self performSegueWithIdentifier:@"MainMenuScreen" sender:self];
         });
         }
    if (touch.view == self.restartLabel){
        self.endLabel.hidden=TRUE;
        self.endLabel.userInteractionEnabled=false;
        self.restartLabel.hidden=TRUE;
        self.restartLabel.userInteractionEnabled=false;
        self.gameoverLabel.hidden = TRUE;
        self.scoreLabel.hidden = TRUE;
        count=0;
        writeOnce=1;
        self.motionManager = [[CMMotionManager alloc] init];
        [self viewDidLoad];
    }
}

//Simple orientation check
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


@end

