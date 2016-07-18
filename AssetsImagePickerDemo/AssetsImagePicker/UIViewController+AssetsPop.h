//
//  UIViewController+AssetsPop.h
//  ImageAssert
//
//  Created by WangBin on 16/6/28.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AssetsPop)
- (void)popPresentViewController:(UIViewController *)viewControllerToPresent completion:(void (^)(void))completion dismiss:(void (^)(void))dismiss;
- (void)dismissPopViewControllerCompletion:(void (^)(void))completion;
@end
