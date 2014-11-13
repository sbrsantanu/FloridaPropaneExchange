//
//  ViewController.m
//  FloridaPropaneExchange
//
//  Created by Mac on 17/10/14.
//  Copyright (c) 2014 FloridaPropaneExchange. All rights reserved.
//

#import "ViewController.h"
#import "NSString+PJR.h"
#import "ThankyouViewController.h"

typedef enum
{
    DelevaryModeNone = 0,
    DelevaryModeEmergency,
    DelevaryModeNormal
} DelevaryModeSelected;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ShowAlert(myTitle, myMessage) [[[UIAlertView alloc] initWithTitle:myTitle message:myMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]

@interface ViewController ()
{
    NSOperationQueue *OperationQueueForCategory;
}
@property (nonatomic,retain) UIScrollView * BackgroundScroollView;
@property (nonatomic,retain) UITextField  *FLCompanyName, *FLOrderBy,*FLContactPhoneOrEmail,*FLDate,*FLStreetAddress,*FLCity,*FLBBQNumber;
@property (nonatomic,retain) IBOutlet UIView *AdditionalView;

@property (nonatomic,retain) UIButton *EmergencyButton;
@property (nonatomic,retain) UIButton *NormalButton,*SendButton;

@property (nonatomic, assign) DelevaryModeSelected DelevaryMode;

@property (nonatomic, retain) UIActivityIndicatorView *ActivityIndicatorView;
@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *HeaderView = (UIView *)[self.view viewWithTag:121];
    [HeaderView setBackgroundColor:UIColorFromRGB(0x131333)];
    
    UIButton *dateSelectButton = (UIButton *)[self.view viewWithTag:123];
    [dateSelectButton addTarget:self action:@selector(openDateSelectionController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *NumberSelectButton = (UIButton *)[self.view viewWithTag:124];
    [NumberSelectButton addTarget:self action:@selector(openPickerController:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.AdditionalView setFrame:CGRectMake(0, 488, self.AdditionalView.layer.frame.size.width, self.AdditionalView.layer.frame.size.height)];
    
    self.EmergencyButton = (UIButton *)[self.AdditionalView viewWithTag:7777];
    [self.EmergencyButton addTarget:self action:@selector(EmergencyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.NormalButton    = (UIButton *)[self.AdditionalView viewWithTag:8888];
    [self.NormalButton addTarget:self action:@selector(NormalButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.SendButton    = (UIButton *)[self.AdditionalView viewWithTag:1234];
    [self.SendButton addTarget:self action:@selector(SendButtonButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.DelevaryMode = DelevaryModeNone;
    
    /*
     Decleare background scrollview
     */
    
    self.BackgroundScroollView = (UIScrollView *)[self.view viewWithTag:100];
    [self.BackgroundScroollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.3)];
    [self.BackgroundScroollView setScrollEnabled:YES];
    [self.BackgroundScroollView setBackgroundColor:[UIColor clearColor]];
    [self.BackgroundScroollView setUserInteractionEnabled:YES];
    [self.BackgroundScroollView setDelegate:self];
    
    [self.BackgroundScroollView addSubview:self.AdditionalView];
    
    
    for(id aSubViewNew in [self.AdditionalView subviews])
    {
        if([aSubViewNew isKindOfClass:[UILabel class]])
        {
            UILabel *MyLabel = (UILabel *)aSubViewNew;
            [MyLabel setBackgroundColor:[UIColor clearColor]];
            [MyLabel setTextColor:(MyLabel.tag == 99)?UIColorFromRGB(0x9e9e9e):UIColorFromRGB(0x303030)];
            [MyLabel setFont:[UIFont fontWithName:@"Helvetica" size:(MyLabel.tag == 99)?11.0f:13.0f]];
        }
    }
    
    
    for(id aSubViewNew in [self.BackgroundScroollView subviews])
    {
        if([aSubViewNew isKindOfClass:[UILabel class]])
        {
            UILabel *MyLabel = (UILabel *)aSubViewNew;
            if (MyLabel.tag == 44 || MyLabel.tag == 45) {
                [MyLabel setFont:[UIFont fontWithName:@"Helvetica" size:17.0f]];
                [MyLabel setText:@"REQUEST FOR TANK DELIVERY"];
                [MyLabel setTextColor:(MyLabel.tag == 44)?UIColorFromRGB(0x3a85c2):UIColorFromRGB(0x303030)];
            } else {
                [MyLabel setBackgroundColor:[UIColor clearColor]];
                [MyLabel setTextColor:UIColorFromRGB(0x303030)];
                [MyLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
            }
        }
    }
    
    /*
     Searchfor uitextfield in main scrollview
     */
    
    for(id aSubView in [self.BackgroundScroollView subviews])
    {
        if([aSubView isKindOfClass:[UITextField class]])
        {
            /*
             Decleare the textfield
             */
            
            UITextField *textField=(UITextField*)aSubView;
            [textField setBackgroundColor:[UIColor whiteColor]];
            [textField setTextColor:[UIColor blackColor]];
            [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [textField setDelegate:self];
            
            /*
             Add placholder to textfield
             */
            
            switch (textField.tag) {
                case 444:
                    self.FLCompanyName = textField;
                    break;
                case 445:
                    self.FLOrderBy = textField;
                    break;
                case 446:
                    self.FLContactPhoneOrEmail = textField;
                    break;
                case 447:
                    self.FLDate = textField;
                    break;
                case 448:
                    self.FLStreetAddress = textField;
                    break;
                case 449:
                    self.FLCity = textField;
                    break;
                case 450:
                    self.FLBBQNumber = textField;
                    break;
            }
            
            /*
             Add padding to textfield
             */
            
            [self PaddingViewWithTextField:textField];
            
            /*
             Set border
             */
            
            [textField.layer setBorderColor:UIColorFromRGB(0x9e9e9e).CGColor];
            [textField.layer setBorderWidth:1.0f];
            [textField.layer setCornerRadius:1.0f];
        }
    }
    
    self.ActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(140, 300, 32, 32)];
    [self.view addSubview:self.ActivityIndicatorView];
    [self.ActivityIndicatorView setHidesWhenStopped:YES];
    [self.ActivityIndicatorView setHidden:YES];
    [self.ActivityIndicatorView setColor:[UIColor darkGrayColor]];
    [self.ActivityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    OperationQueueForCategory=[[NSOperationQueue alloc] init];
}
-(void)SendButtonButtonClicked
{
    NSLog(@"Submit button Licked");
    for(id aSubView in [self.BackgroundScroollView subviews])
    {
        if([aSubView isKindOfClass:[UITextField class]])
        {
            UITextField *textField=(UITextField*)aSubView;
            [textField resignFirstResponder];
        }
    }
    
    BOOL isValidate = YES;
    
    if ([self CleanTextField:[self.FLCompanyName text]].length == 0) {
        ShowAlert(@"Credential Error", @"Company name can't be blank");
        isValidate = NO;
    } else if ([self CleanTextField:[self.FLOrderBy text]].length == 0) {
        ShowAlert(@"Credential Error", @"Order By can't be blank");
        isValidate = NO;
    } else if ([self CleanTextField:[self.FLContactPhoneOrEmail text]].length == 0) {
        ShowAlert(@"Credential Error", @"Please provide phone number or email");
        isValidate = NO;
    } else if ([self CleanTextField:[self.FLDate text]].length == 0) {
        ShowAlert(@"Credential Error", @"Date can't be blank");
        isValidate = NO;
    } else if ([self CleanTextField:[self.FLStreetAddress text]].length == 0) {
        ShowAlert(@"Credential Error", @"Street Address can't be blank");
        isValidate = NO;
    } else if ([self CleanTextField:[self.FLCity text]].length == 0) {
        ShowAlert(@"Credential Error", @"City can't be blank");
        isValidate = NO;
    } else if ([self CleanTextField:[self.FLBBQNumber text]].length == 0) {
        ShowAlert(@"Credential Error", @"Number of BBQ Tank can't be blank");
        isValidate = NO;
    } else if ([[self CleanTextField:[self.FLBBQNumber text]] isEqualToString:@"0"]) {
        ShowAlert(@"Credential Error", @"Number of BBQ Tank can't be 0");
        isValidate = NO;
    } else if (self.DelevaryMode == DelevaryModeNone) {
        ShowAlert(@"Credential Error", @"Please select Delivery method");
        isValidate = NO;
    } else {
        NSLog(@"Go for phone or email validation");
        
        NSString *string = @"@";
        
        if ([[self.FLContactPhoneOrEmail text] rangeOfString:string].location == NSNotFound) {
            NSLog(@"string is an phone number");
            if (![[self CleanTextField:self.FLContactPhoneOrEmail.text] isPhoneNumber]) {
                 ShowAlert(@"Credential Error", @"Phone number is not valied");
                isValidate = NO;
            } else {
                isValidate = YES;
            }
        } else {
            NSLog(@"string is an email");
            if (![[self CleanTextField:self.FLContactPhoneOrEmail.text] isEmail]) {
                ShowAlert(@"Credential Error", @"Email is not valied");
                isValidate = NO;
            } else {
                isValidate = YES;
            }
        }
    }
    
    if (isValidate) {
        NSLog(@"Everything is fine for now");
        
        [self.view setUserInteractionEnabled:NO];
        [self.ActivityIndicatorView startAnimating];
        [self.ActivityIndicatorView setHidden:NO];
        
        @autoreleasepool
        {
            NSInvocationOperation *OperationCredit=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(FetchCategories) object:nil];
            [OperationQueueForCategory addOperation:OperationCredit];
        }
    }
}
-(void) FetchCategories
{
    NSString *DelMode = (self.DelevaryMode == DelevaryModeEmergency)?@"Emergency Resupply":@"Deliver on Normal Route";
    
    @try
    {
        NSString *url=[NSString stringWithFormat:@"http://myphpdevelopers.com/dev/ocrscanner/webservice.php?rquest=Sendmail&CompanyName=%@&OrderBy=%@&ContactPhoneOremail=%@&date=%@&Streetaddress=%@&city=%@&Numberofbbqtanks=%@&DeliveryMethod=%@",[[self CleanTextField:[self.FLCompanyName text]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[self CleanTextField:[self.FLOrderBy text]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[self CleanTextField:[self.FLContactPhoneOrEmail text]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[self CleanTextField:[self.FLDate text]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[self CleanTextField:[self.FLStreetAddress text]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[self CleanTextField:[self.FLCity text]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[self CleanTextField:[self.FLBBQNumber text]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[DelMode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"URL : %@", url);
        
        
        NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
        if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
        
        NSLog(@"results -- %@",results);
        
        if([[results objectForKey:@"status"] isEqualToString:@"success"])
        {
            [self performSelectorOnMainThread:@selector(gotCategories) withObject:nil waitUntilDone:YES];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(HandleError) withObject:nil waitUntilDone:YES];
        }
    }
    @catch(NSException *juju)
    {
        NSLog(@"Reporting juju from FetchCategories: %@",juju);
        [self performSelectorOnMainThread:@selector(HandleError) withObject:nil waitUntilDone:YES];
    }
}
-(void)HandleError
{
    UIAlertView *showError=[[UIAlertView alloc] initWithTitle:@"Sorry!!" message:@"Something is not right. Please try again later." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Retry", nil];
    [showError show];
}
-(void)gotCategories
{
    ThankyouViewController *Thankyou = [[ThankyouViewController alloc] initWithNibName:@"ThankyouViewController" bundle:nil];
    [self.navigationController pushViewController:Thankyou animated:YES];
}
-(void)EmergencyButtonClicked
{
    for(id aSubView in [self.BackgroundScroollView subviews])
    {
        if([aSubView isKindOfClass:[UITextField class]])
        {
            UITextField *textField=(UITextField*)aSubView;
            [textField resignFirstResponder];
        }
    }
    if (self.DelevaryMode == DelevaryModeNone) {
        [self.EmergencyButton setBackgroundImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
        self.DelevaryMode = DelevaryModeEmergency;
    } else if (self.DelevaryMode == DelevaryModeEmergency) {
        [self.EmergencyButton setBackgroundImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
        self.DelevaryMode = DelevaryModeNone;
    } else if (self.DelevaryMode == DelevaryModeNormal) {
        [self.NormalButton setBackgroundImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
        [self.EmergencyButton setBackgroundImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
        self.DelevaryMode = DelevaryModeEmergency;
    }
}
-(NSString *)CleanTextField:(NSString *)TextfieldName
{
    NSString *Cleanvalue = [TextfieldName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return Cleanvalue;
}
-(void)NormalButtonClicked
{
    if (self.DelevaryMode == DelevaryModeNone) {
        [self.NormalButton setBackgroundImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
        self.DelevaryMode = DelevaryModeNormal;
    } else if (self.DelevaryMode == DelevaryModeNormal) {
        [self.NormalButton setBackgroundImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
        self.DelevaryMode = DelevaryModeNone;
    } else if (self.DelevaryMode == DelevaryModeEmergency) {
        [self.EmergencyButton setBackgroundImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
        [self.NormalButton setBackgroundImage:[UIImage imageNamed:@"select.png"] forState:UIControlStateNormal];
        self.DelevaryMode = DelevaryModeNormal;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textField.tag ====== %ld",(long)textField.tag);
    switch (textField.tag) {
        case 444:
        {
            [UIView animateWithDuration:1.0f animations:^(void){
                [self.BackgroundScroollView setContentOffset:CGPointMake(0, 20) animated:YES];
            }];
            break;
        }
        case 445:
        {
            [UIView animateWithDuration:1.0f animations:^(void){
                [self.BackgroundScroollView setContentOffset:CGPointMake(0, 60) animated:YES];
            }];
            break;
        }
        case 446:
        {
            [UIView animateWithDuration:1.0f animations:^(void){
                [self.BackgroundScroollView setContentOffset:CGPointMake(0, 100) animated:YES];
            }];
            break;
        }
        case 447:
        {
            [UIView animateWithDuration:1.0f animations:^(void){
                [self.BackgroundScroollView setContentOffset:CGPointMake(0, 180) animated:YES];
            }];
            break;
        }
        case 448:
        {
            [UIView animateWithDuration:1.0f animations:^(void){
                [self.BackgroundScroollView setContentOffset:CGPointMake(0, 220) animated:YES];
            }];
            break;
        }
        case 449:
        {
            [UIView animateWithDuration:1.0f animations:^(void){
                [self.BackgroundScroollView setContentOffset:CGPointMake(0, 260) animated:YES];
            }];
            break;
        }
        case 450:
        {
            [UIView animateWithDuration:1.0f animations:^(void){
                [self.BackgroundScroollView setContentOffset:CGPointMake(0, 300) animated:YES];
            }];
            break;
        }
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:1.0f animations:^(void){
       // [self.BackgroundScroollView setContentOffset:CGPointMake(0, -20) animated:YES];
    }];
    [textField resignFirstResponder];
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(void)PaddingViewWithTextField:(UITextField *)UITextField
{
    UIView *paddingView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UITextField.layer.frame.size.height-25, UITextField.layer.frame.size.height)];
    UITextField.leftView        = paddingView;
    UITextField.leftViewMode    = UITextFieldViewModeAlways;
    [UITextField addSubview:paddingView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openDateSelectionController:(id)sender {
    
    for(id aSubView in [self.BackgroundScroollView subviews])
    {
        if([aSubView isKindOfClass:[UITextField class]])
        {
            UITextField *textField=(UITextField*)aSubView;
            [textField resignFirstResponder];
        }
    }
    
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    dateSelectionVC.delegate = self;
    dateSelectionVC.titleLabel.text = @"Please choose a date and press 'Select' or 'Cancel'.";
    
    //You can access the actual UIDatePicker via the datePicker property
    dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
    dateSelectionVC.datePicker.minuteInterval = 5;
    dateSelectionVC.datePicker.date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
    [dateSelectionVC show];
}

#pragma mark - RMDAteSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate {
    
    NSArray *SelectedDate = [[NSString stringWithFormat:@"%@",aDate] componentsSeparatedByString:@" "];
    
    [self.FLDate setText:[SelectedDate objectAtIndex:0]];
    NSLog(@"Successfully selected date: %@", aDate);
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    NSLog(@"Date selection was canceled");
}

- (IBAction)openPickerController:(id)sender {
    
    for(id aSubView in [self.BackgroundScroollView subviews])
    {
        if([aSubView isKindOfClass:[UITextField class]])
        {
            UITextField *textField=(UITextField*)aSubView;
            [textField resignFirstResponder];
        }
    }
    
    RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    pickerVC.delegate = self;
    pickerVC.titleLabel.text = @"Please choose a row and press 'Select' or 'Cancel'.";
    [pickerVC show];
}

#pragma mark - RMPickerViewController Delegates
- (void)pickerViewController:(RMPickerViewController *)vc didSelectRows:(NSArray *)selectedRows {
    [self.FLBBQNumber setText:[NSString stringWithFormat:@"%@", [selectedRows objectAtIndex:0]]];
    NSLog(@"Successfully selected rows: %@", selectedRows);
}

- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc {
    NSLog(@"Selection was canceled");
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 1000;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%lu", (long)row];
}

@end
