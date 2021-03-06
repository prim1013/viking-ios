//
//  NewTripVC.m
//  Viking
//
//  Created by macmini08 on 27/01/15.
//  Copyright (c) 2015 Space O Technology. All rights reserved.
//

#import "NewTripVC.h"
#import "ActivityCell.h"
#import <MessageUI/MessageUI.h>
#import "AppConstant.h"
#import "XMLDictionary.h"
#import "CreateTripVC.h"

@interface NewTripVC ()<MFMailComposeViewControllerDelegate>
{
    NSMutableArray *activityArr;
    NSDictionary *allActivityDict;
    NSString *selectedActivity;
}
@end

@implementation NewTripVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainHeaderLbl.font = [UIFont fontWithName:@"ProximaNova-Light" size:18.0];
    self.headerLbl.font = [UIFont fontWithName:@"ProximaNova-Light" size:15.0];
    // Do any additional setup after loading the view.
    
//    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"viking_list" ofType:@"xml"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    documentsURL = [documentsURL URLByAppendingPathComponent:@"viking_list.xml"];

    
    allActivityDict = [NSDictionary dictionaryWithXMLFile:[documentsURL path]];

//    NSLog(@"dictionary: %@", xmlDoc1);
    
    activityArr = allActivityDict[@"Main_Activities"][@"name"];
    NSLog(@"activity arr - %@", activityArr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [activityArr count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_IPHONE_5)
    {
        return CGSizeMake(155, 153);
    }
    else if(IS_IPHONE_6)
        return CGSizeMake(180, 180);
    else if (IS_IPHONE_4_OR_LESS)
       return CGSizeMake(153, 154); //Vikita
    else
        return CGSizeMake(200, 200);
        
        
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//    cell.activityImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"menu_%d", indexPath.row]];
    NSString *imageStr = activityArr[indexPath.row];
    cell.activityImage.image = [UIImage imageNamed:imageStr];
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if(IS_IPHONE_5)
        return 2.0;
    else if (IS_IPHONE_6)
        return 2.0;
    else
        return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if(IS_IPHONE_5)
        return 2.0;
    else if (IS_IPHONE_6)
        return 2.0;
    else
        return 0.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    if(IS_IPHONE_5)
        return UIEdgeInsetsMake(0, 3, 0, 3);
    else
        return UIEdgeInsetsMake(0,5,0,5);  // top, left, bottom, right
}

-(IBAction)backClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

        
        NSString *emailTitle = @"Feedback on New Trip";
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


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSIndexPath * indexPath = [self.activityCollectionView indexPathForCell:sender];
    selectedActivity = activityArr[indexPath.row];
    
    if([sender isKindOfClass:[ActivityCell class]]) {
        
        if([selectedActivity isEqualToString:@"Motorsports"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"This feature is not available yet. Check back soon." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
        else
            return YES;
    }
    else
        return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([sender isKindOfClass:[ActivityCell class]]) {
        NSIndexPath * indexPath = [self.activityCollectionView indexPathForCell:sender];
        selectedActivity = activityArr[indexPath.row];
        
        NSLog(@"activity - %@", selectedActivity);
        
        CreateTripVC *vc = segue.destinationViewController;
        vc.subActivityArr = allActivityDict[@"Equipment"][@"main_activity"];
        vc.selectedActivity = selectedActivity;
    }    
}

@end
