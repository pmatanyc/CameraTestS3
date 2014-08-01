//
//  Constants.m
//  PMCameraTestS3
//
//  Created by Paola Mata Maldonado on 7/28/14.
//
//

#import "Constants.h"


@implementation Constants

+(NSString*)uploadBucket{
    return [[NSString stringWithFormat:@"%@-%@", BUCKET, ACCESS_KEY_ID] lowercaseString];
}

@end
