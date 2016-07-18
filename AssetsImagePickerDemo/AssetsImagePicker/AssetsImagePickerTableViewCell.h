//
//  AssetsTableViewCell.h
//  ImageAssert
//
//  Created by WangBin on 16/6/27.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetsImagePickerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
