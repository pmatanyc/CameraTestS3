//
//  AmazonS3Util.h
//  PMCameraTestS3
//
//  Created by Paola Mata Maldonado on 7/28/14.
//
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>

@interface AmazonS3Util : NSObject

@property (nonatomic, strong) AmazonS3Client *s3;
@property (nonatomic, strong) id delegate;

-(id)initWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey bucket:(NSString*)bucket delegate:(id)delegate;

-(NSArray*)listFromBucket:(NSString*)bucketName;

-(NSData*)downloadFromBucket:(NSString*)bucketName withKey: (NSString*) key;

-(void)uploadData:(NSData*)data format:(NSString*)format
       bucketName:(NSString*)bucketName withKey: (NSString*) key;

-(BOOL)deleteFromBucket:(NSString*)bucketName withKey:(NSString*)key;


@end
