//
//  AssetsTableViewController.h
//  ImageAssert
//
//  Created by WangBin on 16/6/27.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol AssetsImagePickerGroupControllerDelegate <NSObject>

- (void)assetsDidSelectedGroup:(ALAssetsGroup *)group;

@end

@interface AssetsImagePickerGroupController : UITableViewController

@property (strong, nonatomic) NSArray *assetsGroups;
@property (strong, nonatomic) ALAssetsGroup *selectedGroup;
@property (weak, nonatomic) id<AssetsImagePickerGroupControllerDelegate>assetsDelegate;

@end
