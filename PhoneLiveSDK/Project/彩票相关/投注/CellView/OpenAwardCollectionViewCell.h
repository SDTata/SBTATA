//
//  OpenAwardCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface OpenAwardCollectionViewCell : UICollectionViewCell<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *issueLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *dateTitleLabel;

@property (nonatomic, strong) NSDictionary *allData;
@property (nonatomic, assign) NSInteger curLotteryType;
@property (nonatomic, assign) NSInteger selectType;

@property (nonatomic, assign) BOOL bIsInit;

-(void)setOpenAwardData:(NSInteger) lotteryType openData:(NSDictionary *)openData selectType:(NSInteger)selectType;
//-(void)setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType extinfo:(id)extinfo;

@end
