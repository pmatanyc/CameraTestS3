//
//  PMViewController.m
//  PMCameraTest
//
//  Created by Paola Mata Maldonado on 7/24/14.
//
//

#import "PMViewController.h"
#import "Constants.h"

@interface PMViewController ()

@end

@implementation PMViewController
@synthesize popoverController, tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.s3 = [[AmazonS3Util alloc] initWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY bucket:[Constants uploadBucket] delegate:self];

    [self loadData];
    
}

-(void)viewWillLayoutSubviews{
    
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"]){
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:400];
        [self.view addConstraint:constraint];
    }
    else{
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:250];
        [self.view addConstraint:constraint];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell){
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@",[tableData objectAtIndex: indexPath.row ]];
    
    [[cell textLabel] setText: fileName];

    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSString *fileName = [NSString stringWithFormat:@"%@",
                          [tableData objectAtIndex: indexPath.row ]];
    
    NSData *downloadData = [[self s3] downloadFromBucket:[Constants uploadBucket] withKey:fileName];
    
    if(downloadData)
        self.imageView.image = [UIImage imageWithData: downloadData];

    
}

- (void) tableView: (UITableView *)tableView  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [NSString stringWithFormat:@"%@",
                          [tableData objectAtIndex: indexPath.row ]];
    
    [[self s3] deleteFromBucket:[Constants uploadBucket] withKey:fileName];
    [self loadData];}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cameraButtonPressed:(id)sender {
    
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"]){
        if([popoverController isPopoverVisible]){
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
        return;
        }
    
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
        if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
        
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else
        {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        }
    
        imagePickerController.allowsEditing = YES;
        imagePickerController.delegate = self;

        popoverController = [[UIPopoverController alloc]initWithContentViewController:imagePickerController];
    
        popoverController.delegate = self;
    
        [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

    else {
        NSLog(@"Device is not iPad");
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
            
            [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else
        {
            [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            
        }
        
        imagePickerController.allowsEditing = YES;
        imagePickerController.delegate = self;
        

        [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
    }
 
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self.imageView setImage:image];
    
    
    NSData *imageData = UIImageJPEGRepresentation ( image, 1.0);
    
    
    NSString *fileName = [[NSString alloc] initWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970 ] ];
    
    [[self s3] uploadData:imageData format:@"image/jpeg"
               bucketName:[Constants uploadBucket] withKey:fileName];
    
}


- (IBAction)editButtonPressed:(id)sender {
    
    if([self.tableView isEditing]){
        [sender setTitle:@"Edit"];
    }
    else{
        [sender setTitle:@"Done"];
    }
    [self.tableView setEditing:![self.tableView isEditing]];

}

- (void)uploadDone:(NSError *)error
{
    if(error != nil)
    {
        NSLog(@"Error: %@", error);
    }
    else
    {
        NSLog(@"File Uploaded");
        [self loadData];
    }
}

-(void)loadData
{
    tableData = [[self s3] listFromBucket:[Constants uploadBucket]];
    [self.tableView reloadData];
}



@end
