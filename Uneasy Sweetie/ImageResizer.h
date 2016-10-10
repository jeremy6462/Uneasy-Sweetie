//
//  ImageResizer.h
//  Uneasy Sweetie
//
//  Created by Jeremy Kelleher on 2/13/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageResizer : NSObject

+ (nonnull UIImage *)resizeImage:(nonnull UIImage*)image newSize:(CGSize)newSize;

@end
