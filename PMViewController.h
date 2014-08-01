//
//  PMViewController.h
//  PMCameraTest
//
//  Created by Paola Mata Maldonado on 7/24/14.
//
//

#import <UIKit/UIKit.h>
#import "AmazonS3Util.h"


@interface PMViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (weak, nonatomic)IBOutlet UITableView *tableView;
@property (nonatomic, weak)IBOutlet UIImageView *imageView;
@property (nonatomic, strong)UIPopoverController *popoverController;
//@property(nonatomic,strong)NSString *urlString;
@property(nonatomic)NSArray *tableData;

@property (weak, nonatomic)IBOutlet UIBarButtonItem *cameraButton;

@property(nonatomic)AmazonS3Util *s3;


-(void)loadData;
- (IBAction)cameraButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;

@end
