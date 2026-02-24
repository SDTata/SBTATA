
#import "sexCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "LiveUser.h"
#import "Config.h"
@implementation sexCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.sexLabel.text = YZMsg(@"sexCell_Sexy");
}

+(sexCell *)cellWithTableView:(UITableView *)tableView{
    sexCell *cell = [tableView dequeueReusableCellWithIdentifier:@"edimMySex.xib"];
    if (!cell) {
        cell = [[XBundle currentXibBundleWithResourceName:@"edimMySex"]loadNibNamed:@"edimMySex" owner:self options:nil].lastObject;
        LiveUser *user = [Config myProfile];
        if ([minstr(user.sex) isEqualToString:@"1"]) {
            cell.imageV.image = [ImageBundle imagewithBundleName:@"choice_sex_nanren"];
        }
        else{
            cell.imageV.image = [ImageBundle imagewithBundleName:@"choice_sex_nvren"];
        }
    }
    return cell;
    
    
}
@end
