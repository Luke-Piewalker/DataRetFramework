//
//  DataRet.h
//  DataRet
//
//  Created by oakleyk on 09/08/2018.
//  Copyright © 2018 abc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataRet : NSObject
/**
 Returns a shared Instance of the DataRet class
 @return Returns a shared instance of the DataRet class or nil if an error has occured
 */
+(DataRet*)DataRet;

/**
 Returns an array containing the segments for the provided id. If no id is found returns nil
 @return Returns an array containing all the segments for the provided id, or nil if no segments were found for the provided ID
 @remark This should not be called on the main thread due to blocking calls
 */
-(NSArray*)getUserData:(NSString*)provider_id;

@end
