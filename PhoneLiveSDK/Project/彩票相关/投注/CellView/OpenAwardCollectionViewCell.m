//
//  OpenAwardCollectionViewCell.m
//

#import "OpenAwardCollectionViewCell.h"
#import "IssueCollectionViewCell2.h"

#define kIssueCollectionViewCell2 @"IssueCollectionViewCell2"

@implementation OpenAwardCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.dateTitleLabel.text = YZMsg(@"OpenAward_dateTitle");
    [self initCollection];
    self.bIsInit = true;
}

//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//}
-(void)setOpenAwardData:(NSInteger) lotteryType openData:(NSDictionary *)openData selectType:(NSInteger)selectType{
    self.selectType = selectType;
    self.curLotteryType = lotteryType;
    self.allData = openData;
    
    self.issueLabel.text = self.allData[@"issue"];
    if(self.bIsInit){
        if(self.selectType > 1){
            UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.openResultCollectionView.collectionViewLayout;
            if([GameToolClass isSC:self.curLotteryType]){
                flowLayout.minimumInteritemSpacing = 1.f;//左右间隔
            }else{
                flowLayout.minimumInteritemSpacing = 1.f;//左右间隔
            }
            flowLayout.minimumLineSpacing = 0.f;
        }else{
            UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.openResultCollectionView.collectionViewLayout;
            flowLayout.minimumInteritemSpacing = 1.0f;//左右间隔
            flowLayout.minimumLineSpacing = 0.f;
        }
        [self.openResultCollectionView reloadData];
    }
}

-(void)resetDisplay{
    if(self.bIsInit){
        [self.openResultCollectionView reloadData];
    }
}

- (void)initCollection {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing=0.f;//左右间隔
    flowLayout.minimumLineSpacing=0.f;
//    float leftMargin =0;
    
    self.openResultCollectionView.delegate = self;
    self.openResultCollectionView.dataSource = self;
    self.openResultCollectionView.collectionViewLayout = flowLayout;
    self.openResultCollectionView.allowsMultipleSelection = YES;

    UINib *nib=[UINib nibWithNibName:kIssueCollectionViewCell2 bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultCollectionView registerNib: nib forCellWithReuseIdentifier:kIssueCollectionViewCell2];
    
    self.openResultCollectionView.backgroundColor=[UIColor clearColor];
}

-(NSInteger) getItemCountByLotteryType:(NSInteger)lottery{
    NSArray *open_result = [self.allData[@"open_result"] componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if([GameToolClass isLHC:lottery]){
        result_count = result_count + 1;
    }
    return result_count;
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.selectType > 1 && self.allData[@"results_data"]){
        NSArray *results_data = self.allData[@"results_data"];
        return results_data.count;
    }else{
        if(!self.allData || !self.allData[@"open_result"]){
            return 0;
        }
        NSInteger result_count = [self getItemCountByLotteryType:self.curLotteryType];
        return result_count;
    }
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IssueCollectionViewCell2 *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kIssueCollectionViewCell2 forIndexPath:indexPath];
    
    if(self.selectType > 1 && self.allData[@"results_data"]){
        [self setAnalysisCell:cell indexPath:indexPath];
    }else{
        [self setNormalCell:cell indexPath:indexPath];
    }
    
    return cell;
}

- (void)setAnalysisCell:(IssueCollectionViewCell2 *)cell indexPath:(NSIndexPath *)indexPath{
    NSArray *results_data = self.allData[@"results_data"];
    NSString *resultStr = [results_data objectAtIndex:indexPath.row];
    
    [cell setAnalysis:resultStr];
}

- (void)setNormalCell:(IssueCollectionViewCell2 *)cell indexPath:(NSIndexPath *)indexPath{
    NSArray *open_result = [self.allData[@"open_result"] componentsSeparatedByString:@","];
    __block NSString *resultStr = @"";
    __block  NSMutableArray *extInfo = [NSMutableArray array];
    
    dispatch_main_async_safe((^{
        if([GameToolClass isLHC:self.curLotteryType]){
            if(indexPath.row == 6){
                resultStr = @"+";
            }else if (indexPath.row == 7){
                resultStr = [open_result objectAtIndex:6];
            }else{
                resultStr = [open_result objectAtIndex:indexPath.row];
            }
            extInfo = [NSMutableArray arrayWithArray:self.allData[@"spare_2"]];
            [extInfo insertObject:@"" atIndex: 6];
        }else if([GameToolClass isKS:self.curLotteryType]){
            resultStr = [open_result objectAtIndex:indexPath.row];
            extInfo = [NSMutableArray arrayWithArray:self.allData[@"spare_2"]];
            [extInfo insertObject:@"" atIndex: 6];
        }else{
            resultStr = [open_result objectAtIndex:indexPath.row];
        }
        
        [cell setNumber:resultStr lotteryType:self.curLotteryType extinfo:@{@"index":[NSString stringWithFormat:@"%ld", indexPath.row], @"info":extInfo}];
    }));
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if(self.selectType > 1){
        NSArray *results_data = self.allData[@"results_data"];
        NSString *resultStr = [results_data objectAtIndex:indexPath.row];
        CGFloat labelW = [[YBToolClass sharedInstance] widthOfString:minstr(resultStr) andFont:[UIFont systemFontOfSize:14.f] andHeight:30];
        return CGSizeMake(ceil(labelW*1.0) + 10, 25);
    }
    if([GameToolClass isLHC:self.curLotteryType]){
        return CGSizeMake(25, 35);
    }
    if([GameToolClass isSC:self.curLotteryType]){
        return CGSizeMake(25, 35);
    }
    return CGSizeMake(35, 35);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectType > 1){
        NSArray *results_data = self.allData[@"results_data"];
        NSString *resultStr = [results_data objectAtIndex:indexPath.row];
        CGFloat labelW = [[YBToolClass sharedInstance] widthOfString:minstr(resultStr) andFont:[UIFont systemFontOfSize:14.f] andHeight:30];
        return CGSizeMake(ceil(labelW*1.0) + 10, 25);
    }
    if([GameToolClass isLHC:self.curLotteryType]){
        return CGSizeMake(25, 35);
    }
    if([GameToolClass isSC:self.curLotteryType]){
        return CGSizeMake(25, 35);
    }
    return CGSizeMake(35, 35);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat left = 0;
    CGFloat right = 0;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.openResultCollectionView.collectionViewLayout;
    CGFloat spacing = flowLayout.minimumInteritemSpacing; //左右间隔
    
    if(self.selectType > 1){
        NSArray *results_data = self.allData[@"results_data"];
        CGFloat totalW = 0;
        for (int i = 0; i < results_data.count; i++) {
            NSString *resultStr = [results_data objectAtIndex:i];
            CGFloat labelW = [[YBToolClass sharedInstance] widthOfString:minstr(resultStr) andFont:[UIFont systemFontOfSize:14.f] andHeight:30];
            CGFloat signalItemW = ceil(labelW*1.0) + 10;

            totalW += (signalItemW + spacing * 1.5);
        }

//        left = (self.openResultCollectionView.width - totalW) / 2;
        right = left;
        return UIEdgeInsetsMake(9, left, 9, right);
    }
    
    NSInteger result_count = [self getItemCountByLotteryType:self.curLotteryType];
//    if([GameToolClass isLHC:self.curLotteryType]){
//        left = (self.openResultCollectionView.width - (25 + spacing * 1.5) * result_count) / 2;
//    }else if([GameToolClass isSC:self.curLotteryType]){
//        left = (self.openResultCollectionView.width - (25 + spacing * 1.5) * result_count) / 2;
//    }else{
//        left = (self.openResultCollectionView.width - (35 + spacing * 1.5) * result_count) / 2;
//    }
    right = left;
    return UIEdgeInsetsMake(4, left, 4, right);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={0,0};
    return size;
}

@end
