//
//  PayInsteadCollectionViewCell.h
//

#import <UIKit/UIKit.h>

@interface PayInsteadCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quotaLabel;

@property (weak, nonatomic) IBOutlet UIButton *QQBtn;
@property (weak, nonatomic) IBOutlet UIButton *weChatBtn;
@property (weak, nonatomic) IBOutlet UIButton *aliPayBtn;
@property (weak, nonatomic) IBOutlet UILabel *QQLabel;
@property (weak, nonatomic) IBOutlet UILabel *weChatLabel;
@property (weak, nonatomic) IBOutlet UILabel *aliPayLabel;
@property (weak, nonatomic) IBOutlet UILabel *edutitleLable;

@property(nonatomic,strong) NSString *QQ;
@property(nonatomic,strong) NSString *weChat;
@property(nonatomic,strong) NSString *alipay;

- (void)setBtnEnable:(BOOL)enable;
@end
