#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize display, amtText, status,uuid;
@synthesize oneColumnList;
@synthesize thePickerView;

-(IBAction) click1
{
    NSString *myString = @"Waiting for Merchant Approval";
    //NSString *test = [myString stringByAppendingString://(NSString*)amtText];
    status.numberOfLines = 0;
    status.text = myString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.slider.minimumValue = 700;
    self.slider.maximumValue = 850;
    self.status.text = uuid;
    
    NSString *merchantLabel = NULL;
    NSString *saleAmount = @"Sale Amount : $850.00";
    NSString *imagePath = @"Clive-Christian-Perfume-2.jpg";
    
    if([uuid isEqualToString:@"UUID:E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"])
    {
        merchantLabel = @"Perfume Gallery";
    }
    else if([uuid isEqualToString:@"UUID:5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"])
    {
        merchantLabel = @"As You Wish";
        imagePath=@"asyouwish.jpg";
        saleAmount= @"Sale Amount : $40.00";
        self.slider.minimumValue = 30;
        self.slider.maximumValue = 40;
        amtText.text = @"40";
        self.itemTitle.text=@"Full Day Painting";
    }
    else if([uuid isEqualToString:@"UUID:73E9684C-A0A9-E151-4DF6-BEECE13387EF"])
    {
        merchantLabel = @"AZ Custom Tees";
        imagePath=@"aztees.jpg";
        saleAmount= @"Sale Amount : $20.00";
        self.slider.minimumValue = 10;
        self.slider.maximumValue = 20;
        amtText.text = @"20";
        self.itemTitle.text=@"Custom T Shirt - Blue/Red";
    }
    else if([uuid isEqualToString:@"UUID:74278BDA-B644-4520-8F0C-720EAF059935"])
    {
        merchantLabel = @"Euro Chic";
        imagePath=@"eurochic.jpeg";
        saleAmount= @"Sale Amount : $60.00";
        self.slider.minimumValue = 30;
        self.slider.maximumValue = 60;
        amtText.text = @"60";
        self.itemTitle.text=@"Women's Olowahu Euro Shoes";
    }
    else{
        merchantLabel = @"Perfume Gallery";
    }

    self.merchantTitle.text=merchantLabel;
    self.display.text=saleAmount;
    [self.imageToDisplay setImage:[UIImage imageNamed:imagePath]];
    
    thePickerView.showsSelectionIndicator = TRUE;
    
    self.oneColumnList=[[NSArray alloc] initWithObjects:@"New York",@"Montreal",@"Miami",@"Boston",@"Philadelphia",@"Toronto",@"Calcary",@"Vancouver",@"Los Angeles",@"Cupertino",@"Austin",@"New Orleans", nil];

    
    NSMutableArray *dataArray;
    // Init the data array.
    dataArray = [[NSMutableArray alloc] init];
    
    // Add some data for demo purposes.
    [dataArray addObject:@"One"];
    [dataArray addObject:@"Two"];
    [dataArray addObject:@"Three"];
    [dataArray addObject:@"Four"];
    [dataArray addObject:@"Five"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [oneColumnList count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
     return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSInteger val = lround(slider.value);
    //float val = self.slider.value;
    NSLog(@"Sibi Value : %ld",(long)val);
    
    self.amtText.text = [NSString stringWithFormat:@"%d",val];
}

//- (id)initWithName:(NSString *)theName
//{
 //   self = [super initWithNibName:@"ViewController" bundle:nil];
 //   if (self) {
  //      self.status.text = [theName copy];
  //  }
   // return self;
//}

@end


