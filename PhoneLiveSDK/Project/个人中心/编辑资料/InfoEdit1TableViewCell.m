


#import "InfoEdit1TableViewCell.h"
#import "LiveUser.h"
#import "Config.h"
#import "UIImageView+WebCache.h"
@implementation InfoEdit1TableViewCell
-(void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx,1);
    CGContextSetStrokeColorWithColor(ctx,[UIColor groupTableViewBackgroundColor].CGColor);
    CGContextMoveToPoint(ctx,0,self.frame.size.height);
    CGContextAddLineToPoint(ctx,(self.frame.size.width),self.frame.size.height);
    CGContextStrokePath(ctx);
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    
    return self;
    
}

+(InfoEdit1TableViewCell *)cellWithTableView:(UITableView *)tableView{
    InfoEdit1TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editCell1"];
    
    if (!cell) {
        cell = [[XBundle currentXibBundleWithResourceName:@"editCell1"] loadNibNamed:@"editCell1" owner:self options:nil].lastObject;
        cell.labLeftName.text = YZMsg(@"InfoEdit1TableViewCell_Avatar");
        cell.labLeftName.textColor = RGB_COLOR(@"#333333", 1);
        cell.imgRight.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return cell;
    
    
}
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    LiveUser *user = [[LiveUser alloc] init];
    user =  [Config myProfile];
    NSURL *url = [NSURL URLWithString:user.avatar];
    
    [self.imgRight sd_setImageWithURL:url placeholderImage:self.imgRight.image?self.imgRight.image:nil];
}

@end
