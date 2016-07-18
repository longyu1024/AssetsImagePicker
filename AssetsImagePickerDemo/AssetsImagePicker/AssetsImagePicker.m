//
//  AssetsImagePicker.m
//  ImageAssert
//
//  Created by WangBin on 16/6/28.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import "AssetsImagePicker.h"
#import "AssetsImagePickerController.h"

@implementation AssetsImagePicker

+ (void)picker:(id<AssetsImagePickerProtocol>)picker fromViewController:(UIViewController *)fromViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Assets" bundle:nil];
    
    UINavigationController *assetsNav = [sb instantiateInitialViewController];
    
    AssetsImagePickerController *assetsImagePickerController = assetsNav.viewControllers.lastObject;
    assetsImagePickerController.picker = picker;
    
    [fromViewController presentViewController:assetsNav animated:YES completion:nil];
}
@end
