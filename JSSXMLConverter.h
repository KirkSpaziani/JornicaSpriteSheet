//
//  JSSXMLConverter.h
//  SpriteSheet
//
//  Created by Kirk Spaziani on 6/28/20.
//  Copyright © 2020 Spazcosoft, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSSXMLConverter : NSObject

-(instancetype)initWithSourceFile:(NSString *)sourceFile destFile:(NSString *)destFile;

-(void)convert;

@end

NS_ASSUME_NONNULL_END
