//
//  JSSConverter.h
//  SpriteSheet
//
//  Created by Kirk Spaziani on 6/27/20.
//  Copyright © 2020 Spazcosoft, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, JSSConversionOptions) {
  JSSConversionOptionsWhiteToRed = 1 << 0,
  JSSConversionOptionsBlackToAlpha = 1 << 1,
  JSSConversionOptionsAlphaToMagenta = 1 << 2
};

@interface JSSConverter : NSObject

-(nonnull instancetype)initWithConversions:(JSSConversionOptions)conversions
                                sourcePath:(nonnull NSString *)sourcePath
                                  destPath:(nonnull NSString *)destPath;

-(void)convert;

@end
