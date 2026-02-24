//
//  AddTagsViewController.m
//  phonelive2
//
//  Created by Co co on 2024/7/17.
//  Copyright © 2024 toby. All rights reserved.
//

#import "AddTagsViewController.h"
#import "CachePostVideo.h"
@interface AddTagsViewController ()
{
    NSArray *selectedAllIds;
    int pageNum;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@end

@implementation AddTagsViewController

-(void)navigation{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, (ShowDiff>0?ShowDiff:20) + 44)];
    navtion.backgroundColor = [UIColor clearColor];
   
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(8, ShowDiff>0?ShowDiff:20,40,44);

//    [returnBtn setHighlighted:YES];
//    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"person_back_black"] forState:UIControlStateNormal];
//    [returnBtn setBackgroundImage:[UIImage sd_imageWithColor:[UIColor clearColor] size:CGSizeMake(40, 44)]];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-180)/2.0, ShowDiff>0?ShowDiff:20, 180, 44)];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = YZMsg(@"PostVideo_sub_title5");
    [navtion addSubview:titleLabel];
    [self.view addSubview:navtion];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    pageNum = 1;
    [self navigation];
    [self.sureButton setTitle:YZMsg(@"Livebroadcast_order_confirm") forState:UIControlStateNormal];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
    selectedAllIds = [[CachePostVideo sharedManager]getAllOthertagids];
    
   
    //去掉第一条数据
    if (self.datas.count>= 10) {
        [self getTagsInfo];
    }else{
        [self showTagsDefault];
    }
   
}


-(void)getTagsInfo{

    pageNum = pageNum+1;
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"ShortVideo.getTopicList" withBaseDomian:YES andParameter:@{@"p":minnum(pageNum)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0 && [info isKindOfClass:[NSArray class]]) {
            NSArray *arrayTags = info;
            if (arrayTags.count>0) {
                if (strongSelf.datas == nil) {
                    strongSelf.datas = [NSMutableArray array];
                }
                [strongSelf.datas addObjectsFromArray:arrayTags];
                [strongSelf getTagsInfo];
            }else{
                [strongSelf showTagsDefault];
            }
            
        } else {
            [strongSelf showTagsDefault];
            
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf showTagsDefault];
    }];
    
}

-(void)showTagsDefault
{
    NSMutableArray *tags = [NSMutableArray arrayWithArray:self.datas];
    if (tags.count>1) {
        [tags removeObjectAtIndex:0];
    }else{
        return;
    }
    
    UIView *lastV = nil;
    for (int i = 0; i<tags.count; i++) {
        NSDictionary *hotDic = tags[i];
        UILabel * labelHot = [UILabel new];
        labelHot.textColor = [UIColor blackColor];
        labelHot.font = [UIFont systemFontOfSize:13];
        labelHot.text  = hotDic[@"name"];
        [self.contentView addSubview:labelHot];
        
        [labelHot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(5);
            make.top.mas_equalTo((lastV!=nil?lastV.mas_bottom:self.contentView.mas_top)).offset(10);
        }];
        
        
        NSArray *arrayTagsHot = [hotDic objectForKey:@"children"];
        if (arrayTagsHot!= nil && arrayTagsHot.count>0) {
            lastV =  [self showHotTags:arrayTagsHot lastView:labelHot isLast:i==tags.count-1];
        }else{
            lastV = labelHot;
        }
    }
}

-(void)addMoreData:(NSArray*)tags
{
    
}


-(UIView*)showHotTags:(NSArray*)tagsHot lastView:(UIView*)lastView isLast:(BOOL)isLast {
    [self.view layoutIfNeeded];

    if (tagsHot != nil && tagsHot.count > 0) {
        UIView *theLastV = lastView;
        UIView *previousLabel = nil;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat horizontalPadding = 10;
        CGFloat verticalPadding = 10;
        CGFloat currentX = horizontalPadding; // 当前X坐标
        CGFloat currentY = CGRectGetMaxY(lastView.frame) + verticalPadding; // 当前Y坐标

        for (int i = 0; i < tagsHot.count; i++) {
            NSDictionary *subDicTag = tagsHot[i];
            NSString *tagName = subDicTag[@"name"];
            NSString *tagId = subDicTag[@"id"];

            UILabel *labelTag = [UILabel new];
            labelTag.font = [UIFont systemFontOfSize:12];
            labelTag.backgroundColor = [UIColor whiteColor];
            labelTag.layer.cornerRadius = 13;
            labelTag.clipsToBounds = YES;
            labelTag.layer.borderColor = [UIColor orangeColor].CGColor;
            labelTag.layer.borderWidth = 0.5;
            labelTag.userInteractionEnabled = YES;
            [labelTag vk_addTapAction:self selector:@selector(labelClick:)];
            labelTag.text = [NSString stringWithFormat:@"  #%@", tagName];
            labelTag.tag = [tagId integerValue];
            labelTag.textColor = [UIColor blackColor];
            [self.contentView addSubview:labelTag];
            
            if ([selectedAllIds containsObject:tagId]) {
                labelTag.backgroundColor = RGB(50, 4, 56);
                labelTag.textColor = [UIColor whiteColor];
            }
            
            // Calculate label size
            CGSize labelSize = [labelTag sizeThatFits:CGSizeMake(CGFLOAT_MAX, 26)];
            labelTag.frame = CGRectMake(0, 0, labelSize.width + 10, 26);

            // Check if the label fits in the current row
            if (currentX + labelTag.frame.size.width > screenWidth - horizontalPadding) {
                // Move to the next row
                currentX = horizontalPadding;
                currentY += labelTag.frame.size.height + verticalPadding;
            }
            if (i == tagsHot.count - 1 && isLast) {
                // Set label frame
                [labelTag mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(currentX);
                    make.top.mas_equalTo(currentY);
                    make.width.mas_equalTo(labelTag.frame.size.width);
                    make.height.mas_equalTo(labelTag.frame.size.height);
                    make.bottom.mas_equalTo(self.contentView.bottom).offset(-50);
                }];
            }else{
                // Set label frame
                [labelTag mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(currentX);
                    make.top.mas_equalTo(currentY);
                    make.width.mas_equalTo(labelTag.frame.size.width);
                    make.height.mas_equalTo(labelTag.frame.size.height);
                    
                }];
            }
           

            // Update currentX for the next label
            currentX += labelTag.frame.size.width + horizontalPadding;

            previousLabel = labelTag;

            if (i == tagsHot.count - 1) {
                theLastV = labelTag;
            }
        }

        [self.view layoutIfNeeded];
        return theLastV;
    } else {
        return lastView;
    }
}
-(void)labelClick:(UITapGestureRecognizer*)subLabe
{
    UILabel *subTpV =  (UILabel*)subLabe.view;
    NSInteger tagClick  = subTpV.tag;
    NSDictionary *subDic = @{@"name":[subTpV.text substringFromIndex:3],@"id":minnum(tagClick)};
    
    if (subTpV.backgroundColor== [UIColor whiteColor]) {
        subTpV.backgroundColor = RGB(50, 4, 56);
        subTpV.textColor = [UIColor whiteColor];
        
        [self addTagInselectedTags:subDic];
    }else{
        subTpV.backgroundColor = [UIColor whiteColor];
        subTpV.textColor = [UIColor blackColor];
        [self removeTagInselectedTags:subDic];
    }
    
    
}
-(void)addTagInselectedTags:(NSDictionary*)tagDic
{
    if([CachePostVideo sharedManager].selectedOtherTags == nil){
        [CachePostVideo sharedManager].selectedOtherTags = [NSMutableArray array];
    }
    NSInteger tagDicid = [tagDic[@"id"] integerValue];
    BOOL isContent = false;
    for (NSDictionary *subDic in [CachePostVideo sharedManager].selectedOtherTags) {
        NSInteger tagsC = [subDic[@"id"] integerValue];
        if (tagDicid == tagsC) {
            isContent = true;
            break;
        }
    }
    if (!isContent) {
        [[CachePostVideo sharedManager].selectedOtherTags addObject:tagDic];
    }
    if (self.delelgate) {
        [self.delelgate addOtherTags:[CachePostVideo sharedManager].selectedOtherTags];
    }
}

-(void)removeTagInselectedTags:(NSDictionary*)tagDic
{
    if([CachePostVideo sharedManager].selectedOtherTags == nil){
        [CachePostVideo sharedManager].selectedOtherTags = [NSMutableArray array];
    }
    NSInteger tagDicid = [tagDic[@"id"] integerValue];
    NSDictionary *contentDIc;
    for (NSDictionary *subDic in [CachePostVideo sharedManager].selectedOtherTags) {
        NSInteger tagsC = [subDic[@"id"] integerValue];
        if (tagDicid == tagsC) {
            contentDIc = subDic;
            break;
        }
    }
    if (contentDIc) {
        [[CachePostVideo sharedManager].selectedOtherTags removeObject:contentDIc];
    }
    if (self.delelgate) {
        [self.delelgate addOtherTags:[CachePostVideo sharedManager].selectedOtherTags];
    }
}
- (IBAction)sureAction:(id)sender {
    
}

@end
