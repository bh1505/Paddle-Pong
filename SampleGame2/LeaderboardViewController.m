//
//  LeaderboardViewController.m
//  SampleGame2
//
//  Created by Robert Prast on 4/21/18.
//  Copyright © 2018 Robert Prast. All rights reserved.
//

#import "LeaderboardViewController.h"

@interface LeaderboardViewController ()

@end

@implementation LeaderboardViewController

-(void) viewDidAppear:(BOOL)animated{

}
- (void)viewDidLoad {
    [super viewDidLoad];

    //synchronize user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];

    //Go through each label, and if there is a highscore greater than 0, display that value
    if([defaults objectForKey:@"values"][0] >0){
        _highScore1.text= [NSString stringWithFormat:@"%@",[defaults objectForKey:@"values"][0]];}
    if([defaults objectForKey:@"values"][1] >0){
        _highScore2.text= [NSString stringWithFormat:@"%@",[defaults objectForKey:@"values"][1]];}
    if([defaults objectForKey:@"values"][2] >0){
        _highScore3.text= [NSString stringWithFormat:@"%@",[defaults objectForKey:@"values"][2]];}
    if([defaults objectForKey:@"values"][3] >0){
         _highScore4.text= [NSString stringWithFormat:@" %@",[defaults objectForKey:@"values"][3]];}
    if([defaults objectForKey:@"values"][4] >0){
         _highScore5.text= [NSString stringWithFormat:@" %@",[defaults objectForKey:@"values"][4]];}
    if([defaults objectForKey:@"values"][5] >0){
        _highScore6.text= [NSString stringWithFormat:@" %@",[defaults objectForKey:@"values"][5]];}
    if([defaults objectForKey:@"values"][6] >0){
        _highScore7.text= [NSString stringWithFormat:@"%@",[defaults objectForKey:@"values"][6]];}
    if([defaults objectForKey:@"values"][7] >0){
     _highScore8.text= [NSString stringWithFormat:@"%@",[defaults objectForKey:@"values"][7]];}
    if([defaults objectForKey:@"values"][8] >0){
     _highScore9.text= [NSString stringWithFormat:@"%@",[defaults objectForKey:@"values"][8]];}
    if([defaults objectForKey:@"values"][9] >0){
     _highScore10.text=[NSString stringWithFormat:@"%@",[defaults objectForKey:@"values"][9]];}
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
