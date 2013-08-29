//
//  ViewController.h
//  SensorTagEX
//
//  Created by SIBISH BASHEER on 6/30/13.
//  Copyright (c) 2013 Texas Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *display;

@property (strong, nonatomic) IBOutlet UILabel *merchantTitle;

@property (strong, nonatomic) IBOutlet UILabel *itemTitle;

@property (strong, nonatomic) IBOutlet UILabel *status;

@property (strong, nonatomic) IBOutlet UITextField *amtText;

@property (strong, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, retain) IBOutlet UIPickerView *thePickerView;

@property (strong, nonatomic) NSArray *oneColumnList;

@property (strong, nonatomic) NSString *uuid;

@property (nonatomic, retain) IBOutlet UIImageView *imageToDisplay;

-(IBAction) click1;

-(IBAction) sliderChanged:(id)sender;

@end
