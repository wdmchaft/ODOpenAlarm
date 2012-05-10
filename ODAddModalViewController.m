//
//  ODAddModalViewController.m
//  OpenAlarm
//
//  Created by Pirapa on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ODAddModalViewController.h"
#import "Alarm.h"

@interface ODAddModalViewController ()

@end

@implementation ODAddModalViewController

@synthesize delegate;
@synthesize updateAlarm;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        timeRepeat = [[ODTimeRepeatViewController alloc] init];
        isUpdate = false;
    }
        return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil withAlarm:(Alarm *)alarm bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //updateAlarm = [[Alarm alloc]init];
        // Custom initialization
        timeRepeat = [[ODTimeRepeatViewController alloc] init];
        isUpdate = YES;
        self.updateAlarm = alarm;
        NSLog(@"Alarm update %@ ",updateAlarm);
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    detailNewAlarm.delegate = self;
    detailNewAlarm.dataSource = self;
//    [detailNewAlarm da
    if (isUpdate) {
        datePicker.date = updateAlarm.fireDate;
    }


    UIBarButtonItem *backToCameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backToAlarmListPage)];
    self.navigationItem.LeftBarButtonItem = backToCameraButton;
    UIBarButtonItem *saveToDB = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
    self.navigationItem.rightBarButtonItem = saveToDB;
    

}
- (void)viewWillAppear:(BOOL)animated
{
//    for (int i=0; i<10; i++) {
    NSLog(@"%@", timeRepeat.selectedDayRepeat);
//    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60.0;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UILabel *leftLabel; 
    UILabel *rightLabel;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        
        
        leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
        [cell addSubview:leftLabel];
       
        rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 10, 100, 20)];
        [cell addSubview:rightLabel];

    }
    switch (indexPath.row) {
        case 0:
            leftLabel.text = @"Repeat";
            rightLabel.text = @"Every 2 hour";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            leftLabel.text = @"Sound";
            rightLabel.text = @"Default";
            break;
        case 2:
            leftLabel.text = @"Label";
            rightLabel.text = @"Alarm!";
            break;
        case 3:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            leftLabel.text = @"Alarm Photo";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:timeRepeat animated:YES];
    } else if (indexPath.row == 1) {
        [self.navigationController pushViewController:timeRepeat animated:YES];
    } else if (indexPath.row == 2) {
        [self.navigationController pushViewController:timeRepeat animated:YES];
    }
    
}

- (void)backToAlarmListPage
{
    NSLog(@"close");
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)doneButton{
    if(isUpdate){
        NSLog(@"update");
        [self updateAlarmToDB];
    }else{
        NSLog(@"save");
        [self saveAlarmToDB];
    }
}

- (void)updateAlarmToDB{
    self.updateAlarm.fireDate = datePicker.date;
    [APPDELEGATE saveContext];
    
    [self.delegate addViewController:self didUpdateAlarm:self.updateAlarm];
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)saveAlarmToDB
{
    __block NSMutableString *selectedDayRepeatString = [[NSMutableString alloc] init];
    [timeRepeat.selectedDayRepeat enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
     [selectedDayRepeatString appendString: (NSString *)obj];
    }];
    
    NSEntityDescription    * entity   = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:[APPDELEGATE managedObjectContext]];
    Alarm *newAlarm = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:[APPDELEGATE managedObjectContext]];
    newAlarm.repeatPeriod = selectedDayRepeatString;
    newAlarm.title = @"wake up";
    unsigned int unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar * calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents * components = [calendar components:unitFlags fromDate:datePicker.date];
    components.second = 0;
    NSDate *saveAlarm = [calendar dateFromComponents:components];
    newAlarm.fireDate = datePicker.date;
    //save context
    [APPDELEGATE saveContext];
    NSLog(@"save alarm %@",saveAlarm);
    if (![newAlarm isFault]) {
        [self.delegate addViewController:self didInsertAlarm:(Alarm *)newAlarm];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
