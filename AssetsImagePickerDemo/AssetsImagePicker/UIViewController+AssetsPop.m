//
//  UIViewController+AssetsPop.m
//  ImageAssert
//
//  Created by WangBin on 16/6/28.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import "UIViewController+AssetsPop.h"
#import <objc/runtime.h>

#define kOverlayViewTag                 1000001
#define kDismissViewTag                 1000002
#define kAssetsPopPresentedController   @"kAssetsPopPresentedController"
#define kAssetsPopAnimating             @"kAssetsPopAnimating"
#define kAssetsDismissBlock             @"kAssetsDismissBlock"

#define ASSETS_USE_SPRING               1


@implementation UIViewController (AssetsPop)

- (void)popPresentViewController:(UIViewController *)viewControllerToPresent completion:(void (^)(void))completion dismiss:(void (^)(void))dismiss
{
    UIViewController *presentedVc = objc_getAssociatedObject(self, kAssetsPopPresentedController);
    BOOL isAnimating = [objc_getAssociatedObject(self, kAssetsPopAnimating) boolValue];
    if (isAnimating) {
        return;
    }
    else if (presentedVc) {
       return [self dismissPopViewControllerCompletion:nil];
    }
    UIView * target = [self view];
    UIView *contentView = viewControllerToPresent.view;

    if ([target.subviews containsObject:contentView]) { return ;}
    
    objc_setAssociatedObject(self, kAssetsPopPresentedController, viewControllerToPresent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kAssetsDismissBlock, dismiss, OBJC_ASSOCIATION_COPY_NONATOMIC);

    [self addChildViewController:viewControllerToPresent];

//    CGFloat contentViewHeight = CGRectGetHeight(contentView.bounds);
    
    CGRect contentViewAnimatedFrame = CGRectMake(0, 0, CGRectGetWidth(contentView.bounds), CGRectGetHeight(contentView.bounds));

    UIView *overlayView = [[UIView alloc] initWithFrame:target.bounds];
    overlayView.tag = kOverlayViewTag;
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = .5;
    overlayView.userInteractionEnabled = YES;
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [target addSubview:overlayView];
    
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    overlayView.tag = kOverlayViewTag;
    [dismissButton addTarget:self action:@selector(dismissPopViewController) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.backgroundColor = [UIColor clearColor];
//    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dismissButton.frame = overlayView.frame;
    [overlayView addSubview:dismissButton];
    
//    contentView.frame = CGRectOffset(contentViewAnimatedFrame, 0, -contentViewHeight);
    contentView.frame = CGRectMake(0, 0, CGRectGetWidth(contentView.bounds), 0);
    
    contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    contentView.layer.shadowOffset = CGSizeMake(0, -2);
    contentView.layer.shadowRadius = 5.0;
    contentView.layer.shadowOpacity = 0.8;
    contentView.layer.shouldRasterize = YES;
    contentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
//    contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [target addSubview:contentView];

    objc_setAssociatedObject(self, kAssetsPopAnimating, @(YES), OBJC_ASSOCIATION_ASSIGN);
    
    dispatch_block_t animation = ^{
        contentView.frame = contentViewAnimatedFrame;
    };
    
    dispatch_block_t finishedBlock = ^{
        objc_setAssociatedObject(self, kAssetsPopAnimating, @(NO), OBJC_ASSOCIATION_ASSIGN);
        [viewControllerToPresent didMoveToParentViewController:self];
    };
#if ASSETS_USE_SPRING
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:.0 options:UIViewAnimationOptionCurveLinear animations:^{
        animation();
    } completion:^(BOOL finished) {
        if (finished) {
            finishedBlock();
        }
    }];
#else
    [UIView animateWithDuration:0.3 animations:^{
        animation();
    } completion:^(BOOL finished) {
        if (finished) {
            finishedBlock();
        }
    }];
#endif
    
    if (completion) {
        completion();
    }
}

- (void)dismissPopViewController
{
    return [self dismissPopViewControllerCompletion:nil];
}

- (void)dismissPopViewControllerCompletion:(void (^)(void))completion
{
    BOOL isAnimating = [objc_getAssociatedObject(self, kAssetsPopAnimating) boolValue];
    if (isAnimating) {
        return;
    }
    
    UIViewController *presentedVc = objc_getAssociatedObject(self, kAssetsPopPresentedController);
    UIView * target = [self view];

    UIView * overlayView = [target viewWithTag:kOverlayViewTag];
    UIView * contentView = [presentedVc view];

    [presentedVc willMoveToParentViewController:nil];
    
    objc_setAssociatedObject(self, kAssetsPopAnimating, @(YES), OBJC_ASSOCIATION_ASSIGN);
    
    dispatch_block_t dismissBlock = objc_getAssociatedObject(self, kAssetsDismissBlock);
    if (dismissBlock) {
        dismissBlock();
    }
    
    dispatch_block_t animation = ^{
        overlayView.alpha = 0.0;
        contentView.frame = CGRectOffset(contentView.frame, 0, -CGRectGetHeight(contentView.frame));
    };
    
    dispatch_block_t finishedBlock = ^{
        [overlayView removeFromSuperview];
        [contentView removeFromSuperview];
        [presentedVc removeFromParentViewController];
        
        if (completion) {
            completion();
        }
        objc_setAssociatedObject(self, kAssetsPopAnimating, @(NO), OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(self, kAssetsPopPresentedController, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, kAssetsDismissBlock, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    };
    

#if ASSETS_USE_SPRING
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:.0 options:UIViewAnimationOptionCurveLinear animations:^{
        animation();
    } completion:^(BOOL finished) {
        if (finished) {
            finishedBlock();
        }
    }];
#else
    [UIView animateWithDuration:0.3 animations:^{
        animation();
    } completion:^(BOOL finished) {
        if (finished) {
            finishedBlock();
        }
    }];
#endif
}

@end
