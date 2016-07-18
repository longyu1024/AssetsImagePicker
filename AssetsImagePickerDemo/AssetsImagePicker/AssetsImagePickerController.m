//
//  ImageAssertController.m
//  ImageAssert
//
//  Created by WangBin on 16/6/27.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import "AssetsImagePickerController.h"
#import "AssetsImagePickerGroupController.h"
#import "AssetsImagePickerCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIViewController+AssetsPop.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface AssetsImagePickerController ()<AssetsImagePickerGroupControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong,nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSArray *assetsGroups;
@property (strong, nonatomic) ALAssetsGroup *selectedGroup;
@property (strong, nonatomic) NSArray  *selectedGroupAssets;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
@implementation AssetsImagePickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    CGFloat minimumLineSpacing = 10;
    CGFloat minimumInteritemSpacing = 8;
    
    [collectionViewLayout setSectionInset:sectionInset];
    [collectionViewLayout setMinimumLineSpacing:minimumLineSpacing];
    [collectionViewLayout setMinimumInteritemSpacing:minimumInteritemSpacing];

    CGFloat cellW = (screenW - sectionInset.left - sectionInset.right - minimumInteritemSpacing*2)/3 - 10;
  
    [collectionViewLayout setItemSize:CGSizeMake(lrint(cellW), lrint(cellW))];


    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    _assetsGroups = [NSMutableArray array];
    
    if (![self assetsAccessable:NO]) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    __block NSMutableArray *assetsGroups = [NSMutableArray array];

    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if (group.numberOfAssets) {
                [assetsGroups addObject:group];
            }
        }else{
            NSArray *sortedAssetsGroups = [assetsGroups sortedArrayUsingComparator:^NSComparisonResult(ALAssetsGroup * obj1, ALAssetsGroup * obj2) {
                
                NSNumber *propertyType1 = [obj1 valueForProperty:ALAssetsGroupPropertyType];
                NSNumber *propertyType2 = [obj2 valueForProperty:ALAssetsGroupPropertyType];
                if ([propertyType1 compare:propertyType2] == NSOrderedAscending)
                {
                    return NSOrderedDescending;
                }
                return NSOrderedSame;
            }];
            
            weakself.assetsGroups = sortedAssetsGroups;
            weakself.selectedGroup = sortedAssetsGroups.firstObject;
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Group not found!\n");
    }];
}

#pragma mark - Utils

- (BOOL)assetsAccessable:(BOOL)camera
{
    if (camera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        BOOL cameraDenied = (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied);
        
        if (cameraDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"警告", nil) message:NSLocalizedString(@"APP没有权限访问相机，您可以在“隐私设置”中启用访问", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"前往设置", nil) otherButtonTitles:NSLocalizedString(@"取消", nil), nil];
            [alert show];
            return NO;
        }
    }else{
        BOOL assetsLibraryDenied = YES;
        if ([[[UIDevice currentDevice] systemVersion] caseInsensitiveCompare:@"8.0"] != NSOrderedAscending) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            assetsLibraryDenied = status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied;
        }
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        assetsLibraryDenied = status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied;
        if (assetsLibraryDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"警告", nil) message:NSLocalizedString(@"APP没有权限访问相册，您可以在“隐私设置”中启用访问", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"前往设置", nil) otherButtonTitles:NSLocalizedString(@"取消", nil), nil];
            [alert show];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Events

- (void)setSelectedGroup:(ALAssetsGroup *)selectedGroup
{
    _selectedGroup = selectedGroup;
    
    if (selectedGroup) {
        UIButton *titleView = (UIButton *)self.navigationItem.titleView;
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[selectedGroup valueForProperty:ALAssetsGroupPropertyName] attributes:@{NSFontAttributeName:titleView.titleLabel.font,NSForegroundColorAttributeName:titleView.titleLabel.textColor}];
        [titleView setAttributedTitle:attr forState:UIControlStateNormal];
        
        [titleView setTitleEdgeInsets:UIEdgeInsetsMake(0, -titleView.imageView.image.size.width, 0, titleView.imageView.image.size.width)];
        [titleView setImageEdgeInsets:UIEdgeInsetsMake(0, attr.size.width, 0, -attr.size.width)];
        CGRect frame = titleView.frame;
        frame.size.width = attr.size.width + titleView.imageView.image.size.width;
        titleView.frame = frame;
        NSMutableArray *selectedGroupAssets = [NSMutableArray array];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [selectedGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [selectedGroupAssets insertObject:result atIndex:0];
                }
            }];
            [selectedGroupAssets insertObject:[NSNull null] atIndex:0];

            self.selectedGroupAssets = selectedGroupAssets;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        });
    }
}

- (IBAction)goBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchAction:(UIButton *)sender {
    AssetsImagePickerGroupController *assetsTvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AssetsTableViewController"];
    CGRect targetFrame = assetsTvc.view.frame;
    
    CGFloat h = MAX(self.assetsGroups.count, 3)*60 + 20;
    
    targetFrame.size.height = MIN([UIScreen mainScreen].bounds.size.height*0.5, h);
    assetsTvc.view.frame = targetFrame;
    assetsTvc.assetsDelegate = self;
    assetsTvc.assetsGroups = self.assetsGroups;
    assetsTvc.selectedGroup = self.selectedGroup;

    [self popPresentViewController:assetsTvc completion:^{
        sender.selected = YES;
    } dismiss:^{
        sender.selected = NO;
    }];
}

#pragma mark - AssetsTableViewControllerDelegate

- (void)assetsDidSelectedGroup:(ALAssetsGroup *)group
{
    [self dismissPopViewControllerCompletion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
    self.selectedGroup = group;
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIApplication *app = [UIApplication sharedApplication];
        NSString *urlString = @"prefs:root=Privacy";
        if (&UIApplicationOpenSettingsURLString)
            urlString = UIApplicationOpenSettingsURLString;
        NSURL *sourceUrl = [NSURL URLWithString:urlString];
        if ([app canOpenURL:sourceUrl]) {
            [app openURL:sourceUrl];
        }
    }
}

#pragma mark - UIcCollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedGroupAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AssetsImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"assetsCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        cell.coverImageView.image = [UIImage imageNamed:@"assets_camera"];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        ALAsset *asset = self.selectedGroupAssets[indexPath.row];
        CGImageRef thumbnailImageRef = [asset aspectRatioThumbnail];
        cell.coverImageView.image = [UIImage imageWithCGImage:thumbnailImageRef];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if ([self assetsAccessable:YES]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
                imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            }else{
                imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
            }
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }else{
        ALAsset *asset = self.selectedGroupAssets[indexPath.row];
        if ([self.picker respondsToSelector:@selector(assetsImagePickerDidSeletedAssets:)]) {
            UIImage *sourceImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            [self.picker assetsImagePickerDidSeletedAssets:sourceImage];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *sourceImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        if ([self.picker respondsToSelector:@selector(assetsImagePickerDidSeletedAssets:)]) {
            [self.picker assetsImagePickerDidSeletedAssets:sourceImage];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
