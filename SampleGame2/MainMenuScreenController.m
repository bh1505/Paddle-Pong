//
//  MainMenuScreenController.m
//  SampleGame2
//
//  Created by Robert Prast on 4/29/18.
//  Copyright © 2018 Robert Prast. All rights reserved.
//

#import "MainMenuScreenController.h"

@implementation MainMenuScreenController
- (void) viewDidAppear:(BOOL)animated
{

}
- (void)viewDidLoad {
    [super viewDidLoad];

    //UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"led"]];
    
    // start a timer that will go off several times per second
    [NSTimer scheduledTimerWithTimeInterval:0.4
                                     target:self
                                   selector:@selector(onTimer:)
                                   userInfo:nil
                                    repeats:YES];
}

// Timer event is called whenever the timer goes off
-(void) onTimer:(NSTimer *)timer
{
    UIImage *ball =  [UIImage imageNamed:@"fallBall"];
    UIImageView *ballView = [[UIImageView alloc] initWithImage:ball];
    //ballView.image = ball;
    
    // choose random X starting and ending positions
    double startX = arc4random_uniform(320);
    double endX = arc4random_uniform(320);
    
    // different balls will fall at different speeds
    double howFast = 4;
    
    // set the ball start position
    ballView.frame = CGRectMake(startX, -100.0, 50.0, 50.0);
    ballView.alpha = 1;
    
    // put the ball in our main view
    [self.view addSubview:ballView];
    
    [UIView animateWithDuration: howFast delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        ballView.frame = CGRectMake(endX, 780.0, 25.0, 25.0);
    } completion:^(BOOL finished) {
        [ballView removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
