//
//  TaskTableVC.m
//  phonelive
//
//  Created by 400 on 2020/9/22.
//  Copyright © 2020 toby. All rights reserved.
//

#import "TaskTableVC.h"
#import "TaskContentCell.h"
#import "LiveTaskContentCell.h"
@interface TaskTableVC ()

@end

@implementation TaskTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //使用重用机制，IDENTIFIER作为重用机制查找的标识，tableview查找可用cell时通过IDENTIFIER检索，如果有则cell不为nil
    if ([self.type isEqualToString:@"1"]) {
        static NSString * Identifier=@"LiveTaskContentCell";
        LiveTaskContentCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (!cell) {
            cell=[[[XBundle currentXibBundleWithResourceName:@"LiveTaskContentCell"] loadNibNamed:@"LiveTaskContentCell" owner:self options:nil] lastObject];
        }
        WeakSelf
        cell.taskCallback = ^(NSInteger taskID) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.delelgate) {
                [strongSelf.delelgate taskJumpWithTaskID:taskID];
            }
        };
        cell.model = self.models[indexPath.row];
        return cell;
    }else{
        static NSString * Identifier=@"TaskContentCell";
        TaskContentCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (!cell) {
            cell=[[[XBundle currentXibBundleWithResourceName:@"TaskContentCell"] loadNibNamed:@"TaskContentCell" owner:self options:nil] lastObject];
        }
        WeakSelf
        cell.taskCallback = ^(NSInteger taskID) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.delelgate) {
                [strongSelf.delelgate taskJumpWithTaskID:taskID];
            }
        };
        cell.model = self.models[indexPath.row];
        return cell;
    }

}



@end
