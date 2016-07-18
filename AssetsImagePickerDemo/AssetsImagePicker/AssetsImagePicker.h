//
//  AssetsImagePicker.h
//  ImageAssert
//
//  Created by WangBin on 16/6/28.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AssetsImagePickerProtocol.h"

@interface AssetsImagePicker : NSObject

+ (void)picker:(id<AssetsImagePickerProtocol>)picker fromViewController:(UIViewController *)fromViewController;
@end
