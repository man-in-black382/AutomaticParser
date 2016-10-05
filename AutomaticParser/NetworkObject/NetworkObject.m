//
//  NetworkObject.m
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "NetworkObject.h"
#import <objc/runtime.h>

static NSString *const DefaultDateFormat = @"yyyy-MM-dd'T'HH:mm'+0000'";
static NSString *const ParseDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

/*!
 @class NetworkObject
 @discussion Class designed to provide automatic parsing of back-end responses into PONSO objects.
 Custom parsing rules for specific cases can be implemented by overriding -adaptJSONObject:forKey: and -adaptedObjectForJSONFromKey: methods.
 */
@implementation NetworkObject

#pragma mark - Lifecycle

/**
 *  Returns object with properties filled with NSDictionary received from back-end.
 *
 *  @param data JSON data received from back-end.
 *
 *  @return Initialized model object
 */
+ (instancetype)objectFromJSON:(NSDictionary *)json
{
    NetworkObject *object = [[self alloc] init];
    object.JSONRepresentation = json;
    return object;
}

+ (NSArray<NetworkObject *> *)objectsFromJSON:(NSArray *)json
{
    return [self objectsOfClass:self fromJSONArray:json];
}

#pragma mark - Custom Accessors (Private)

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    [[self map] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [description appendFormat:@"%@ : %@\n", key, [[self valueForKey:key] description]];
    }];
    return description;
}

#pragma mark - Private

+ (NSArray<NetworkObject *> *)objectsOfClass:(Class)class fromJSONArray:(NSArray *)array
{
    NSMutableArray *mappedArray = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        NetworkObject *networkObject = [[class alloc] init];
        networkObject.JSONRepresentation = dictionary;
        [mappedArray addObject:networkObject];
    }
    
    return mappedArray;
}

+ (NSArray<NSDictionary *> *)JSONArrayFromObjects:(NSArray<NetworkObject *> *)objects
{
    NSMutableArray *mappedRepresentation = [NSMutableArray array];
    for (NetworkObject *networkObject in objects) {
        [mappedRepresentation addObject:networkObject.JSONRepresentation];
    }
    return mappedRepresentation;
}

- (Class)classOfProperty:(objc_property_t)property
{
    NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSString *typeAttribute = [propertyAttributes componentsSeparatedByString:@","].firstObject;
    
    // Cheking for string's length because type id doesn't have type specifier after 'T@'
    if ([typeAttribute hasPrefix:@"T@"] && typeAttribute.length > 2) {
        // Getting class name from string that looks like this: @T"ClassName"
        NSString *typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length] - 4)];
        return NSClassFromString(typeClassName);
    }
    return nil;
}

#pragma mark - Public

/**
 *  Used to specify dependencies between object properties and JSON keys. Used for filling object properties from server response.
 *
 *  @code
 *  - (NSDictionary *)map
 *  {
 *      return @{@"object_property_name" : @"JSON_property_name"};
 *  }
 *  @endcode
 *  @return Dictionary where key - object property name and value - JSON property key.
 */
- (NSDictionary *)map
{
    [NSException raise:NSInternalInconsistencyException format:@"Method %@ not implemented", NSStringFromSelector(_cmd)];
    return nil;
}

/**
 *  Used to specify dependencies between object properties and JSON keys. Used for creating NSDictionary that may be serialized to JSON data. In case if NetworkObject doesn't implement this method - returns "- (NSDictionary *)map" value
 *
 *  @code
 *  - (NSDictionary *)invertedMap
 *  {
 *      return @{@"object_property_name" : @"JSON_property_name"};
 *  }
 *  @endcode
 *  @return Dictionary where key - object property name and value - JSON property key.
 */
- (NSDictionary *)invertedMap
{
    return self.map;
}

/**
 *  Provides dictionary the keys in which represent property names of collections (arrays) and values - class names of objects that these arrays can contain
 *  
 *  @discussion
 *  This method is needed due to a lack of type reflection for collections in Objective-C
 *  @code
 *  - (NSDictionary *)collectionObjectTypesMap
 *  {
 *      return @{@"collection_property_name" : @"NetworkObject"};
 *  }
 *  @endcode
 *  @return Dictionary where key is an object's property name and the value is a class name for a NetworkObject's descendant.
 */
- (NSDictionary *)collectionObjectTypesMap
{
    return nil;
}

#pragma mark - Private

#pragma mark - Custom Accessors (Public)

- (void)setJSONRepresentation:(NSDictionary *)JSONRepresentation
{
    if ([JSONRepresentation isKindOfClass:[NSNull class]]) {
        return;
    }
    
    NSDictionary *mappingKeys = [self map];
    NSDictionary *collectionObjectTypesMap = [self collectionObjectTypesMap];
    
    __weak typeof(self) weakSelf = self;
    [mappingKeys enumerateKeysAndObjectsUsingBlock:^(id objectPropertyName, id JSONPropertyName, BOOL *stop) {
        id JSONObject = [JSONRepresentation valueForKeyPath:JSONPropertyName];
        
        if (!JSONObject) {
            [NSException raise:NSInternalInconsistencyException format:@"Value for JSON key %@ is nil", JSONPropertyName];
            return;
        }
        
        objc_property_t property = class_getProperty([weakSelf class], [objectPropertyName UTF8String]);
        Class propertyClass = [self classOfProperty:property];
        
        if ([propertyClass isSubclassOfClass:[NSDictionary class]]) {
            [NSException raise:NSInternalInconsistencyException format:@"NetworkObjects shouldn't have properties of NSDictionary type. Each NSDictionary must be replaced with a NetworkObject's descendant."];
            return;
        }
        
        // First, process arrays (may consist of primitives or NetworkObject descendants)
        if ([propertyClass isSubclassOfClass:[NSArray class]]) {
            // Check if JSON array contains complex objects (dictionaries)
            if ([[(NSArray *)JSONObject firstObject] isKindOfClass:[NSDictionary class]]) {
                // Get class of object from classNamesMap dictionary
                NSArray *mappedArray = [NetworkObject objectsOfClass:NSClassFromString(collectionObjectTypesMap[objectPropertyName]) fromJSONArray:JSONObject];
                [weakSelf setValue:mappedArray forKey:objectPropertyName];
            } else {
                [weakSelf setValue:[self adaptJSONObject:JSONObject forKey:objectPropertyName] forKey:objectPropertyName];
            }
        } else if ([propertyClass isSubclassOfClass:[NetworkObject class]]) { // Second, process single NetworkObject descendants
            NetworkObject *relatedObject = [[propertyClass alloc] init];
            relatedObject.JSONRepresentation = [self adaptJSONObject:JSONObject forKey:objectPropertyName];
            [weakSelf setValue:relatedObject forKey:objectPropertyName];
        } else { // Third, process all other objects
            id adapdedJSONObject = [self adaptJSONObject:JSONObject forKey:objectPropertyName];
            [weakSelf setValue:adapdedJSONObject forKey:objectPropertyName];
        }
    }];
}

- (NSDictionary *)JSONRepresentation
{
    NSDictionary *invertedMappingKeys = [self invertedMap];
    
    NSMutableDictionary *JSONDictionary = [NSMutableDictionary dictionary];
    
    __weak typeof(self) weakSelf = self;
    [invertedMappingKeys enumerateKeysAndObjectsUsingBlock:^(id objectPropertyName, id JSONPropertyName, BOOL *stop) {
        id propertyValue = [weakSelf valueForKey:objectPropertyName];
        
        if (!propertyValue) {
            [NSException raise:NSInternalInconsistencyException format:@"Value for key %@ is nil, which is unacceptable. You may want to override %@ to return a specific value when the value for this key is nil.", objectPropertyName, NSStringFromSelector(@selector(adaptedObjectForJSONFromKey:))];
            return;
        }
        
        if ([propertyValue isKindOfClass:[NetworkObject class]]) {
            [JSONDictionary setObject:[(NetworkObject *)propertyValue JSONRepresentation] forKey:JSONPropertyName];
        } else if ([propertyValue isKindOfClass:[NSArray class]]){
            if ([[(NSArray *)propertyValue firstObject] isKindOfClass:[NetworkObject class]]) {
                [JSONDictionary setObject:[NetworkObject JSONArrayFromObjects:propertyValue] forKey:JSONPropertyName];
            } else {
                [JSONDictionary setObject:[weakSelf adaptedObjectForJSONFromKey:objectPropertyName] forKey:JSONPropertyName];
            }
        } else {
            [JSONDictionary setObject:[weakSelf adaptedObjectForJSONFromKey:objectPropertyName] forKey:JSONPropertyName];
        }
    }];
    return JSONDictionary;
}

/**
 *  May be overriden to apply specific parsing rules of JSON response for some key (e.g. property)
 *
 *  @param JSONObject Object which needs to be additionally transformed before setting to property
 *  @param key        Key (property) for which transformation is needed
 *
 *  @return Transformed object which is ready to be set into property's ivar
 */
- (id)adaptJSONObject:(id)JSONObject forKey:(NSString *)key
{
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    Class propertyClass = [self classOfProperty:property];
    
    if (!propertyClass) {
        return JSONObject;
    }
    
    if ([propertyClass isSubclassOfClass:[NSURL class]]) {
        return [NSURL URLWithString:JSONObject];
    } else if ([propertyClass isSubclassOfClass:[NSDate class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = ParseDateFormat;
        NSDate *date = [dateFormatter dateFromString:JSONObject];
        if (!date) {
            dateFormatter.dateFormat = DefaultDateFormat;
            date = [dateFormatter dateFromString:JSONObject];
        }
        return date;
    }
    
    return JSONObject;
}

/**
 *  May be overriden to provide custom transformations of value for 'key'
 *
 *  @param key Key (property) transformation of which is needed
 *
 *  @return Transformed object which is ready to be passed to back-end
 */
- (id)adaptedObjectForJSONFromKey:(NSString *)key
{
    id propertyValue = [self valueForKey:key];
    
    if ([propertyValue isKindOfClass:[NSDate class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:DefaultDateFormat];
        return [dateFormatter stringFromDate:propertyValue];
    } else if ([propertyValue isKindOfClass:[NSURL class]]) {
        return [propertyValue absoluteString];
    } else {
        return propertyValue;
    }
}

@end
