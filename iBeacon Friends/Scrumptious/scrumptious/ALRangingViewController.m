
#import "ALRangingViewController.h"
#import "ALDefaults.h"
#import "ViewController.h"

@implementation ALRangingViewController
{
    NSMutableDictionary *_beacons;
    CLLocationManager *_locationManager;
    NSMutableArray *_rangedRegions;
    NSMutableArray *immediateBeaconsNew;
    NSMutableArray *nearBeaconsNew;
    NSMutableArray *unknownBeaconsNew;
    NSMutableArray *farBeaconsNew;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    NSLog(@"initWithStyle");
	self = [super initWithStyle:style];
	if(self)
	{
        _beacons = [[NSMutableDictionary alloc] init];
        immediateBeaconsNew = [[NSMutableArray alloc] init];
        nearBeaconsNew = [[NSMutableArray alloc] init];
        unknownBeaconsNew = [[NSMutableArray alloc] init];
        farBeaconsNew = [[NSMutableArray alloc] init];
        // This location manager will be used to demonstrate how to range beacons.
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
	}
	
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // CoreLocation will call this delegate method at 1 Hz with updated range information.
    // Beacons will be categorized and displayed by proximity.
    NSLog(@"didRangeBeacons :: %d", beacons.count);
    NSLog(@"didRangeBeacons ::_beacons :: %d", _beacons.count);
    CLBeacon *beaconAdded = NULL;
    
    for (id key in _beacons) {
        id anObject = [_beacons objectForKey:key];
        NSLog(@"_beacons :: key :: %@" , key );
        NSLog(@"_beacons :: object Count :: %@" , anObject );
        /* Do something with anObject. */
    }
    
    //[_beacons removeAllObjects];
    NSArray *unknownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityUnknown]];
     NSLog(@"unknownBeacons count:: %d", unknownBeacons.count);
    
    
    BOOL existing = NO;  
    
    
    if([unknownBeacons count])
    {
        NSUInteger indexNew = 0;
        for(id bcons in unknownBeaconsNew ){
            CLBeacon *beaconExisting = bcons;
            NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
            CLBeacon *beaconNew = [unknownBeacons objectAtIndex:0];
            NSUUID *beaconNewUUID = beaconNew.proximityUUID;
            if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
            {
                existing = YES;
                [unknownBeaconsNew replaceObjectAtIndex:indexNew withObject:beaconNew];
                break;
                
            }
            indexNew++;
        }
        
        if (existing == NO) {
            
            [unknownBeaconsNew addObjectsFromArray:unknownBeacons];
            beaconAdded = [unknownBeacons objectAtIndex:0];
        }

        [_beacons setObject:unknownBeaconsNew forKey:[NSNumber numberWithInt:CLProximityUnknown]];
    }
    
    
    
    
    NSArray *immediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityImmediate]];
   // if([immediateBeacons count])
     //   [_beacons setObject:immediateBeacons forKey:[NSNumber numberWithInt:CLProximityImmediate]];
    
    
    //for(id bcons in immediateBeaconsNew )
    //{
        
        
    //}
    
 
    existing = NO;  

    if([immediateBeacons count])
    {
        NSUInteger indexNew = 0;
        for(id bcons in immediateBeaconsNew ){
            CLBeacon *beaconExisting = bcons;
            NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
            CLBeacon *beaconNew = [immediateBeacons objectAtIndex:0];
            NSUUID *beaconNewUUID = beaconNew.proximityUUID;
            if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
               {
                existing = YES;
                [immediateBeaconsNew replaceObjectAtIndex:indexNew withObject:beaconNew];
                   break;
                
               }
             indexNew++;
        }
        
        if (existing == NO) {
            
            [immediateBeaconsNew addObjectsFromArray:immediateBeacons];
            beaconAdded = [immediateBeacons objectAtIndex:0];
        }
       
        [_beacons setObject:immediateBeaconsNew forKey:[NSNumber numberWithInt:CLProximityImmediate]];
        
    }
    NSLog(@"immediateBeacons count:: %d", immediateBeacons.count);
    
    NSArray *nearBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityNear]];
    
    existing = NO;
    
    if([nearBeacons count])
    {
        NSUInteger indexNew = 0;
        for(id bcons in nearBeaconsNew ){
            CLBeacon *beaconExisting = bcons;
            NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
            CLBeacon *beaconNew = [nearBeacons objectAtIndex:0];
            NSUUID *beaconNewUUID = beaconNew.proximityUUID;
            if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
            {
                existing = YES;
                [nearBeaconsNew replaceObjectAtIndex:indexNew withObject:beaconNew];
                break;
                
            }
            indexNew++;
        }
        
        if (existing == NO) {
            
            [nearBeaconsNew addObjectsFromArray:nearBeacons];
            beaconAdded = [nearBeacons objectAtIndex:0];
        }

        [_beacons setObject:nearBeaconsNew forKey:[NSNumber numberWithInt:CLProximityNear]];
    }
    
    NSLog(@"nearBeacons count:: %d", nearBeacons.count);
        
    NSArray *farBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityFar]];
    
    existing = NO;  
    
    if([farBeacons count])
    {
        NSUInteger indexNew = 0;
        for(id bcons in farBeaconsNew ){
            CLBeacon *beaconExisting = bcons;
            NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
            CLBeacon *beaconNew = [farBeacons objectAtIndex:0];
            NSUUID *beaconNewUUID = beaconNew.proximityUUID;
            if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
            {
                existing = YES;
                [farBeaconsNew replaceObjectAtIndex:indexNew withObject:beaconNew];
                break;
                
            }
            indexNew++;
        }
        
        if (existing == NO) {
            
            [farBeaconsNew addObjectsFromArray:farBeacons];
            beaconAdded = [farBeacons objectAtIndex:0];
        }

        [_beacons setObject:farBeaconsNew forKey:[NSNumber numberWithInt:CLProximityFar]];
    }
    
    NSLog(@"farBeacons count:: %d", farBeacons.count);
    
    if(beaconAdded != NULL)
    {
        NSUInteger indexNew = 0;
        if([immediateBeacons count])
        {
            NSLog(@"immediateBeacons removal para %d", nearBeacons.count);
            for(id bcons in nearBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [immediateBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [nearBeaconsNew removeObjectAtIndex:indexNew];
                    break;
                    
                }
                indexNew++;
            }
            
            indexNew = 0;
            for(id bcons in unknownBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [immediateBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [unknownBeaconsNew removeObjectAtIndex:indexNew];
                    break;
                    
                }
                indexNew++;
            }
            
            indexNew = 0;
            for(id bcons in farBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [immediateBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [farBeaconsNew removeObjectAtIndex:indexNew];
                    break;
                    
                }
                indexNew++;
            }



            
        }
        
        
        
        
        NSUInteger indexNew1 = 0;
        if([nearBeacons count])
        {
            NSLog(@"nearBeacons removal para %d", nearBeacons.count);
            for(id bcons in immediateBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [nearBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [immediateBeaconsNew removeObjectAtIndex:indexNew1];
                    break;
                    
                }
                indexNew1++;
            }
            
            indexNew1 = 0;
            
            for(id bcons in unknownBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [nearBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [unknownBeaconsNew removeObjectAtIndex:indexNew1];
                    break;
                }
                indexNew1++;
            }
            
            indexNew1 = 0;
            
            for(id bcons in farBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [nearBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [farBeaconsNew removeObjectAtIndex:indexNew1];
                    break;
                    
                }
                indexNew1++;
            }


            
            
        }
        
        
        
        NSUInteger indexNew2 = 0;
        if([unknownBeacons count])
        {
            NSLog(@"unknownBeacons removal para %d", nearBeacons.count);
            for(id bcons in immediateBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [unknownBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [immediateBeaconsNew removeObjectAtIndex:indexNew2];
                    break;
                    
                }
                indexNew2++;
            }
            
            indexNew2 = 0;
            
            for(id bcons in nearBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [unknownBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [nearBeaconsNew removeObjectAtIndex:indexNew2];
                    break;
                    
                }
                indexNew2++;
            }
            
            for(id bcons in farBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [unknownBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [farBeaconsNew removeObjectAtIndex:indexNew2];
                    break;
                    
                }
                indexNew2++;
            }
            
        }
        
        
        NSUInteger indexNew3 = 0;
        if([farBeacons count])
        {
            NSLog(@"farBeacons removal para %d", farBeacons.count);
            for(id bcons in immediateBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [farBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [immediateBeaconsNew removeObjectAtIndex:indexNew3];
                    break;
                    
                }
                indexNew3++;
            }
            
            indexNew3 = 0;
            
            for(id bcons in nearBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [farBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [nearBeaconsNew removeObjectAtIndex:indexNew3];
                    break;
                    
                }
                indexNew3++;
            }
            
            indexNew3 = 0;
            
            for(id bcons in unknownBeaconsNew ){
                CLBeacon *beaconExisting = bcons;
                NSUUID *beaconTempUUID = beaconExisting.proximityUUID;
                CLBeacon *beaconNew = [farBeacons objectAtIndex:0];
                NSUUID *beaconNewUUID = beaconNew.proximityUUID;
                if([[beaconNewUUID UUIDString] isEqualToString:[beaconTempUUID UUIDString]])
                {
                    existing = YES;
                    [unknownBeaconsNew removeObjectAtIndex:indexNew3];
                    break;
                    
                }
                indexNew3++;
            }


        }
        
        


    }

    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
     NSLog(@"viewDidAppear");
    // Start ranging when the view appears.
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager startRangingBeaconsInRegion:region];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
     NSLog(@"viewDidDisappear");
    // Stop ranging when the view goes away.
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager stopRangingBeaconsInRegion:region];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    self.title = @"";
    
    
    // Populate the regions we will range once.
    _rangedRegions = [NSMutableArray array];
    [[ALDefaults sharedDefaults].supportedProximityUUIDs enumerateObjectsUsingBlock:^(id uuidObj, NSUInteger uuidIdx, BOOL *uuidStop) {
        
        NSUUID *uuid = (NSUUID *)uuidObj;
        NSLog(@"viewDidLoad :: %@", uuid.UUIDString );
        
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        [_rangedRegions addObject:region];
    }];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(changeSorting) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

}

- (void)changeSorting
{
    [_beacons removeAllObjects];
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView :: %d" , _beacons.count);
   
    return _beacons.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *sectionValues = [_beacons allValues];
    NSLog(@"numberOfRowsInSection:: %d", [[sectionValues objectAtIndex:section] count]);
    NSLog(@"numberOfRowsInSection:: Section:: %d", section);
    return [[sectionValues objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"titleForHeaderInSection ");
    NSString *title = nil;
    NSArray *sectionKeys = [_beacons allKeys];
    
    
    // The table view will display beacons by proximity.
    NSNumber *sectionKey = [sectionKeys objectAtIndex:section];
    
    NSLog(@"titleForHeaderInSection :: section :: %d" , section);
    NSLog(@"titleForHeaderInSection :: sectionKey :: %@" , sectionKey);
    
    switch([sectionKey integerValue])
    {
        case CLProximityImmediate:
            title = @"Immediate";
            break;
            
        case CLProximityNear:
            title = @"Near";
            break;
            
        case CLProximityFar:
            title = @"Far";
            break;
            
        default:
            title = @"Unknown";
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSLog(@"cellForRowAtIndexPath ");
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    // Display the UUID, major, minor and accuracy for each beacon.
    NSNumber *sectionKey = [[_beacons allKeys] objectAtIndex:indexPath.section];
    CLBeacon *beacon = [[_beacons objectForKey:sectionKey] objectAtIndex:indexPath.row];
    
    NSLog(@"cellForRowAtIndexPath :: indexPath Row:: %d" , indexPath.row);
    NSLog(@"cellForRowAtIndexPath :: sectionKey :: %@" , sectionKey);
    
    NSString *merchantLabel = NULL;
        
    if([[beacon.proximityUUID UUIDString]isEqualToString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"])
    {
        merchantLabel = @"Perfume Gallery";
    }
    else if([[beacon.proximityUUID UUIDString]isEqualToString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"])
    {
        merchantLabel = @"As You Wish";
    }
    else if([[beacon.proximityUUID UUIDString]isEqualToString:@"73E9684C-A0A9-E151-4DF6-BEECE13387EF"])
    {
        merchantLabel = @"AZ Custom Tees";
    }
    else if([[beacon.proximityUUID UUIDString]isEqualToString:@"74278BDA-B644-4520-8F0C-720EAF059935"])
    {
        merchantLabel = @"Euro Chic";
    }
    else{
        merchantLabel = @"Perfume Gallery";
    }
    
    NSString *majorString = [beacon.major stringValue];
    NSString *minorString = [beacon.minor stringValue];
    
    NSString *userJson = [self getUserDetails:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0" major:majorString minor:minorString];
    
    NSData *jsonData = [userJson dataUsingEncoding:NSASCIIStringEncoding];
    
    NSDictionary *jsonDict = [[NSDictionary alloc] init];
    NSError *error = nil;
    
    // Parse that data object using NSJSONSerialization without options.
    jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    merchantLabel = [jsonDict valueForKey:@"name"] ;
    
    //cell.textLabel.text = [beacon.proximityUUID UUIDString];
    cell.textLabel.text = merchantLabel;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@, Acc: %.2fm", beacon.major, beacon.minor, beacon.accuracy];
	
    return cell;
}


- (NSString*) getUserDetails:(NSString*) uuid major: (NSString*) major minor: (NSString*) minor {
    
    NSString *userdata = uuid;
    userdata = [userdata stringByAppendingString:@";"];
    userdata = [userdata stringByAppendingString:major];
    userdata = [userdata stringByAppendingString:@";"];
    userdata = [userdata stringByAppendingString:minor];
    
    // NSString *returnGetFBID = [self.getFbidDetails: fbidInput];
    // [self.getFbidDetails: fbidInput];
    
    
    
    
    // NSString *existFbid = @"false";
    NSString *urlString1 = @"http://ibeaconideas.com/servicev2/examples/_006_crud/userinfo?userdata=";
    urlString1 = [urlString1 stringByAppendingString:userdata];
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
    if(!res)
        
    {
        
        NSLog(@"data found");
        
    }
    
    return retVal1;
}




-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSNumber *sectionKey = [[_beacons allKeys] objectAtIndex:indexPath.section];
    CLBeacon *beacon = [[_beacons objectForKey:sectionKey] objectAtIndex:indexPath.row];
    
    NSLog(@"cellForRowAtIndexPath :: indexPath Row:: %d" , indexPath.row);
    NSLog(@"cellForRowAtIndexPath :: sectionKey :: %@" , [beacon.proximityUUID UUIDString]);
    

    
    ViewController *vC = [[ViewController alloc]init];
   //ViewController *vC = [[ViewController alloc]initWithName:uuidVc];
    
    vC.uuid = [ @"UUID:" stringByAppendingString: [beacon.proximityUUID UUIDString] ];
    
    [self.navigationController pushViewController:vC animated:YES];
    
}



@end
