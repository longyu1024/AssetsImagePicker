//
//  AssetsTableViewController.m
//  ImageAssert
//
//  Created by WangBin on 16/6/27.
//  Copyright © 2016年 WangBin. All rights reserved.
//

#import "AssetsImagePickerGroupController.h"
#import "AssetsImagePickerTableViewCell.h"

@interface AssetsImagePickerGroupController ()

@end

@implementation AssetsImagePickerGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    for (NSUInteger index = 0; index < self.assetsGroups.count;index++) {
        ALAssetsGroup *group = self.assetsGroups[index];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if (group == self.selectedGroup) {
            [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AssetsImagePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"assetsGroupCell"];
    ALAssetsGroup *group = self.assetsGroups[indexPath.row];
    NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
    NSInteger groupAmounts = [group numberOfAssets];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@  %@",groupName,@(groupAmounts)];

    UIImage *poster = [UIImage imageWithCGImage:group.posterImage];
    cell.coverImageView.image = poster;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ALAssetsGroup *group = self.assetsGroups[indexPath.row];
    if ([self.assetsDelegate respondsToSelector:@selector(assetsDidSelectedGroup:)]) {
        [self.assetsDelegate assetsDidSelectedGroup:group];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
