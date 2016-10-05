//
//  NetworkObject.h
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkObject : NSObject

/**
 *  Returns NSDictionary which represents properties' values of this and all nested model objects.
 *  Setting a dictionary-response to this property automatically leads to immediate automatic parsing of response.
 */
@property (strong, nonatomic) NSDictionary *JSONRepresentation;

+ (instancetype)objectFromJSON:(NSDictionary *)json;
+ (NSArray<NetworkObject *> *)objectsFromJSON:(NSArray *)json;

- (NSDictionary *)map;
- (NSDictionary *)invertedMap;
- (NSDictionary *)collectionObjectTypesMap;

- (id)adaptJSONObject:(id)JSONObject forKey:(NSString *)key;
- (id)adaptedObjectForJSONFromKey:(NSString *)key;

@end
