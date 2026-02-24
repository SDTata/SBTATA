//
//  ShowDropDownTextField.m
//  phonelive2
//
//  Created by s5346 on 2024/2/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShowDropDownTextField.h"

@interface ShowDropDownTextField() <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *defaultMails;
    NSArray *changeMails;
    CGFloat errorHeight;
    CGFloat keyboardHeight;
}
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ShowDropDownTextField

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self.tableView removeFromSuperview];
    [self.errorLabel removeFromSuperview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    keyboardHeight = 0;
    [self addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    self.tableView.hidden = true;
    return true;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self buildSearchTableView];
}

- (void)textFieldDidChange {
    if (!self.isNeedShowDropDown) {
        return;
    }
    [self filter];
    [self updateSearchTableView];
    self.tableView.hidden = self.text.length <= 0;
}

- (void)buildSearchTableView {
    if (self.tableView != nil) {
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.window addSubview:self.tableView];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

        errorHeight = 20;
        defaultMails = @[@"@gmail.com", @"@yahoo.com",@"@qq.com",@"@163.com", @"@hotmail.com", @"@outlook.com", @"@aol.com",@"@msn.com",@"@live.com",@"@mail.com",@"@126.com",@"@sina.com",@"@21cn.com",@"@sohu.com",@"@hn.vnn.vn",@"@hcm.fpt.vn",@"@hcm.vnn.vn",@"@dnet.net.id",@"@sinos.net"];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.allowsSelection = true;

        self.errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.errorLabel.textColor = [UIColor redColor];
        self.errorLabel.font = [UIFont systemFontOfSize:14];
        [self.window addSubview:self.errorLabel];
    }

    [self updateSearchTableView];
}

- (void)updateErrorLabelFrame {
    CGRect rect = self.bounds;
    rect.origin.y = CGRectGetMaxY(rect);
    rect.size.height = errorHeight;
    rect.origin = [self convertPoint:rect.origin toView:nil];
    self.errorLabel.frame = rect;
}

- (void)updateSearchTableView {
    [self updateErrorLabelFrame];

    if (self.tableView == nil) {
        return;
    }

    [self.superview bringSubviewToFront:self.tableView];
    CGFloat tableHeight = 0;
    tableHeight = self.tableView.contentSize.height;

    if (tableHeight < self.tableView.contentSize.height) {
        tableHeight -= 10;
    }

    CGFloat tableViewFrameY = 0;
    if (self.errorLabel.text.length > 0) {
        tableViewFrameY = errorHeight;
    }

    CGRect tableViewFrame = CGRectMake(0, tableViewFrameY, self.frame.size.width - 4, tableHeight);
    tableViewFrame.origin = [self convertPoint:tableViewFrame.origin toView:nil];
    tableViewFrame.origin.x += 2;
    tableViewFrame.origin.y += self.frame.size.height + 2;

    CGFloat tableBottom = CGRectGetMaxY(tableViewFrame);
    CGFloat keyboardTop = CGRectGetHeight([[UIScreen mainScreen] bounds]) - keyboardHeight;
    CGFloat space = tableBottom - keyboardTop;
    if (space > 0) {
        tableViewFrame.size.height -= space;
    }

    WeakSelf;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.tableView.frame = tableViewFrame;
    }];

    self.tableView.layer.masksToBounds = true;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.layer.cornerRadius = 5.0;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];

    if ([self isFirstResponder]) {
        [self.superview bringSubviewToFront:self];
    }

    [self.tableView reloadData];
}

- (void)filter {
    NSArray *textArray = [self.text componentsSeparatedByString:@"@"];
    NSString *prefixText = @"";
    if (textArray.count >= 1) {
        for (int i = 0; i<textArray.count; i++) {
            if (textArray.count > 1 && textArray.count - 1 == i) {
                break;
            }
            if (i == 0) {
                prefixText = [prefixText stringByAppendingString:textArray[i]];
            } else {
                prefixText = [prefixText stringByAppendingFormat:@"@%@", textArray[i]];
            }
        }
    }
    NSString *sufixText = @"";
    if (textArray.count > 1) {
        sufixText = [textArray lastObject];
    }
    if (prefixText.length <= 0) {
        return;
    }

    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *mail in defaultMails) {
        if (sufixText.length > 0) {
            NSRange range = [mail rangeOfString:sufixText];
            if (range.location != 1) {
                continue;
            }
        }
        [tempArray addObject:[NSString stringWithFormat:@"%@%@", prefixText, mail]];
    }
    changeMails = tempArray;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 將鍵盤的高度獲取出來
    keyboardHeight = CGRectGetHeight(keyboardFrame);

    // 在這裡可以使用鍵盤的高度來進行相應的邏輯處理
    NSLog(@"鍵盤高度：%f", keyboardHeight);
    [self updateSearchTableView];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    keyboardHeight = 0;
    [self updateSearchTableView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return changeMails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if (changeMails.count > indexPath.row) {
        cell.textLabel.text = changeMails[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (changeMails.count <= indexPath.row) {
        return;
    }
    self.text = changeMails[indexPath.row];
    tableView.hidden = true;
    [self endEditing:true];

    if ([self.dropDownDelegate respondsToSelector:@selector(showDropDownTextFieldForSelected)]) {
        [self.dropDownDelegate showDropDownTextFieldForSelected];
    }
}
@end
