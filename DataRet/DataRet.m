//
//  DataRet.m
//  DataRet
//
//  Created by oakleyk on 09/08/2018.
//  Copyright © 2018 abc. All rights reserved.
//

#import "DataRet.h"
#include <UIKit/UIKit.h>

@implementation DataRet
{
    NSArray* retrievedData;
    NSDate* prevInteraction;
}
static const NSString* uniqueUserID;
+(DataRet*)DataRet
{
    static dispatch_once_t runOnce = 0;
    static DataRet* instance = nil;
    dispatch_once(&runOnce, ^{
        instance = [[self alloc] init];
        
        // This won't change for the life time of the app on device.
        // If app uninstalled and reinstalled later this will change. However if only installed over this won't change (e.g patches)
        // Alternatively however could use some form of user login credentials here
        // Which could be used to track users across multiple devices || multiple users on same device
        uniqueUserID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
    });
    return instance;
}

-(NSData*)getDataFromAddress:(NSString*)getAddress
{
    NSData* retData = nil;
    NSMutableURLRequest* request = nil;
    do{
        if (getAddress == nil)
        {
            NSLog(@"getAddress was nil");
            break;
        }
        
        request = [[NSMutableURLRequest alloc] init];
        if (request == nil)
        {
            NSLog(@"Failed to init NSMutableURLRequest");
            break;
        }
        [request setHTTPMethod:@"GET"];
        [request setURL:[NSURL URLWithString:getAddress]];
        
        NSError* error = nil;
        NSHTTPURLResponse* responce = nil;
        // Function is deprecated + blocking, but for localserver its quick
        retData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error];
        // Would ideally use [NSURLSession dataTaskWithRequest:completionHandler:] as this is a blocking call
        
        if (retData == nil || responce.statusCode != 200 || error != nil)
        {
            // Failed to retrieve data
            NSLog(@"Something went wrong with Request");
            retData = nil;
        }
    } while (false);
    
    /** Not needed for ARC environment. However would ideally have #define around this to include this in non ARC environments
     if (request != nil)
     {
     [request release];
     }
     */
    return retData;
}

-(NSString*)createGetRequestString
{
    // This string really should be scrambled && would ideally be a https get request considering its potentially sensitive information being transferred
    return [NSString stringWithFormat:@"http://localhost:8080/api/v1/data?user_id=:%@",uniqueUserID];
}

-(NSDictionary*)convertJSONToNSDictionary:(NSData*)jsonData
{
    NSError* error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (error != nil)
    {
        json = nil;
    }
    
    return json;
}
// In practise this is faster than looping through the array.
// Would be faster if using a hashmap to look up id within dictionary instead of having to peak into each dictionary within the array!
-(NSArray*)findValue:(NSString*)value inProviderArray:(NSArray*)providerArray
{
    NSPredicate* findValue = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary* bind)
                              {
                                  return [[obj objectForKey:@"id"] isEqualToString:value];
                              }];
    return [providerArray filteredArrayUsingPredicate:findValue];
}

-(bool)updateData:(NSString*)provider_id
{
    bool updateSucceeded = false;
    do
    {
        NSString* requestString = [self createGetRequestString];
        
        NSData* gotData = [self getDataFromAddress:requestString];
        if (gotData == nil)
        {
            NSLog(@"Failed to retrieve data");
            break;
        }
        
        NSDictionary* jsonData = [self convertJSONToNSDictionary:gotData];
        if(jsonData == nil)
        {
            NSLog(@"Failed to convert JSON to NSDictionary");
            break;
        }
        
        retrievedData = [jsonData objectForKey:@"providers"];
        if (retrievedData == nil)
        {
            NSLog(@"No providers in returned JSON");
            break;
        }
        
        updateSucceeded = true;
    } while(false);
    
    return updateSucceeded;
}

-(NSArray*)getUserData:(NSString*)provider_id
{
    NSArray* retSegmentArray = nil;
    NSArray* filteredArray = nil;
    
    @autoreleasepool {
        do
        {
            if (provider_id == nil || [provider_id length] == 0)
            {
                NSLog(@"nil or empty string provided");
                break;
            }
            
            if (retrievedData == nil)
            {
                if (![self updateData:provider_id])
                {
                    NSLog(@"Failed to retrieve data.. can't proceed");
                    break;
                }
            }
            
            if([prevInteraction timeIntervalSinceDate:[NSDate date]] > 1200)
            {
                if ([self updateData:provider_id])
                {
                    NSLog(@"Failed to update Data");
                    // Not a major fail. But would ideally trigger something to poll server for data update on seperate thread
                }
            }
            // Session extention
            prevInteraction = [NSDate date];
            
            filteredArray = [self findValue:provider_id inProviderArray:retrievedData];
            if (filteredArray == nil || [filteredArray count] == 0)
            {
                NSLog(@"id not found");
                break;
            }
            // This is assuming that only 1 object is found where provider_ID is unique
            retSegmentArray = [[filteredArray objectAtIndex:0] objectForKey:@"segments"];
            
        } while (false);
    }
    return retSegmentArray;
}
@end
