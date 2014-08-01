//
//  AmazonS3Util.m
//  PMCameraTestS3
//
//  Created by Paola Mata Maldonado on 7/28/14.
//
//

#import "AmazonS3Util.h"
#import <AWSRuntime/AWSRuntime.h>

@implementation AmazonS3Util


-(id)initWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey bucket:(NSString*)bucket delegate:(id)delegate
{
    self = [super init];
    
    // Initial the S3 Client.
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:accessKey withSecretKey:secretKey];
    self.delegate = delegate;
    
    // Create Bucket.
    S3CreateBucketRequest *request = [[S3CreateBucketRequest alloc] initWithName:bucket ];
    S3CreateBucketResponse *response = [self.s3 createBucket:request];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
    }
    
    return self;
}


-(NSArray*)listFromBucket:(NSString*)bucketName
{
    @try
    {
        S3ListObjectsRequest *request = [[S3ListObjectsRequest alloc] initWithName: bucketName];
        S3ListObjectsResponse *response = [self.s3 listObjects:request];
        NSMutableArray* objectSummaries = response.listObjectsResult.objectSummaries;
        return [[NSArray alloc] initWithArray: objectSummaries];
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot list S3 %@",exception);
        return [[NSArray alloc]init];
    }
    
}

-(NSData*)downloadFromBucket:(NSString*)bucketName withKey: (NSString*) key
{
    @try
    {
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:key withBucket:bucketName];
        S3GetObjectResponse *response = [self.s3 getObject:request];
        return [response body];
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot Load S3 Object %@",exception);
        return  nil;
    }
    
}

-(void)uploadData:(NSData*)data format:(NSString*)format
       bucketName:(NSString*)bucketName withKey: (NSString*) key
{
    S3PutObjectRequest *pOR = [[S3PutObjectRequest alloc] initWithKey:key inBucket:bucketName ];
    pOR.contentType = format;
    pOR.data        = data;
    S3PutObjectResponse *putObjectResponse =
    [self.s3 putObject:pOR];
    [self performSelectorOnMainThread:@selector(uploadDone:) withObject:putObjectResponse.error waitUntilDone:NO];
    
}

- (void)uploadDone:(NSError *)error
{
    @try
    {
        [[self delegate] uploadDone:error];
    }
    @catch (NSException *exception) {
        NSLog(@"uploadDone Exception : %@",exception);
    }
}


-(BOOL)deleteFromBucket:(NSString*)bucketName withKey:(NSString*)key
{
    @try
    {
        [self.s3 deleteObjectWithKey:key withBucket:bucketName];
        return TRUE;
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot Delete S3 Object %@",exception);
        return FALSE;
    }
}

- (void)dealloc {
    self.s3 = nil;
    self.delegate = nil;
    NSLog(@"Deallocation Done");
}


@end
