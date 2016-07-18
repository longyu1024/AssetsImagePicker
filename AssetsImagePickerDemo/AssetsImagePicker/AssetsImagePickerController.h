//
//  ImageAssertController.h
//  ImageAssert
//
//  Created by WangBin on 16/6/27.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetsImagePickerProtocol.h"

@interface AssetsImagePickerController : UICollectionViewController

@property (assign, nonatomic) id<AssetsImagePickerProtocol>picker;

@end
