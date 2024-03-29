/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "SCViewController.h"
#import "SCAppDelegate.h"
#import "SCLoginViewController.h"
#import "SCProtocols.h"
#import <AddressBook/AddressBook.h>
#import "TargetConditionals.h"
#import "ALRangingViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ALDefaults.h"

@interface SCViewController() < UITableViewDataSource, 
                                FBFriendPickerDelegate,
                                UINavigationControllerDelegate,
                                FBPlacePickerDelegate,
                                CLLocationManagerDelegate,
                                UIActionSheetDelegate>

@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *announceButton;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) UIActionSheet *mealPickerActionSheet;
@property (retain, nonatomic) NSArray *mealTypes;

@property (strong, nonatomic) NSObject<FBGraphPlace> *selectedPlace;
@property (strong, nonatomic) NSString *selectedMeal;
@property (strong, nonatomic) NSArray *selectedFriends;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) FBCacheDescriptor *placeCacheDescriptor;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (IBAction)announce:(id)sender;
- (void)populateUserDetails;
- (void)updateSelections;
- (void)updateCellIndex:(int)index withSubtitle:(NSString *)subtitle;
- (id<SCOGMeal>)mealObjectForMeal:(NSString *)meal;
- (void)postOpenGraphAction;
- (void)centerAndShowActivityIndicator;
- (void)setPlaceCacheDescriptorForCoordinates:(CLLocationCoordinate2D)coordinates;

@end

@implementation SCViewController
{
    CBPeripheralManager *_peripheralManager;
    NSNumber *_power;
}
@synthesize userNameLabel = _userNameLabel;
@synthesize userProfileImage = _userProfileImage;
@synthesize selectedPlace = _selectedPlace;
@synthesize selectedMeal = _selectedMeal;
@synthesize selectedFriends = _selectedFriends;
@synthesize announceButton = _announceButton;
@synthesize menuTableView = _menuTableView;
@synthesize locationManager = _locationManager;
@synthesize mealPickerActionSheet = _mealPickerActionSheet;
@synthesize activityIndicator = _activityIndicator;
@synthesize settingsViewController = _settingsViewController;
@synthesize mealTypes = _mealTypes;
@synthesize placeCacheDescriptor = _placeCacheDescriptor;

 

#pragma mark open graph



- (id)init
{
	
	if(self)
	{
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

        _power = [ALDefaults sharedDefaults].defaultPower;
        
        NSUUID *uuidUUID = [[NSUUID alloc] initWithUUIDString:@"0270879D-1972-4FB2-A72E-1C73607280C9"];
        BOOL _enabled=true;
        
        if(_peripheralManager.state < CBPeripheralManagerStatePoweredOn)
        {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Bluetooth must be enabled" message:@"To configure your device as a beacon" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
            
          //  return;
        }
        
        if(_enabled)
        {
            
            NSDictionary *peripheralData = nil;
            
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuidUUID identifier:@"com.apple.AirLocate"];
            peripheralData = [region peripheralDataWithMeasuredPower:_power];
            if(peripheralData)
            {
                [_peripheralManager startAdvertising:peripheralData];
            }
            
        }

     
	}
	
	return self;
}


// FBSample logic
// This is a helper function that returns an FBGraphObject representing a meal
- (id<SCOGMeal>)mealObjectForMeal:(NSString *)meal {
    
    // We create an FBGraphObject object, but we can treat it as an SCOGMeal with typed
    // properties, etc. See <FacebookSDK/FBGraphObject.h> for more details.
    id<SCOGMeal> result = (id<SCOGMeal>)[FBGraphObject graphObject];
    
    // Give it a URL of sample data that contains the object's name, title, description, and body.
    // These OG object URLs were created using the edit open graph feature of the graph tool
    // at https://www.developers.facebook.com/apps/
    if ([meal isEqualToString:@"Cheeseburger"]) {
        result.url = @"http://samples.ogp.me/314483151980285";
    } else if ([meal isEqualToString:@"Pizza"]) {
        result.url = @"http://samples.ogp.me/314483221980278";
    } else if ([meal isEqualToString:@"Hotdog"]) {
        result.url = @"http://samples.ogp.me/314483265313607";
    } else if ([meal isEqualToString:@"Italian"]) {
        result.url = @"http://samples.ogp.me/314483348646932";
    } else if ([meal isEqualToString:@"French"]) {
        result.url = @"http://samples.ogp.me/314483375313596";
    } else if ([meal isEqualToString:@"Chinese"]) {
        result.url = @"http://samples.ogp.me/314483421980258";
    } else if ([meal isEqualToString:@"Thai"]) {
        result.url = @"http://samples.ogp.me/314483451980255";
    } else if ([meal isEqualToString:@"Indian"]) {
        result.url = @"http://samples.ogp.me/314483491980251";
    }
    return result;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

// FBSample logic
// Creates the Open Graph Action.
- (void)postOpenGraphAction {
    // First create the Open Graph meal object for the meal we ate.
    id<SCOGMeal> mealObject = [self mealObjectForMeal:self.selectedMeal];
    
    // Now create an Open Graph eat action with the meal, our location, and the people we were with.
    id<SCOGEatMealAction> action = (id<SCOGEatMealAction>)[FBGraphObject graphObject];
    action.meal = mealObject;
    if (self.selectedPlace) {
        // FBSample logic
        // We don't use the action.place syntax here because, unfortunately, setPlace:
        // and a few other selectors may be flagged as reserved selectors by Apple's App Store
        // validation tools. While this doesn't necessarily block App Store approval, it
        // could slow down the approval process. Falling back to the setObjec:forKey:
        // selector is a useful technique to avoid such naming conflicts.
        [action setObject:self.selectedPlace forKey:@"place"];
    }
    if (self.selectedFriends.count > 0) {
        [action setObject:self.selectedFriends forKey:@"tags"];
    }

    // Create the request and post the action to the "me/fb_sample_scrumps:eat" path.
    [FBRequestConnection startForPostWithGraphPath:@"me/fb_sample_scrumps:eat"
                                       graphObject:action
                                 completionHandler:^(FBRequestConnection *connection,
                                                     id result,
                                                     NSError *error) {
                                     [self.activityIndicator stopAnimating];
                                     [self.view setUserInteractionEnabled:YES];
                                     
                                     NSString *alertText;
                                     if (!error) {
                                         alertText = [NSString stringWithFormat:@"Posted Open Graph action, id: %@",
                                                      [result objectForKey:@"id"]];
                                         
                                         // start over
                                         self.selectedMeal = nil;
                                         self.selectedPlace = nil;
                                         self.selectedFriends = nil;
                                         [self updateSelections];
                                     } else {
                                         alertText = [NSString stringWithFormat:@"error: domain = %@, code = %d",
                                                      error.domain, error.code];
                                     }
                                     [[[UIAlertView alloc] initWithTitle:@"Result" 
                                                                 message:alertText 
                                                                delegate:nil 
                                                       cancelButtonTitle:@"Thanks!" 
                                                       otherButtonTitles:nil] 
                                      show];
                                 }];
}

// FBSample logic
// Handles the user clicking the Announce button by creating an Open Graph Action
- (IBAction)announce:(id)sender {
    // if we don't have permission to announce, let's first address that
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         // re-call assuming we now have the permission
                                                         [self announce:sender];
                                                     }
                                                 }];
    } else {
        self.announceButton.enabled = false;
        [self centerAndShowActivityIndicator];
        [self.view setUserInteractionEnabled:NO];
        
        [self postOpenGraphAction];
    }
}

- (void)startLocationManager {
    [self.locationManager startUpdatingLocation];
}

- (void)centerAndShowActivityIndicator {
    CGRect frame = self.view.frame;
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    self.activityIndicator.center = center;
    [self.activityIndicator startAnimating];
}

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // If user presses cancel, do nothing
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    // One method handles the delegate action for two action sheets
    if (actionSheet == self.mealPickerActionSheet) { 
        self.selectedMeal = [self.mealTypes objectAtIndex:buttonIndex];
        [self updateSelections];
        
    }
}


#pragma mark -

#pragma mark Data fetch

- (void)updateCellIndex:(int)index withSubtitle:(NSString *)subtitle {
    UITableViewCell *cell = (UITableViewCell *)[self.menuTableView cellForRowAtIndexPath:
                                                [NSIndexPath indexPathForRow:index inSection:0]];
    cell.detailTextLabel.text = subtitle;
}

- (void)updateSelections {
    [self updateCellIndex:0 withSubtitle:(self.selectedMeal ?
                                          self.selectedMeal : 
                                          @"Select one")];
    [self updateCellIndex:1 withSubtitle:(self.selectedPlace ?
                                          self.selectedPlace.name :
                                          @"Select one")];
    
    NSString *friendsSubtitle = @"Select friends";
    int friendCount = self.selectedFriends.count;
    if (friendCount > 2) {
        // Just to mix things up, don't always show the first friend.
        id<FBGraphUser> randomFriend = [self.selectedFriends objectAtIndex:arc4random() % friendCount];
        friendsSubtitle = [NSString stringWithFormat:@"%@ and %d others", 
            randomFriend.name,
            friendCount - 1];
    } else if (friendCount == 2) {
        id<FBGraphUser> friend1 = [self.selectedFriends objectAtIndex:0];
        id<FBGraphUser> friend2 = [self.selectedFriends objectAtIndex:1];
        friendsSubtitle = [NSString stringWithFormat:@"%@ and %@",
            friend1.name,
            friend2.name];
    } else if (friendCount == 1) {
        id<FBGraphUser> friend = [self.selectedFriends objectAtIndex:0];
        friendsSubtitle = friend.name;
    }
    [self updateCellIndex:2 withSubtitle:friendsSubtitle];
    
    self.announceButton.enabled = (self.selectedMeal != nil);
}

// FBSample logic
// Displays the user's name and profile picture so they are aware of the Facebook
// identity they are logged in as.
- (void)populateUserDetails {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 self.userNameLabel.text = user.first_name;
                 self.userProfileImage.profileID = [user objectForKey:@"id"];
                 [self updateUserDetails:user.id userName:user.first_name];
                 
                 
        //          _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
       //          _power = [ALDefaults sharedDefaults].defaultPower;
               //  NSString *uuidConstant = @"0270879D-1972-4FB2-A72E-1C73607280C9";
                        }
         }];   
    }
}

-(IBAction) findFriendsButton
{

    ALRangingViewController *vC = [[ALRangingViewController alloc]init];
    [self.navigationController pushViewController:vC animated:YES];
}


- (void)updateUserDetails:(NSString*) userId userName: (NSString*) userName {
 
    NSString *fbidInput = userId;
    // NSString *returnGetFBID = [self.getFbidDetails: fbidInput];
    // [self.getFbidDetails: fbidInput];
    
    
    
    
    // NSString *existFbid = @"false";
    NSString *urlString1 = @"http://ibeaconideas.com/servicev2/examples/_006_crud/author?fbid=";
    urlString1 = [urlString1 stringByAppendingString:fbidInput];
    //urlString1 = [urlString1 stringByAppendingString:@"690404218"];
    NSLog(@"URL %@" , urlString1);
    NSURL *url1 = [NSURL URLWithString:urlString1];
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:url1];
    
    
    
    [request1 setHTTPMethod: @"GET"];
    [request1 setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSLog(@"Call completed");
    NSError *errorReturned1 = nil;
    NSURLResponse *theResponse1 =[[NSURLResponse alloc]init];
    NSData *data1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&theResponse1 error:&errorReturned1];
    
    NSString *retVal1;
    if (errorReturned1)
    {
        //...handle the error
        NSLog(@"Error");
    }
    else
    {
        retVal1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        NSLog(@"%@", retVal1);
        //...do something with the returned value
    }
    
    
    BOOL res = [retVal1 isEqualToString:@"false"];
    if(res)
        
    {
        
        
        
        
        NSUUID  *UUID = [NSUUID UUID];
        NSString* stringUUID = [UUID UUIDString];
        NSString *uuidConstant = @"0270879D-1972-4FB2-A72E-1C73607280C9";
        NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"test@gmail.com", @"email",
                                  userName, @"name",
                                  userId, @"fbid",
                                  stringUUID, @"uuid",
                                  @"765", @"major",
                                  @"987", @"minor",
                                  nil];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
        
        
        
        NSString *myParamString = @"{\"name\":\"Sibish\",\"email\":\"another@email.com\",\"fbid\":\"12345\",\"uuid\":\"123-232323\",\"major\":\"1234\",\"minor\":\"5678\"}";
        NSString *urlString = @"http://ibeaconideas.com/servicev2/examples/_006_crud/author";
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        
        
        [request setHTTPMethod: @"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        //   [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        //NSString *myRequestString = @"param="; // Attention HERE!!!!
        NSString *myRequestString = @"";
        [myRequestString stringByAppendingString:myParamString];
        //   NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        // [request setHTTPBody: requestData];
        
        [request setHTTPBody: jsonData];
        
        
        NSLog(@"Call completed");
        NSError *errorReturned = nil;
        NSURLResponse *theResponse =[[NSURLResponse alloc]init];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
        if (errorReturned)
        {
            //...handle the error
            NSLog(@"Error");
        }
        else
        {
            NSString *retVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", retVal);
            //...do something with the returned value
        }
        
    }
}

- (void)dealloc {
    _locationManager.delegate = nil;
    _mealPickerActionSheet.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"iBeacon Friends";

    // Get the CLLocationManager going.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // We don't want to be notified of small changes in location, preferring to use our
    // last cached results, if any.
    self.locationManager.distanceFilter = 50;
    
    // This avoids a gray background in the table view on iPad.
    if ([self.menuTableView respondsToSelector:@selector(backgroundView)]) {
        self.menuTableView.backgroundView = nil;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Logout"
                                                style:UIBarButtonItemStyleBordered 
                                              target:self 
                                              action:@selector(settingsButtonWasPressed:)];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(sessionStateChanged:) 
                                                 name:SCSessionStateChangedNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
}

-(void)settingsButtonWasPressed:(id)sender {
    if (self.settingsViewController == nil) {
       // self.settingsViewController = [[FBUserSettingsViewController alloc] init];
        self.settingsViewController = FBUserSettingsViewController.new;
    }
    self.settingsViewController.delegate = self;
    self.settingsViewController.doneButton = nil;
    self.settingsViewController.cancelButton = nil;
   // [self presentViewController:self.settingsViewController animated:YES completion:nil];
   // [self presentedViewController:self.settingsViewController animated:YES completion:nil];
   // [self. pushViewController:self.settingsViewController animated:YES];
   // [self presentViewController:self.settingsViewController animated:YES completion:YES];
    [self.navigationController pushViewController:self.settingsViewController animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Release any retained subviews of the main view.
    self.mealPickerActionSheet = nil;
}

- (void)sessionStateChanged:(NSNotification*)notification {
    // A more complex app might check the state to see what the appropriate course of
    // action is, but our needs are simple, so just make sure our idea of the session is
    // up to date and repopulate the user's name and picture (which will fail if the session
    // has become invalid).
    [self populateUserDetails];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)setPlaceCacheDescriptorForCoordinates:(CLLocationCoordinate2D)coordinates {
    self.placeCacheDescriptor =
    [FBPlacePickerViewController cacheDescriptorWithLocationCoordinate:coordinates
                                                        radiusInMeters:1000
                                                            searchText:@"restaurant"
                                                          resultsLimit:50
                                                      fieldsForRequest:nil];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cell.textLabel.clipsToBounds = YES;

        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:1];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cell.detailTextLabel.clipsToBounds = YES;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"What are you eating?";
            cell.detailTextLabel.text = @"Select one";
            cell.imageView.image = [UIImage imageNamed:@"action-eating.png"];
            break;
            
        case 1:
            cell.textLabel.text = @"Where are you?";
            cell.detailTextLabel.text = @"Select one";
            cell.imageView.image = [UIImage imageNamed:@"action-location.png"];
            break;
            
        case 2:
            cell.textLabel.text = @"With whom?";
            cell.detailTextLabel.text = @"Select friends";
            cell.imageView.image = [UIImage imageNamed:@"action-people.png"];
            break;
            
        default:
            break;
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *target;
    
    switch (indexPath.row) {
        case 0: {
            // if we don't yet have an array of meal types, create one now
            if (!self.mealTypes) {
                self.mealTypes = [NSArray arrayWithObjects:
                                  @"Cheeseburger", 
                                  @"Pizza",
                                  @"Hotdog",
                                  @"Italian",
                                  @"French",
                                  @"Chinese",
                                  @"Thai",
                                  @"Indian",
                                  nil];
            }
            self.mealPickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a meal"
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil];
                                          
            for( NSString *meal in self.mealTypes) {
                [self.mealPickerActionSheet addButtonWithTitle:meal]; 
            }
            
            self.mealPickerActionSheet.cancelButtonIndex = [self.mealPickerActionSheet addButtonWithTitle:@"Cancel"];
            
            [self.mealPickerActionSheet showInView:self.view];
            return;
        }
        
        case 1: {
            FBPlacePickerViewController *placePicker = [[FBPlacePickerViewController alloc] init];
            
            placePicker.title = @"Select a restaurant";

            // SIMULATOR BUG:
            // See http://stackoverflow.com/questions/7003155/error-server-did-not-accept-client-registration-68
            // at times the simulator fails to fetch a location; when that happens rather than fetch a
            // a meal near 0,0 -- let's see if we can find something good in Paris
            if (self.placeCacheDescriptor == nil) {
                [self setPlaceCacheDescriptorForCoordinates:CLLocationCoordinate2DMake(48.857875, 2.294635)];
            }
            
            [placePicker configureUsingCachedDescriptor:self.placeCacheDescriptor];
            [placePicker loadData];
            [placePicker presentModallyFromViewController:self
                                                 animated:YES
                                                  handler:^(FBViewController *sender, BOOL donePressed) {
                                                      if (donePressed) {
                                                          self.selectedPlace = placePicker.selection;
                                                          [self updateSelections];
                                                      }
                                                  }];
            return;
        }
            
        case 2: {
            FBFriendPickerViewController *friendPicker = [[FBFriendPickerViewController alloc] init];
            
            // Set up the friend picker to sort and display names the same way as the
            // iOS Address Book does.
            
            // Need to call ABAddressBookCreate in order for the next two calls to do anything.
            ABAddressBookCreate();
            ABPersonSortOrdering sortOrdering = ABPersonGetSortOrdering();
            ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormat();
            
            friendPicker.sortOrdering = (sortOrdering == kABPersonSortByFirstName) ? FBFriendSortByFirstName : FBFriendSortByLastName;
            friendPicker.displayOrdering = (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) ? FBFriendDisplayByFirstName : FBFriendDisplayByLastName;
            
            [friendPicker loadData];
            [friendPicker presentModallyFromViewController:self
                                                  animated:YES
                                                   handler:^(FBViewController *sender, BOOL donePressed) {
                                                       if (donePressed) {
                                                           self.selectedFriends = friendPicker.selection;
                                                           [self updateSelections];
                                                       }
                                                   }];
            return;
        }
    }
    
    [self.navigationController pushViewController:target animated:YES];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    if (!oldLocation ||
        (oldLocation.coordinate.latitude != newLocation.coordinate.latitude && 
         oldLocation.coordinate.longitude != newLocation.coordinate.longitude &&
         newLocation.horizontalAccuracy <= 100.0)) {
            // Fetch data at this new location, and remember the cache descriptor.
            [self setPlaceCacheDescriptorForCoordinates:newLocation.coordinate];
            [self.placeCacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
    }
}

- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error {
	NSLog(@"%@", error);
}

#pragma mark -

@end
