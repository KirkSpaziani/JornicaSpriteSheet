//
//  JSSUtils.m
//  SpriteSheet
//
//  Created by Kirk Spaziani on 6/29/20.
//  Copyright © 2020 Spazcosoft, LLC. All rights reserved.
//

#import "JSSUtils.h"
@import AppKit;

NSXMLElement *spriteSize(NSInteger width, NSInteger height) {
  NSXMLElement *spriteSizeElement = [NSXMLElement elementWithName: @"spritesize"];
  NSXMLElement *widthElement = [NSXMLElement elementWithName: @"width" stringValue: [@(width) stringValue]];
  NSXMLElement *heightElement = [NSXMLElement elementWithName: @"height" stringValue: [@(height) stringValue]];

  [spriteSizeElement addChild: widthElement];
  [spriteSizeElement addChild: heightElement];

  return spriteSizeElement;
}


/// Converts from snake_case to camelCase.
/// @param string snake_case string.
NSString *humpify(NSString *string) {
  NSArray<NSString *> *components = [string componentsSeparatedByString:@"_"];
  NSMutableString *tempString = [[NSMutableString alloc] init];
  [tempString appendString: [components firstObject]];
  components = [components subarrayWithRange: NSMakeRange(1, [components count] - 1)];
  for(NSString *component in components) {
    [tempString appendString: capitalize(component)];
  }

  return [tempString copy];
}

NSString *capitalize(NSString *string) {
  return [string stringByReplacingCharactersInRange: NSMakeRange(0, 1)
                                         withString:[[string substringToIndex:1]
                                                     capitalizedString]];
}
