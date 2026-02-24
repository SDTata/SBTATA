#import "ListCollection.h"
#import "listCell.h"
#import "listModel.h"
#import "Config.h"
@interface ListCollection ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    
}
@property (nonatomic, strong) dispatch_queue_t asyncLoadQueue;
@end
@implementation ListCollection
-(void)initarrayWithoutReload{
    self.listArray = [NSMutableArray array];
}
-(void)listArrayRemove{
    [self.listArray removeAllObjects];
}
-(void)changeFrame:(CGRect)rect{
    _listCollectionview.frame = rect;
}
-(void)initArray{
    self.listArray = nil;
    self.listArray = [NSMutableArray array];
    [_listCollectionview reloadData];
}
-(void)listarrayAddArray:(NSArray *)array{
    
    if (array!= nil && array.count>0) {
        WeakSelf
        dispatch_sync(self.asyncLoadQueue,^{
            STRONGSELF
            [strongSelf.listArray addObjectsFromArray:array];
            [strongSelf quickSort1:strongSelf.listArray];
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(reloadCollectionViews) object:nil];
            [strongSelf performSelector:@selector(reloadCollectionViews) withObject:nil afterDelay:2];
        });
    }
    
    
    
}
-(void)userAccess:(NSDictionary *)dic{
    WeakSelf
    dispatch_sync(self.asyncLoadQueue,^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSString *ID = [[dic valueForKey:@"ct"] valueForKey:@"id"];
        
        [strongSelf.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            for (NSDictionary *dic in strongSelf.listArray) {
                int a = [[dic valueForKey:@"id"] intValue];
                int bsss = [ID intValue];
                if ([[dic valueForKey:@"id"] isEqual:ID] || a == bsss) {
                    [strongSelf.listArray removeObject:dic];
                    break;
                }
            }
        }];
        NSDictionary *subdic = [dic valueForKey:@"ct"];
        
        
        [strongSelf.listArray addObject:subdic];
        [strongSelf quickSort1:strongSelf.listArray];
        [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(reloadCollectionViews) object:nil];
        [strongSelf performSelector:@selector(reloadCollectionViews) withObject:nil afterDelay:2];
    });
    
}
-(void)reloadCollectionViews{
    [_listCollectionview reloadData];
}

-(void)userLive:(NSDictionary *)dic{
    WeakSelf
    dispatch_sync(self.asyncLoadQueue,^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSDictionary *SUBdIC =[dic valueForKey:@"ct"];
        NSString *ID = [SUBdIC valueForKey:@"id"];
        [strongSelf.listArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            for (NSDictionary *dic in strongSelf.listArray) {
                if ([[dic valueForKey:@"id"] isEqual:ID]) {
                    [strongSelf.listArray removeObject:dic];
                    
                    [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(reloadCollectionViews) object:nil];
                    [strongSelf performSelector:@selector(reloadCollectionViews) withObject:nil afterDelay:2];
                    
                    break;
                    return ;
                }
            }
        }];
    });
}
//懒加载
-(NSArray *)listModelArray{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in self.listArray) {
        listModel *model = [listModel modelWithDic:dic];
        [array addObject:model];
    }
    _listModelArray = array;
    return _listModelArray;
}
//定时刷新用户列表
-(void)listReloadNoew{
    WeakSelf
    dispatch_sync(self.asyncLoadQueue,^{
        NSDictionary *userlist = @{
            @"liveuid":IDs,
            @"stream":stream
        };
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.getUserLists" withBaseDomian:YES andParameter:userlist data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                NSArray *infos = [info firstObject];
                NSArray *list = [infos valueForKey:@"userlist"];
                if ([list isEqual:[NSNull null]]) {
                    
                    return ;
                }
                [strongSelf listArrayRemove];
                for (int i =0; i<list.count; i++) {
                    NSDictionary *dic = [list objectAtIndex:i];
                    [strongSelf.listArray addObject:dic];
                }
                
                [strongSelf quickSort1:strongSelf.listArray];
                //            NSLog(@"%ld------%@",strongSelf.listArray.count,[info valueForKey:@"nums"]);
                [strongSelf.listCollectionview reloadData];
                
            }
        } fail:^(NSError * _Nonnull error) {
            
        }];
    });
    
}
-(instancetype)initWithListArray:(NSArray *)list andID:(NSString *)ID andStream:(NSString *)streams{
    self = [super init];
    if (self) {
        _asyncLoadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        IDs = [NSString stringWithFormat:@"%@",ID];
        stream = [NSString stringWithFormat:@"%@",streams];
        userCount =list.count;
        self.listArray = [NSMutableArray array];
        _listModelArray = [NSMutableArray array];
        if ([list isKindOfClass:[NSArray class]]) {
            self.listArray = [NSMutableArray arrayWithArray:list];
        }
        
        UICollectionViewFlowLayout *flowlayoutt = [[UICollectionViewFlowLayout alloc]init];
        flowlayoutt.itemSize = CGSizeMake(40,40);
        flowlayoutt.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _listCollectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0,_window_width- 130,40) collectionViewLayout:flowlayoutt];
        _listCollectionview.showsHorizontalScrollIndicator = NO;
        _listCollectionview.delegate = self;
        _listCollectionview.dataSource = self;
        [_listCollectionview registerClass:[listCell class] forCellWithReuseIdentifier:@"list"];
        _listCollectionview.backgroundColor = [UIColor clearColor];
        [self addSubview:_listCollectionview];
        
    }
    return self;
}
//用户列表
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.listModelArray.count;
}
//定义section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    listCell *cell = (listCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"list" forIndexPath:indexPath];
    //    if (cell == nil) {
    //        cell = [[[XBundle currentXibBundleWithResourceName:@"listCell"] loadNibNamed:@"listCell" owner:nil options:nil] lastObject];
    //    }
    listModel *model = self.listModelArray[indexPath.row];
    cell.model = model;
    cell.backgroundColor = [UIColor clearColor];
    //    if (indexPath.row == 0) {
    //        if ([model.contribution intValue]>0) {
    //            cell.kuang.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"userlist_no1"]];
    //        }else{
    //            cell.kuang.image = [UIImage new];
    //        }
    //    }
    if (indexPath.row < 3 && [model.contribution intValue]>0) {
        
        cell.kuang.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"userlist_no%ld",indexPath.row+1]];
    }else{
        cell.kuang.image = [UIImage new];
    }
    
    return cell;
}
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    listModel *model = [self.listModelArray objectAtIndex:indexPath.row];
    NSString *ID = model.userID;
    NSDictionary *subdic  = [NSDictionary dictionaryWithObjects:@[ID,model.user_nicename] forKeys:@[@"id",@"name"]];
    [self.delegate GetInformessage:subdic];
}
//每个cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(40,40);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,5,0,5);
}
-(void)quickSort1:(NSMutableArray *)userlist
{
    //    for (int i = 0; i<userlist.count; i++)
    //    {
    //        for (int j=i+1; j<[userlist count]; j++)
    //        {
    //            int aac = [[[userlist objectAtIndex:i] valueForKey:@"level"] intValue];
    //            int bbc = [[[userlist objectAtIndex:j] valueForKey:@"level"] intValue];
    //            NSDictionary *da = [NSDictionary dictionaryWithDictionary:[userlist objectAtIndex:i]];
    //            NSDictionary *db = [NSDictionary dictionaryWithDictionary:[userlist objectAtIndex:j]];
    //            if (aac >= bbc)
    //            {
    //                [userlist replaceObjectAtIndex:i withObject:da];
    //                [userlist replaceObjectAtIndex:j withObject:db];
    //            }else{
    //                [userlist replaceObjectAtIndex:j withObject:da];
    //                [userlist replaceObjectAtIndex:i withObject:db];
    //            }
    //        }
    //    }
}
@end
