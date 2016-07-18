//
//  ViewController.m
//  AssetsImagePickerDemo
//
//  Created by WangBin on 16/7/18.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import "AssetsDemoViewController.h"
#import "AssetsImagePicker.h"

@interface AssetsDemoViewController ()<AssetsImagePickerProtocol>
@property (weak, nonatomic) IBOutlet UIButton *assetsBtn;

@end

@implementation AssetsDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.assetsBtn];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - events

- (IBAction)assetsBtnOnTouched:(UIButton *)sender {
    [AssetsImagePicker picker:self fromViewController:self.navigationController];
}

- (void)assetsImagePickerDidSeletedAssets:(id)assets
{
    // TODO... handle the selected assets...
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
