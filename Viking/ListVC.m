//
//  ListVC.m
//  Viking
//
//  Created by macmini08 on 30/01/15.
//  Copyright (c) 2015 Space O Technology. All rights reserved.
//

#import "ListVC.h"
#import "ListCell.h"
#import "LDProgressView.h"
#import <MessageUI/MessageUI.h>
#import "AppConstant.h"
#import "XMLDictionary.h"


@interface ListVC () <MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
{
    AppDelegate *appDel;
    NSMutableArray *indexArray;
    
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL isReset;
@property (nonatomic) BOOL isDeleted;
@property (nonatomic) BOOL isLeftMoved;
@property (nonatomic) BOOL isRightMoved;
@property (nonatomic) BOOL isScrollUp;
@property (nonatomic) BOOL isScrollDown;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray *contentArray;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation ListVC

@synthesize headerStr, activityDict, listArray, isFromCreateTrip, myTripObj, activityListArray, currentIndex, totalIndex;

- (void)viewDidLoad {
    [super viewDidLoad];

    totalCount = 21;
    self.actionView.hidden = YES;
    self.actView.hidden = YES;
    
    self.totalIndex = [self.activityListArray count];
    
    
    self.isOpen = NO;
    self.isReset = NO;
    self.isDeleted = NO;
    self.isScrollUp = NO;
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.headerLbl.font = [UIFont fontWithName:@"ProximaNova-Bold" size:21.0];
    self.activityNameLbl.font = [UIFont fontWithName:@"ProximaNova-Bold" size:21.0];
    self.mainHeaderLbl.font = [UIFont fontWithName:@"ProximaNova-Light" size:18.0];
    
    
    self.BtnAddItem.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:25.0];
    self.BtnDeleteList.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:25.0];
    self.BtnRenameList.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:25.0];
    self.BtnResetList.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:25.0];
   
    self.contentArray = [NSMutableArray new];
    indexArray = [NSMutableArray new];
    
    
    // Build layout
    CCHexagonFlowLayout *layout = [[CCHexagonFlowLayout alloc] init];
    layout.delegate = self;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    if(IS_IPHONE_5)
    {
        layout.minimumInteritemSpacing = -30.0f;
        layout.minimumLineSpacing = 53.0f;
        layout.sectionInset = UIEdgeInsetsMake(2.0f, 0.0f, 20.0f, 15.0f);
        layout.gap = 20.0f;
        layout.minimumInteritemSpacing = -38.0f;
        layout.gap = 69.0f;
        layout.itemSize = RootCell_SIZE_FOR_5;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.headerBGView.frame.size.height + 15, self.view.frame.size.width, 295) collectionViewLayout:layout];
    }
    else if(IS_IPHONE_6P)
    {
        layout.minimumLineSpacing = 80.0f;
        layout.sectionInset = UIEdgeInsetsMake(2.0f, 0.0f, 20.0f, 15.0f);
        layout.minimumInteritemSpacing = -38.0f;
        layout.itemSize = RootCell_SIZE_FOR_6P;
        layout.gap = 90.0f;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.headerBGView.frame.size.height + 15, self.view.frame.size.width, 343) collectionViewLayout:layout];
    }
    else
    {
        layout.minimumLineSpacing = 60.0f;
        layout.sectionInset = UIEdgeInsetsMake(2.0f, 0.0f, 20.0f, 15.0f);
        layout.minimumInteritemSpacing = -42.0f;
        layout.itemSize = RootCell_SIZE_FOR_6;
        layout.gap = 78.0f;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.headerBGView.frame.size.height + 15, self.view.frame.size.width, 413) collectionViewLayout:layout];
    }
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.scrollEnabled = YES;
    _collectionView.clipsToBounds = YES;
    
    // Register cell and views
    [_collectionView registerNib:[ListCell cellNib] forCellWithReuseIdentifier:RootCell_ID];
//    [self.collectionListsView addSubview:_collectionView];
    [self.scrlView addSubview:_collectionView];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
//        [self.collectionView.collectionViewLayout invalidateLayout];
    });
    
    [self.collectionListsView bringSubviewToFront:self.actionView];

    
    listArray = [self fetchEquipmentList:currentIndex];    
    [self.collectionView reloadData];
    [self setUpheader];
    
//     NSLog(@"content size - %@", NSStringFromCGSize(self.collectionView.contentMode)) ;
        self.scrlView.contentSize = CGSizeMake(self.view.frame.size.width, self.collectionView.contentSize.height + self.headerView.frame.size.height);
    
     self.scrlView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    
}

-(void)setUpheader
{
    if(isFromCreateTrip)
    {
        self.BtnLeft.hidden = YES;
        self.BtnRight.hidden = YES;
        self.rightImgView.hidden = YES;
        self.leftImgView.hidden = YES;
        
        self.headerBGView.image = [UIImage imageNamed:[NSString stringWithFormat:@"BG_%@_%@", activityDict[@"main_Activity"],activityDict[@"ActivityTitle"]]];
        
        self.headerLbl.text = [NSString stringWithFormat:@"%@ %@", activityDict[@"ActivityTitle"], activityDict[@"main_Activity"]];
        self.activityNameLbl.text = [activityDict[@"activityListname"] capitalizedString];
        UIImage *activityImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon-%@-%@", activityDict[@"main_Activity"], activityDict[@"ActivityTitle"]]];
        UIImage *durationImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", activityDict[@"DurationTitle"]]];
        UIImage *tempImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", activityDict[@"TempTitle"]]];
        
        NSString *durationStr;
        if([activityDict[@"DurationTitle"] isEqualToString:@"1 Day"])
            durationStr = @"Raid";
        else if ([activityDict[@"DurationTitle"] isEqualToString:@"2 Days"])
            durationStr = @"Journey";
        else if ([activityDict[@"DurationTitle"] isEqualToString:@"3+ Days"])
            durationStr = @"Expedition";
        
        [self createSelectionView:activityImage durationImg:durationImage tempImg:tempImage activityName:activityDict[@"ActivityTitle"] durationName:durationStr tempName:activityDict[@"TempTitle"] inView:self.collectionListsView];
    }
    else
    {
        self.BtnLeft.hidden = NO;
        self.BtnRight.hidden = NO;
        self.rightImgView.hidden = NO;
        self.leftImgView.hidden = NO;

        self.headerBGView.image = [UIImage imageNamed:[NSString stringWithFormat:@"BG_%@_%@", [myTripObj valueForKey:@"main_Activity"],[myTripObj valueForKey:@"sub_activity"]]];
        
        self.headerLbl.text = [NSString stringWithFormat:@"%@ %@", [myTripObj valueForKey:@"sub_activity"], [myTripObj valueForKey:@"main_Activity"]];
        self.activityNameLbl.text = [[myTripObj valueForKey:@"activityList_Name"] capitalizedString];
        
        UIImage *activityImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon-%@-%@", [myTripObj valueForKey:@"main_Activity"], [myTripObj valueForKey:@"sub_activity"]]];
        UIImage *durationImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [myTripObj valueForKey:@"duration"]]];
        UIImage *tempImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [myTripObj valueForKey:@"temperature"]]];
        
        NSString *durationStr;
        if([[myTripObj valueForKey:@"duration"] isEqualToString:@"1 Day"])
            durationStr = @"Raid";
        else if ([[myTripObj valueForKey:@"duration"] isEqualToString:@"2 Days"])
            durationStr = @"Journey";
        else if ([[myTripObj valueForKey:@"duration"] isEqualToString:@"3+ Days"])
            durationStr = @"Expedition";
        
        [self createSelectionView:activityImage durationImg:durationImage tempImg:tempImage activityName:[myTripObj valueForKey:@"sub_activity"] durationName:durationStr  tempName:[myTripObj valueForKey:@"temperature"] inView:self.collectionListsView];
    }
    
    [self calculatePercentageAndUpdate];
}

-(void)calculatePercentageAndUpdate
{
    float totalItems = [listArray count];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.returnsObjectsAsFaults = NO;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyActivityEquipmentList" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate;
    
    if(isFromCreateTrip)
    {
        predicate = [NSPredicate predicateWithFormat:@"activityList_Name=%@ AND duration=%@ AND main_Activity=%@ AND sub_activity=%@ AND temperature=%@ AND image=%@", activityDict[@"activityListname"],activityDict[@"DurationTitle"], activityDict[@"main_Activity"], activityDict[@"ActivityTitle"], activityDict[@"TempTitle"],@"hexa_gray"];
    }
    else
    {
        myTripObj = [self.activityListArray objectAtIndex:currentIndex];
        
        predicate = [NSPredicate predicateWithFormat:@"activityList_Name=%@ AND duration=%@ AND main_Activity=%@ AND sub_activity=%@ AND temperature=%@ AND image=%@", [myTripObj valueForKey:@"activityList_Name"],[myTripObj valueForKey:@"duration"], [myTripObj valueForKey:@"main_Activity"], [myTripObj valueForKey:@"sub_activity"], [myTripObj valueForKey:@"temperature"], @"hexa_gray"];
    }
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    float packedCount = [fetchedObjects count];
    NSLog(@"percentage - %f", packedCount/totalItems);
    
    LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(0, self.selectionView.frame.size.height, self.view.frame.size.width, 15)];
    progressView.progress = packedCount/totalItems;
    progressView.borderRadius = @0;
    progressView.animate = @NO;
    progressView.type = LDProgressSolid;
    progressView.color = [UIColor colorWithRed:66.0/255.0 green:81.0/255.0 blue:92.0/255.0 alpha:1.0];
    progressView.background = [UIColor colorWithRed:231.0/255.0 green:220.0/255.0 blue:69.0/255.0 alpha:1.0];
    [self.collectionListsView addSubview:progressView];
}


#pragma mark - Core Data


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *managedcontext = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        managedcontext = [delegate managedObjectContext];
    }
    return managedcontext;
}

-(NSArray *)fetchEquipmentList:(NSInteger)fromIndex
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (context == nil) {
        NSLog(@"Nil");
        return nil;
    }
    else {
        
        NSLog(@"dict - %@", activityDict);
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.returnsObjectsAsFaults = NO;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyActivityEquipmentList" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate;
        
        if(isFromCreateTrip)
        {
             predicate = [NSPredicate predicateWithFormat:@"activityList_Name=%@ AND duration=%@ AND main_Activity=%@ AND sub_activity=%@ AND temperature=%@", activityDict[@"activityListname"],activityDict[@"DurationTitle"], activityDict[@"main_Activity"], activityDict[@"ActivityTitle"], activityDict[@"TempTitle"]];
        }
        else
        {
            myTripObj = [self.activityListArray objectAtIndex:fromIndex];
            
            predicate = [NSPredicate predicateWithFormat:@"activityList_Name=%@ AND duration=%@ AND main_Activity=%@ AND sub_activity=%@ AND temperature=%@", [myTripObj valueForKey:@"activityList_Name"],[myTripObj valueForKey:@"duration"], [myTripObj valueForKey:@"main_Activity"], [myTripObj valueForKey:@"sub_activity"], [myTripObj valueForKey:@"temperature"]];
        }
        [fetchRequest setPredicate:predicate];
        
        
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        return fetchedObjects;
    }
    
}

-(NSArray *)fetchMyActivityList
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (context == nil) {
        NSLog(@"Nil");
        return nil;
    }
    else {

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.returnsObjectsAsFaults = NO;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyActivityList" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate;
        
        if(isFromCreateTrip)
        {
            predicate = [NSPredicate predicateWithFormat:@"activityList_Name=%@ AND duration=%@ AND main_Activity=%@ AND sub_activity=%@ AND temperature=%@", activityDict[@"activityListname"],activityDict[@"DurationTitle"], activityDict[@"main_Activity"], activityDict[@"ActivityTitle"], activityDict[@"TempTitle"]];
        }
        else
            predicate = [NSPredicate predicateWithFormat:@"activityList_Name=%@ AND duration=%@ AND main_Activity=%@ AND sub_activity=%@ AND temperature=%@", [myTripObj valueForKey:@"activityList_Name"],[myTripObj valueForKey:@"duration"], [myTripObj valueForKey:@"main_Activity"], [myTripObj valueForKey:@"sub_activity"], [myTripObj valueForKey:@"temperature"]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        return fetchedObjects;
    }
}


-(void)createSelectionView:(UIImage *)activityImage durationImg:(UIImage *)durationImage tempImg:(UIImage *)tempImage activityName:(NSString *)activityStr durationName:(NSString *)durationStr tempName:(NSString *)tempStr inView:(UIView *)view
{
    
    if(self.selectionView)
    {
        [self.selectionView removeFromSuperview];
    }
    
    self.selectionView = [[UIView alloc] init];
    
    
    float barHeight;
    if(IS_IPHONE_6P)
        barHeight = 59.0;
    else if (IS_IPHONE_5)
        barHeight = 39.0;
    else
        barHeight = 39.0;
    
    self.selectionView.frame = CGRectMake(self.view.bounds.origin.x,0, self.view.bounds.size.width, barHeight);
    
    
    self.selectionView.backgroundColor = [UIColor clearColor];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.selectionView.frame.size.width, self.selectionView.frame.size.height)];
    [img setImage:[UIImage imageNamed:@"blur_strip"]];
    [self.selectionView addSubview:img];
    
    UIImageView *activityImg;
    UIImageView *durImg;
    UIImageView *tempImg;
    UILabel *activityLbl;
    UILabel *durationLbl;
    UILabel *tempLbl;
    UILabel *deviderLbl;
    UILabel *deviderLbl2;
    
    if(IS_IPHONE_5)
        activityImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 20, 20)];
    else if(IS_IPHONE_6P)
        activityImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15, 30, 30)];
    else if (IS_IPHONE_4_OR_LESS)
        activityImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 9, 20, 20)]; //Vikita
    else
        activityImg = [[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 20, 20)];
    
    activityImg.image = activityImage;
    activityImg.contentMode = UIViewContentModeScaleAspectFill;
    [self.selectionView addSubview:activityImg];
    
    
    if(IS_IPHONE_5)
    {
        activityLbl = [[UILabel alloc] initWithFrame:CGRectMake(36, 9, 71, 21)];
        activityLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];
    }
    else if(IS_IPHONE_6P)
    {
        activityLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 90, 40)];
        activityLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:15.0];
        activityLbl.backgroundColor = [UIColor clearColor];
        
    }else if (IS_IPHONE_4_OR_LESS){  //Vikita
        activityLbl = [[UILabel alloc] initWithFrame:CGRectMake(30, 9, 71, 21)];
        activityLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];
        
    }
    else
    {
        activityLbl = [[UILabel alloc] initWithFrame:CGRectMake(42, 9, 71, 21)];
        activityLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];
    }
    activityLbl.text = [activityStr uppercaseString];
    activityLbl.numberOfLines = 0;
    activityLbl.textColor = [UIColor whiteColor];
    activityLbl.textAlignment = NSTextAlignmentCenter;
    [self.selectionView addSubview:activityLbl];
    
    
    
    if(IS_IPHONE_5)
        durImg = [[UIImageView alloc] initWithFrame:CGRectMake(120, 10, 20, 17)];
    else if(IS_IPHONE_6P)
        durImg = [[UIImageView alloc] initWithFrame:CGRectMake(144, 20, 26, 21)];
    else if (IS_IPHONE_4_OR_LESS) //Vikita
        durImg = [[UIImageView alloc] initWithFrame:CGRectMake(114,12,15,15)];
    else
        durImg = [[UIImageView alloc] initWithFrame:CGRectMake(136, 10, 20, 17)];
    durImg.image = durationImage;
    durImg.contentMode = UIViewContentModeScaleAspectFill;
    [self.selectionView addSubview:durImg];
    
    
    
    if(IS_IPHONE_5)
    {
        durationLbl = [[UILabel alloc] initWithFrame:CGRectMake(149, 9, 73, 21)];
        durationLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];
    }
    else if(IS_IPHONE_6P)
    {
        durationLbl = [[UILabel alloc] initWithFrame:CGRectMake(175, 12, 90, 40)];
        durationLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:15.0];
        durationLbl.backgroundColor = [UIColor clearColor];
    }else if (IS_IPHONE_4_OR_LESS){ //Vikita
        durationLbl = [[UILabel alloc] initWithFrame:CGRectMake(136, 9, 71, 21)];
        durationLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];
    }
    else
    {
        durationLbl = [[UILabel alloc] initWithFrame:CGRectMake(165, 9, 73, 21)];
        durationLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];
    }
    durationLbl.text = [durationStr uppercaseString];
    durationLbl.textAlignment = NSTextAlignmentCenter;
    durationLbl.textColor = [UIColor whiteColor];
    [self.selectionView addSubview:durationLbl];
    
    
    if(IS_IPHONE_5)
        tempImg = [[UIImageView alloc] initWithFrame:CGRectMake(250, 10, 8, 20)];
    else if(IS_IPHONE_6P)
        tempImg = [[UIImageView alloc] initWithFrame:CGRectMake(284, 15, 26, 26)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
        
        tempImg = [[UIImageView alloc] initWithFrame:CGRectMake(224, 10, 10, 15)];
    else
        tempImg = [[UIImageView alloc] initWithFrame:CGRectMake(277, 10, 8, 20)];
    tempImg.image = tempImage;
    tempImg.contentMode = UIViewContentModeScaleAspectFill;
    [self.selectionView addSubview:tempImg];
    
    
    
    if(IS_IPHONE_5)
    {
        tempLbl = [[UILabel alloc] initWithFrame:CGRectMake(271, 9, 41, 21)];
        tempLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];
    }
    else if(IS_IPHONE_6P)
    {
        tempLbl = [[UILabel alloc] initWithFrame:CGRectMake(315, 12, 90, 40)];
        tempLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:15.0];
        tempLbl.backgroundColor = [UIColor redColor];
    }else if (IS_IPHONE_4_OR_LESS){//Vikita
        tempLbl = [[UILabel alloc] initWithFrame:CGRectMake(242, 9, 71, 21)];
        tempLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];}
    else
    {
        tempLbl = [[UILabel alloc] initWithFrame:CGRectMake(308, 9, 41, 21)];
        tempLbl.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12.0];
    }
    tempLbl.backgroundColor = [UIColor clearColor];
    tempLbl.text = [tempStr uppercaseString];
    tempLbl.textAlignment = NSTextAlignmentCenter;
    tempLbl.textColor = [UIColor whiteColor];
    
    [self.selectionView addSubview:tempLbl];
    
    if(IS_IPHONE_5)
        deviderLbl = [[UILabel alloc] initWithFrame:CGRectMake(108, 4, 1, 32)];
    else if (IS_IPHONE_6P)
        deviderLbl = [[UILabel alloc] initWithFrame:CGRectMake(137, 4, 1, barHeight-8)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
        deviderLbl = [[UILabel alloc] initWithFrame:CGRectMake(106, 4, 1, 32)];
    else
        deviderLbl = [[UILabel alloc] initWithFrame:CGRectMake(124, 4, 1, 32)];
    
    deviderLbl.backgroundColor = [UIColor colorWithRed:142.0/255.0 green:141.0/255.0 blue:145.0/255.0 alpha:1.0];
    [self.selectionView addSubview:deviderLbl];
    
    if(IS_IPHONE_5)
        deviderLbl2 = [[UILabel alloc] initWithFrame:CGRectMake(233, 4, 1, 32)];
    else if (IS_IPHONE_6P)
        deviderLbl2 = [[UILabel alloc] initWithFrame:CGRectMake(276, 4, 1, barHeight-8)];
    else  if (IS_IPHONE_4_OR_LESS)//Vikita
        deviderLbl2 = [[UILabel alloc] initWithFrame:CGRectMake(212, 4, 1, 32)]; //Vikita
    else
        deviderLbl2 = [[UILabel alloc] initWithFrame:CGRectMake(249, 4, 1, 32)];
    
    deviderLbl2.backgroundColor = [UIColor colorWithRed:142.0/255.0 green:141.0/255.0 blue:145.0/255.0 alpha:1.0];
    [self.selectionView addSubview:deviderLbl2];
    
    [view addSubview:self.selectionView];

}


-(IBAction)clickAdd:(id)sender
{
    [self SwipeDown:self.menuView];
    self.menuView.hidden = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Equipment Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] ;
    alertView.tag = 1001;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 1001)
    {
        if(buttonIndex == 1)
        {
            UITextField * alertTextField = [alertView textFieldAtIndex:0];
            NSLog(@"alerttextfiled - %@",alertTextField.text);
            
            NSManagedObjectContext *context = [self managedObjectContext];
            NSManagedObject *newActivityList = [NSEntityDescription insertNewObjectForEntityForName:@"MyActivityEquipmentList" inManagedObjectContext:context];
            if(isFromCreateTrip)
            {
                [newActivityList setValue:activityDict[@"activityListname"] forKey:@"activityList_Name"];
                [newActivityList setValue:activityDict[@"DurationTitle"] forKey:@"duration"];
                [newActivityList setValue:activityDict[@"main_Activity"] forKey:@"main_Activity"];
                [newActivityList setValue:activityDict[@"ActivityTitle"] forKey:@"sub_activity"];
                [newActivityList setValue:activityDict[@"TempTitle"] forKey:@"temperature"];
                
            }
            else
            {
                [newActivityList setValue:[myTripObj valueForKey:@"activityList_Name"] forKey:@"activityList_Name"];
                [newActivityList setValue:[myTripObj valueForKey:@"duration"] forKey:@"duration"];
                [newActivityList setValue:[myTripObj valueForKey:@"main_Activity"] forKey:@"main_Activity"];
                [newActivityList setValue:[myTripObj valueForKey:@"sub_activity"] forKey:@"sub_activity"];
                [newActivityList setValue:[myTripObj valueForKey:@"temperature"] forKey:@"temperature"];
            }
            [newActivityList setValue:alertTextField.text forKey:@"equipment"];
            [newActivityList setValue:@"hexa_orange" forKey:@"image"];
            
            NSError *error1 = nil;
            if (![context save:&error1]) {
                NSLog(@"Can't Save! %@ %@", error1, [error1 localizedDescription]);
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
            listArray = [self fetchEquipmentList:currentIndex];
            [self.collectionView reloadData];
        }
    }
    else if (alertView.tag == 2001)
    {
        if(buttonIndex == 1)
        {
            UITextField * alertTextField = [alertView textFieldAtIndex:0];
//            alertTextField.text = @"ABC";
            if([alertTextField.text length]>0)
                self.activityNameLbl.text = [alertTextField.text capitalizedString];
            
            NSArray *listArr = [self fetchEquipmentList:currentIndex];
            
            NSManagedObjectContext *context = [self managedObjectContext];
            for(NSManagedObject *obj in listArr)
            {
                [obj setValue:alertTextField.text forKey:@"activityList_Name"];
                
                NSError *error1 = nil;
                // Save the object to persistent store
                if (![context save:&error1]) {
                    NSLog(@"Can't Save! %@ %@", error1, [error1 localizedDescription]);
                }
            }
            
            NSArray *myListArr = [self fetchMyActivityList];
            
            for(NSManagedObject *obj in myListArr)
            {
                [obj setValue:alertTextField.text forKey:@"activityList_Name"];
                
                NSError *error1 = nil;
                // Save the object to persistent store
                if (![context save:&error1]) {
                    NSLog(@"Can't Save! %@ %@", error1, [error1 localizedDescription]);
                }
            }

        }
    }
    else if(alertView.tag == 3001)
    {
        if(buttonIndex == 1)
        {
            self.isDeleted = YES;
            
            [self SwipeDown:self.actView];
            self.actView.hidden = YES;
            self.isOpen = NO;

            NSLog(@"arr count before- %lu", (unsigned long)[self.listArray count]);
            
            NSManagedObjectContext *context = [self managedObjectContext];
            
            for(NSManagedObject *obj in indexArray)
            {
                [context deleteObject:obj];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            [indexArray removeAllObjects];
            listArray = [self fetchEquipmentList:currentIndex];
            [self.collectionView reloadData];
            
            [self calculatePercentageAndUpdate];
        }
    }
    else if (alertView.tag == 4001)
    {
        if(buttonIndex ==1)
        {
            
            NSManagedObjectContext *context = [self managedObjectContext];
            
            NSArray *listArr = [self fetchEquipmentList:currentIndex];
            for(NSManagedObject *obj in listArr)
            {
//                [context deleteObject:obj];
                [obj setValue:@"hexa_orange" forKey:@"image"];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            
            [self.collectionView reloadData];
            [self calculatePercentageAndUpdate];
            
        self.isReset = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
    }
    else if(alertView.tag == 5001)
    {
        if(buttonIndex ==1)
        {
            NSManagedObjectContext *context = [self managedObjectContext];
            
            NSArray *listArr = [self fetchEquipmentList:currentIndex];
            for(NSManagedObject *obj in listArr)
            {
                [context deleteObject:obj];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            
            NSArray *myListArr = [self fetchMyActivityList];
            for(NSManagedObject *obj in myListArr)
            {
                [context deleteObject:obj];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            if(isFromCreateTrip)
                [self.navigationController popToRootViewControllerAnimated:YES];
            else
                [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UICollectionDataSource methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return totalCount;
//    return [self.contentArray count];
    return [listArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RootCell_ID forIndexPath:indexPath];
    NSManagedObject *obj = listArray[indexPath.row];
    
    cell.titleLabel.text = [[obj valueForKey:@"equipment"] uppercaseString];
    cell.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:10.0];
    
    if(IS_IPHONE_6P)
        cell.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:13.0];
    else if (IS_IPHONE_5 || IS_IPHONE_6)
        cell.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:10.0];
    
    cell.hexImege.image = [UIImage imageNamed:[obj valueForKey:@"image"]];
    
    if([[obj valueForKey:@"image"] isEqualToString:@"hexa_gray"])
    {
        cell.titleLabel.textColor = [UIColor colorWithRed:123.0/255.0 green:137.0/255.0 blue:149.0/255.0 alpha:1.0];
    }
    else
    {
        cell.titleLabel.textColor = [UIColor colorWithRed:70.0/255.0 green:82.0/255.0 blue:94.0/255.0 alpha:1.0];
    }
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListCell *cell = (ListCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.hexImege.image = [UIImage imageNamed:@"hexa_turkis"];
    cell.titleLabel.textColor = [UIColor colorWithRed:206.0/255.0 green:250.0/255.0 blue:246.0/255.0 alpha:1.0];
    
    [self SwipeDown:self.menuView];
    self.menuView.hidden = YES;
    
    if(![indexArray containsObject:listArray[indexPath.row]])
    {
//        [indexArray addObject:indexPath];
        [indexArray addObject:listArray[indexPath.row]];
        self.actView.hidden = NO;
        CGRect actionViewRect;
        if(IS_IPHONE_6P)
            actionViewRect = CGRectMake(0, self.view.frame.size.height - 101, self.view.frame.size.width, 101);
        else
            actionViewRect = CGRectMake(0, self.view.frame.size.height - 70, self.view.frame.size.width, 70);
        [self createActionView:actionViewRect];
    }
    else
    {
        [indexArray removeObject:listArray[indexPath.row]];
        NSManagedObject *obj = listArray[indexPath.row];
        
        cell.hexImege.image = [UIImage imageNamed:[obj valueForKey:@"image"]];
        cell.titleLabel.text = [[obj valueForKey:@"equipment"] uppercaseString];
        NSLog(@"txt - %@", cell.titleLabel.text);
        if([[obj valueForKey:@"image"] isEqualToString:@"hexa_gray"])
        {
            cell.titleLabel.textColor = [UIColor colorWithRed:123.0/255.0 green:137.0/255.0 blue:149.0/255.0 alpha:1.0];
        }
        else
        {
            cell.titleLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:84.0/255.0 blue:99.0/255.0 alpha:1.0];
        }
        if(indexArray.count == 0)
        {
            self.actView.hidden = YES;
        }
        else
        {
            self.actView.hidden = NO;
            CGRect actionViewRect;
            if(IS_IPHONE_6P)
                actionViewRect = CGRectMake(0, self.view.frame.size.height - 101, self.view.frame.size.width, 101);
            else
                actionViewRect = CGRectMake(0, self.view.frame.size.height - 70, self.view.frame.size.width, 70);

            [self createActionView:actionViewRect];
        }
    }
    
    
    
//    CGRect actionViewRect = CGRectMake(0, self.view.frame.size.height - 70, self.view.frame.size.width, 70);
//    [self createActionView:actionViewRect];
    

    self.isReset = NO;
    self.isDeleted = NO;
    self.selectedIndexPath = indexPath;

    NSLog(@"selected index - %ld", (long)indexPath.row);
    NSLog(@"selected indexes - %@", indexArray);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yVelocity = [scrollView.panGestureRecognizer velocityInView:scrollView].y;
    if (yVelocity < 0)
    {
//               self.scrlView.contentOffset = CGPointMake(self.view.frame.origin.x, -yVelocity);
        
        NSLog(@"Up");
        self.isScrollUp = YES;
        
        self.collectionView.scrollEnabled = YES;
        self.actView.hidden = YES;
        
        NSLog(@"content size - %@", NSStringFromCGSize(self.collectionView.contentSize));
        self.scrlView.contentSize = CGSizeMake(self.view.frame.size.width, self.collectionView.contentSize.height + self.headerView.frame.size.height+70);
        
        NSLog(@"self.scrlView content size - %@", NSStringFromCGSize(self.scrlView.contentSize));
        
        CGRect collectionlistViewFrame = self.collectionListsView.frame;
        collectionlistViewFrame.size.height = self.scrlView.contentSize.height;
//        _collectionListsView.frame = collectionlistViewFrame;
//        self.collectionListsView.frame = CGRectMake(0, 318, 414, 1484);
//        self.collectionListsView.backgroundColor = [UIColor greenColor];
//        self.view.frame = collectionlistViewFrame;

        
        CGRect collRect = self.collectionView.frame;
        collRect.size.height = self.scrlView.contentSize.height;
        self.collectionView.frame = collRect;
        self.collectionView.backgroundColor = [UIColor clearColor];
        
        NSLog(@"coll view size - %@", NSStringFromCGRect(self.collectionView.frame));
        NSLog(@"coll list view size - %@", NSStringFromCGRect(self.collectionListsView.frame));
    }
    else
    {
        self.isScrollUp = NO;
        NSLog(@"Down");
    }

}

-(void)createActionView:(CGRect)viewFrame
{
    if(self.actView)
        [self.actView removeFromSuperview];
    
    if(IS_IPHONE_6P)
        viewFrame.size.height = 101;
    self.actView = [[UIView alloc] initWithFrame:viewFrame];
    self.actView.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
    bgImage.image = [UIImage imageNamed:@"black_bg"];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add the effect view to the image view
    [bgImage addSubview:effectView];
    
    [self.actView addSubview:bgImage];
    
    UIImageView *unpackedImg;
    UIImageView *packedImg;
    UIImageView *needImg;
    UIImageView *deleteImg;
    UILabel *lblDevier1;
    UILabel *lblDevier2;
    UILabel *lblDevier3;
    UILabel *lblUnPacked;
    UILabel *lblPacked;
    UILabel *lblNeed;
    UILabel *lblDelete;
    UIButton *btnUnpacked;
    UIButton *btnPacked;
    UIButton *btnNeed;
    UIButton *btnDelete;
    
    if(IS_IPHONE_5)
        unpackedImg = [[UIImageView alloc] initWithFrame:CGRectMake(27, 11, 25, 21)];
    else if (IS_IPHONE_6P)
        unpackedImg = [[UIImageView alloc] initWithFrame:CGRectMake(36, 28, 25, 25)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
        unpackedImg = [[UIImageView alloc] initWithFrame:CGRectMake(27, 11, 25, 21)];
    else
        unpackedImg = [[UIImageView alloc] initWithFrame:CGRectMake(34, 11, 25, 21)];
    unpackedImg.image = [UIImage imageNamed:@"Unpacked"];
    [self.actView addSubview:unpackedImg];
    
    if(IS_IPHONE_5)
        packedImg = [[UIImageView alloc] initWithFrame:CGRectMake(107, 11, 25, 21)];
    else if (IS_IPHONE_6P)
        packedImg = [[UIImageView alloc] initWithFrame:CGRectMake(145, 28, 25, 25)];
    else if (IS_IPHONE_4_OR_LESS)//vikita
        packedImg = [[UIImageView alloc] initWithFrame:CGRectMake(107, 11, 25, 21)];
    else
        packedImg = [[UIImageView alloc] initWithFrame:CGRectMake(127, 11, 25, 21)];
    packedImg.image = [UIImage imageNamed:@"Packed"];
    [self.actView addSubview:packedImg];
    
    if(IS_IPHONE_5)
        needImg = [[UIImageView alloc] initWithFrame:CGRectMake(190, 11, 25, 21)];
    else if (IS_IPHONE_6P)
        needImg = [[UIImageView alloc] initWithFrame:CGRectMake(250, 28, 25, 21)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
         needImg = [[UIImageView alloc] initWithFrame:CGRectMake(190, 11, 25, 21)];
    else
        needImg = [[UIImageView alloc] initWithFrame:CGRectMake(221, 11, 25, 21)];
    needImg.image = [UIImage imageNamed:@"Need"];
    [self.actView addSubview:needImg];
    
    if(IS_IPHONE_5)
        deleteImg = [[UIImageView alloc] initWithFrame:CGRectMake(270, 11, 25, 21)];
    else if (IS_IPHONE_6P)
        deleteImg = [[UIImageView alloc] initWithFrame:CGRectMake(353, 28, 25, 21)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
          deleteImg = [[UIImageView alloc] initWithFrame:CGRectMake(270, 11, 25, 21)];
    else
        deleteImg = [[UIImageView alloc] initWithFrame:CGRectMake(316, 11, 25, 21)];
    deleteImg.image = [UIImage imageNamed:@"Trash"];
    [self.actView addSubview:deleteImg];
    
    if(IS_IPHONE_5)
        lblDevier1 = [[UILabel alloc] initWithFrame:CGRectMake(80, 8, 1, 54)];
    else if (IS_IPHONE_6P)
        lblDevier1 = [[UILabel alloc] initWithFrame:CGRectMake(103, 24, 1, 54)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
        lblDevier1 = [[UILabel alloc] initWithFrame:CGRectMake(80, 8, 1, 54)];

    else
        lblDevier1 = [[UILabel alloc] initWithFrame:CGRectMake(92, 8, 1, 54)];
    [lblDevier1 setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:106.0/255.0 blue:111.0/255.0 alpha:1.0]];
    [self.actView addSubview:lblDevier1];
    
    if(IS_IPHONE_5)
        lblDevier2 = [[UILabel alloc] initWithFrame:CGRectMake(160, 8, 1, 54)];
    else if (IS_IPHONE_6P)
        lblDevier2 = [[UILabel alloc] initWithFrame:CGRectMake(207, 24, 1, 54)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
         lblDevier2 = [[UILabel alloc] initWithFrame:CGRectMake(160, 8, 1, 54)];
    else
        lblDevier2 = [[UILabel alloc] initWithFrame:CGRectMake(186, 8, 1, 54)];
    [lblDevier2 setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:106.0/255.0 blue:111.0/255.0 alpha:1.0]];
    [self.actView addSubview:lblDevier2];
    
    if(IS_IPHONE_5)
        lblDevier3 = [[UILabel alloc] initWithFrame:CGRectMake(240, 8, 1, 54)];
    else if (IS_IPHONE_6P)
        lblDevier3 = [[UILabel alloc] initWithFrame:CGRectMake(311, 24, 1, 54)];
    else if (IS_IPHONE_4_OR_LESS)
        lblDevier3 = [[UILabel alloc] initWithFrame:CGRectMake(240, 8, 1, 54)];
    else
        lblDevier3 = [[UILabel alloc] initWithFrame:CGRectMake(281, 8, 1, 54)];
    [lblDevier3 setBackgroundColor:[UIColor colorWithRed:103.0/255.0 green:106.0/255.0 blue:111.0/255.0 alpha:1.0]];
    [self.actView addSubview:lblDevier3];
    
    if(IS_IPHONE_5)
        lblUnPacked = [[UILabel alloc] initWithFrame:CGRectMake(7, 37, 64, 21)];
    else if (IS_IPHONE_6P)
        lblUnPacked = [[UILabel alloc] initWithFrame:CGRectMake(16, 56, 64, 21)];
    else if (IS_IPHONE_4_OR_LESS)
         lblUnPacked = [[UILabel alloc] initWithFrame:CGRectMake(7, 37, 64, 21)];
    else
        lblUnPacked = [[UILabel alloc] initWithFrame:CGRectMake(14, 37, 64, 21)];
    lblUnPacked.text = @"Unpacked";
    lblUnPacked.textAlignment = NSTextAlignmentCenter;
    lblUnPacked.textColor = [UIColor whiteColor];
    lblUnPacked.font = [UIFont fontWithName:@"ProximaNova-Regular" size:13.0];
    [self.actView addSubview:lblUnPacked];
    
    if(IS_IPHONE_5)
        lblPacked = [[UILabel alloc] initWithFrame:CGRectMake(93, 37, 52, 21)];
    else if (IS_IPHONE_6P)
        lblPacked = [[UILabel alloc] initWithFrame:CGRectMake(131, 56, 52, 21)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
        lblPacked = [[UILabel alloc] initWithFrame:CGRectMake(93, 37, 52, 21)];
    else
        lblPacked = [[UILabel alloc] initWithFrame:CGRectMake(113, 37, 52, 21)];
    lblPacked.text = @"Packed";
    lblPacked.textAlignment = NSTextAlignmentCenter;
    lblPacked.textColor = [UIColor whiteColor];
    lblPacked.font = [UIFont fontWithName:@"ProximaNova-Regular" size:13.0];
    [self.actView addSubview:lblPacked];
    
    
    if(IS_IPHONE_5)
        lblNeed = [[UILabel alloc] initWithFrame:CGRectMake(185, 37, 34, 21)];
    else if (IS_IPHONE_6P)
        lblNeed = [[UILabel alloc] initWithFrame:CGRectMake(245, 56, 34, 21)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
        lblNeed = [[UILabel alloc] initWithFrame:CGRectMake(185, 37, 34, 21)];
    else
        lblNeed = [[UILabel alloc] initWithFrame:CGRectMake(216, 37, 34, 21)];
    lblNeed.text = @"Need";
    lblNeed.textColor = [UIColor whiteColor];
    lblNeed.textAlignment = NSTextAlignmentCenter;
    lblNeed.font = [UIFont fontWithName:@"ProximaNova-Regular" size:13.0];
    [self.actView addSubview:lblNeed];
    
    if(IS_IPHONE_5)
        lblDelete = [[UILabel alloc] initWithFrame:CGRectMake(261, 37, 43, 21)];
    else if (IS_IPHONE_6P)
        lblDelete = [[UILabel alloc] initWithFrame:CGRectMake(344, 56, 43, 21)];
    else if (IS_IPHONE_4_OR_LESS)//Vikita
         lblDelete = [[UILabel alloc] initWithFrame:CGRectMake(261, 37, 43, 21)];
    else
        lblDelete = [[UILabel alloc] initWithFrame:CGRectMake(307, 37, 43, 21)];
    lblDelete.text = @"Delete";
    lblDelete.textColor = [UIColor whiteColor];
    lblDelete.textAlignment = NSTextAlignmentCenter;
    lblDelete.font = [UIFont fontWithName:@"ProximaNova-Regular" size:13.0];
    [self.actView addSubview:lblDelete];
    
    
    btnUnpacked = [UIButton buttonWithType:UIButtonTypeCustom];
    if(IS_IPHONE_5)
        btnUnpacked.frame = CGRectMake(5, 0, 76, 70);
    else if (IS_IPHONE_6P)
        btnUnpacked.frame = CGRectMake(8, 13, 87, 80);
    else if (IS_IPHONE_4_OR_LESS)//Vikita
        btnUnpacked.frame = CGRectMake(5, 0, 76, 70);

    else
        btnUnpacked.frame = CGRectMake(4, 2, 85, 68);
    btnUnpacked.titleLabel.text = @"";
    [btnUnpacked addTarget:self action:@selector(unpackedClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.actView addSubview:btnUnpacked];
    
    btnPacked = [UIButton buttonWithType:UIButtonTypeCustom];
    if(IS_IPHONE_5)
        btnPacked.frame = CGRectMake(81, 0, 76, 70);
    else if (IS_IPHONE_6P)
        btnPacked.frame = CGRectMake(112, 13, 87, 80);
    else if (IS_IPHONE_4_OR_LESS)//Vikita
          btnPacked.frame = CGRectMake(81, 0, 76, 70);
    else
        btnPacked.frame = CGRectMake(95, 2, 85, 68);
    btnPacked.titleLabel.text = @"";
    [btnPacked addTarget:self action:@selector(packedClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.actView addSubview:btnPacked];
    
    btnNeed = [UIButton buttonWithType:UIButtonTypeCustom];
    if(IS_IPHONE_5)
        btnNeed.frame = CGRectMake(164, 0, 76, 70);
    else if (IS_IPHONE_6P)
        btnNeed.frame = CGRectMake(216, 13, 87, 80);
    else if (IS_IPHONE_4_OR_LESS)//Vikita
          btnNeed.frame = CGRectMake(164, 0, 76, 70);
    else
        btnNeed.frame = CGRectMake(190, 2, 85, 68);
    btnNeed.titleLabel.text = @"";
    [btnNeed addTarget:self action:@selector(needClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.actView addSubview:btnNeed];
    
    btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    if(IS_IPHONE_5)
        btnDelete.frame = CGRectMake(244, 0, 76, 70);
    else if (IS_IPHONE_6P)
        btnDelete.frame = CGRectMake(320, 0, 87, 80);
    else if (IS_IPHONE_4_OR_LESS)//Vikita
         btnDelete.frame = CGRectMake(244, 0, 76, 70);
    else
        btnDelete.frame = CGRectMake(286, 2, 85, 68);
    
    btnDelete.titleLabel.text = @"";
    [btnDelete addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.actView addSubview:btnDelete];
    
    [self.view addSubview:self.actView];
    
}

-(void)SwipeUp:(UIView *)view{
    
    CATransition* transition = [CATransition animation];
    [transition setDuration:0.3];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [transition setFillMode:kCAFillModeBoth];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.actionView.layer addAnimation:transition forKey:kCATransition];
}

-(void)SwipeDown:(UIView *)view{
    
    CATransition* transition = [CATransition animation];
    [transition setDuration:0.3];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [transition setFillMode:kCAFillModeBoth];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.actionView.layer addAnimation:transition forKey:kCATransition];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backClick:(id)sender
{
    if(isFromCreateTrip)
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)unpackedClicked:(id)sender
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for(NSManagedObject *obj in indexArray)
    {
        [obj setValue:@"hexa_orange" forKey:@"image"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
    
    [self SwipeDown:self.actView];
    self.actView.hidden = YES;
    self.isOpen = NO;
    
    [indexArray removeAllObjects];
    listArray = [self fetchEquipmentList:currentIndex];
    [self.collectionView reloadData];
    
    [self calculatePercentageAndUpdate];
}

-(IBAction)packedClicked:(id)sender
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for(NSManagedObject *obj in indexArray)
    {
        [obj setValue:@"hexa_gray" forKey:@"image"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }

    [self SwipeDown:self.actView];
    self.actView.hidden = YES;

    self.isOpen = NO;
    [indexArray removeAllObjects];

    listArray = [self fetchEquipmentList:currentIndex];
    [self.collectionView reloadData];
    
    [self calculatePercentageAndUpdate];
}

-(IBAction)needClicked:(id)sender
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for(NSManagedObject *obj in indexArray)
    {
        [obj setValue:@"hexa_olive" forKey:@"image"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
    
    [self SwipeDown:self.actView];
    self.actView.hidden = YES;
    self.isOpen = NO;
    [indexArray removeAllObjects];
    listArray = [self fetchEquipmentList:currentIndex];
    [self.collectionView reloadData];
    
    [self calculatePercentageAndUpdate];
}

-(IBAction)deleteClicked:(id)sender
{
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Delete this item?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    deleteAlert.tag = 3001;
    [deleteAlert show];
}

-(IBAction)deleteListClicked:(id)sender
{
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Delete this list?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    deleteAlert.tag = 5001;
    [deleteAlert show];

}

-(IBAction)renameListClicked:(id)sender
{
    [self SwipeDown:self.menuView];
    self.menuView.hidden = YES;
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename Activity List" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil] ;
    alertView.tag = 2001;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    if(isFromCreateTrip)
        [alertView textFieldAtIndex:0].text = activityDict[@"activityListname"];
    else
        [alertView textFieldAtIndex:0].text = [myTripObj valueForKey:@"activityList_Name"];
    [alertView show];
}

-(IBAction)resateListClicked:(id)sender
{
    [self SwipeDown:self.menuView];
    self.menuView.hidden = YES;
    
    UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Reset all items in this list?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    resetAlert.tag = 4001;
    [resetAlert show];
}

-(IBAction)editClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if(!btn.selected)
    {
        self.actView.hidden = YES;
        self.menuView.hidden = NO;
        [self SwipeUp:self.menuView];
    }
    else
    {
        [self SwipeDown:self.menuView];
        self.menuView.hidden = YES;

    }
    btn.selected = !btn.selected;
}

-(IBAction)sendEmailClicked:(id)sender {
    // Email Subject
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if([MFMailComposeViewController canSendMail])
    {
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *snapShotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSLog(@"image - %@", snapShotImage);
        
        NSData *jpegData = UIImageJPEGRepresentation(snapShotImage, 1);
        NSString *fileName = @"Scrren_Shot";
        fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
        [mc addAttachmentData:jpegData mimeType:@"image/jpeg" fileName:fileName];

        
        NSString *emailTitle = @"Feedback on My Trips";
        // Email Content
        NSString *messageBody = @"";
        // To address
       NSArray *toRecipents = [NSArray arrayWithObject:@"info@thevikingapp.com"];
        
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)leftClicked:(id)sender
{
    self.BtnRight.userInteractionEnabled = YES;
    if(!currentIndex == 0)
    {
        currentIndex = currentIndex-1;
        if(currentIndex == 0)
        {
            self.BtnLeft.userInteractionEnabled = NO;
        }
        [self SwipeLeft:self.view];
        self.isOpen = NO;
        self.actView.hidden = YES;
        [self SwipeDown:self.actView];
        
        listArray = [self fetchEquipmentList:currentIndex];
        [self.collectionView reloadData];
        [self setUpheader];
    }
    NSLog(@"Left :- current index - %d", currentIndex);

}

-(IBAction)rightClicked:(id)sender
{
    self.BtnLeft.userInteractionEnabled = YES;
    if(currentIndex < totalIndex-1)
    {
        currentIndex = currentIndex+1;
        if(currentIndex == totalIndex-1)
        {
            self.BtnRight.userInteractionEnabled = NO;
        }            
        [self SwipeRight:self.view];
        self.isOpen = NO;
        [self SwipeDown:self.actView];
        self.actView.hidden = YES;
        
        listArray = [self fetchEquipmentList:currentIndex];
        [self.collectionView reloadData];
        [self setUpheader];
    }
    NSLog(@"Right :- current index - %d", currentIndex);
    
}

-(void)SwipeRight:(UIView *)view{
    
    CATransition* transition = [CATransition animation];
    [transition setDuration:0.3];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromRight;
    [transition setFillMode:kCAFillModeBoth];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [view.layer addAnimation:transition forKey:kCATransition];
    //    [self.tblFiles reloadData];
}

-(void)SwipeLeft:(UIView *)view{
    CATransition* transition = [CATransition animation];
    [transition setDuration:0.3];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromLeft;
    [transition setFillMode:kCAFillModeBoth];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [view.layer addAnimation:transition forKey:kCATransition];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if (![[touch view] isKindOfClass:[UICollectionView class]])
    {
        NSLog(@"yeeeeee");
    }
    
}

- (void)userTapped:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"tapped");
    self.actView.hidden = YES;
    for(NSIndexPath *selIndex in indexArray)
    {
        ListCell *cell = (ListCell *)[_collectionView cellForItemAtIndexPath:selIndex];
//        cell.hexImege.image = [UIImage imageNamed:@"orange_hexagon"];
    }
    
    [indexArray removeAllObjects];
}

@end
