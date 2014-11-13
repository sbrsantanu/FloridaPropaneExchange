//
//  ThankyouViewController.m
//  FloridaPropaneExchange
//
//  Created by Mac on 17/10/14.
//  Copyright (c) 2014 FloridaPropaneExchange. All rights reserved.
//

#import "ThankyouViewController.h"
#import "ViewController.h"

@interface ThankyouViewController ()

@end

@implementation ThankyouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *backbutton = (UIButton *)[self.view viewWithTag:999];
    [backbutton setBackgroundColor:[UIColor clearColor]];
    [backbutton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
}
-(void)goBack
{
    ViewController *Viewone = [[ViewController alloc] initWithNibName:NSStringFromClass([ViewController class]) bundle:nil];
    [self.navigationController pushViewController:Viewone animated:YES];
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
