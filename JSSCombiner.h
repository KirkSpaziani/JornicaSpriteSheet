//
//  JSSCombiner.h
//  SpriteSheet
//
//  Created by Kirk Spaziani on 6/27/20.
//  Copyright © 2020 Spazcosoft, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSSCombiner : NSObject

-(nonnull instancetype)initWithImagePath:(nonnull NSString *)imagePath
                               sheetName:(nonnull NSString *)sheetName
                              sheetWidth:(NSInteger)sheetWidth
                             sheetHeight:(NSInteger)sheetHeight
                             spriteWidth:(NSInteger)spriteWidth
                            spriteHeight:(NSInteger)spriteHeight;

-(void)combine;

@end

