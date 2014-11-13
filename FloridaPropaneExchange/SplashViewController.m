//
//  SplashViewController.m
//  FloridaPropaneExchange
//
//  Created by Mac on 21/10/14.
//  Copyright (c) 2014 FloridaPropaneExchange. All rights reserved.
//

#import "SplashViewController.h"
#import "ViewController.h"
#import "ThankyouViewController.h"

@interface SplashViewController ()
@property (nonatomic,retain) NSTimer *Mytimer;
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(targetMethod)
                                   userInfo:nil
                                    repeats:NO];
    
    UIButton *GotoView = (UIButton *)[self.view viewWithTag:444];
    [GotoView addTarget:self action:@selector(SendtoNormalView:) forControlEvents:UIControlEventTouchUpInside];
}
-(IBAction)SendtoNormalView:(id)sender
{
    ViewController *RedirectViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self.navigationController pushViewController:RedirectViewController animated:YES];
}
-(void)targetMethod
{
    ViewController *ViewControllerm = [[ViewController alloc] init];
    [self.navigationController pushViewController:ViewControllerm animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
