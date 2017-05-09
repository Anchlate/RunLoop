//
//  ViewController.m
//  RunLoopWorkDistribution
//
//  Created by Di Wu on 9/19/15.
//  Copyright © 2015 Di Wu. All rights reserved.
//

#import "ViewController.h"
#import "DWURunLoopWorkDistribution.h"
#import "UIImageView+WebCache.h"

static NSString *IDENTIFIER = @"IDENTIFIER";

static CGFloat CELL_HEIGHT = 135.f;
static NSArray *images;


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *exampleTableView;

@end

@implementation ViewController

// 清除掉Cell.contentView上的subViews
+ (void)task_5:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    for (NSInteger i = 1; i <= 5; i++) {
        [[cell.contentView viewWithTag:i] removeFromSuperview];
    }
}

// 添加cell的顶部label
+ (void)task_1:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor redColor];
    label.text = [NSString stringWithFormat:@"%zd - Drawing index is top priority", indexPath.row];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.tag = 1;
    [cell.contentView addSubview:label];
}

// 第二张图片
+ (void)task_2:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(105, 20, 85, 85)];
    imageView.tag = 2;
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
//    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.image = image;
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:images[indexPath.row * 3 + 1]]];
    
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [cell.contentView addSubview:imageView];
    } completion:^(BOOL finished) {
    }];
}

// 第三张图片
+ (void)task_3:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 20, 85, 85)];
    imageView.tag = 3;
    
    // http://img.banlvs.com/2017/2/8/148653841891151521.jpg
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
//    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:images[indexPath.row * 3 + 2]]];
    
    
    
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.image = image;
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [cell.contentView addSubview:imageView];
    } completion:^(BOOL finished) {
    }];
}

// 第一张图片
+ (void)task_4:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath  {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 99, 300, 35)];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:0 green:100.f/255.f blue:0 alpha:1];
    label.text = [NSString stringWithFormat:@"%zd - Drawing large image is low priority. Should be distributed into different run loop passes.", indexPath.row];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.tag = 4;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 85, 85)];
    imageView.tag = 5;
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
//    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.image = image;
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:images[indexPath.row * 3]]];
    
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:imageView];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.currentIndexPath = indexPath;
    
    // 0. 先清除掉Cell上的所有View
    [ViewController task_5:cell indexPath:indexPath];
    
    // 1. 添加Cell的顶部标签
    [ViewController task_1:cell indexPath:indexPath];

    // 2. 绘制第一张图片
    [[DWURunLoopWorkDistribution sharedRunLoopWorkDistribution] addTask:^BOOL(void) {
        if (![cell.currentIndexPath isEqual:indexPath]) {
            
            NSLog(@"...... NO 1: row:%ld", indexPath.row);
            return NO;
        }
        [ViewController task_4:cell indexPath:indexPath];
        //NSLog(@"...... YES 1 row:%ld", indexPath.row);
        return YES;
    } withKey:indexPath];
    
    // 3. 绘制第二张图片
    [[DWURunLoopWorkDistribution sharedRunLoopWorkDistribution] addTask:^BOOL(void) {
        if (![cell.currentIndexPath isEqual:indexPath]) {
            NSLog(@"...... NO 2 row:%ld", indexPath.row);
            return NO;
        }
        [ViewController task_2:cell indexPath:indexPath];
        //NSLog(@"...... YES 2 row:%ld", indexPath.row);
        return YES;
    } withKey:indexPath];

    // 4. 绘制第三张图片
    [[DWURunLoopWorkDistribution sharedRunLoopWorkDistribution] addTask:^BOOL(void) {
        if (![cell.currentIndexPath isEqual:indexPath]) {
            NSLog(@"...... NO 3 row:%ld", indexPath.row);
            return NO;
        }
        [ViewController task_3:cell indexPath:indexPath];
        //NSLog(@"...... YES 3 row:%ld", indexPath.row);
        return YES;
    } withKey:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)loadView {
    self.view = [UIView new];
    self.exampleTableView = [UITableView new];
    self.exampleTableView.delegate = self;
    self.exampleTableView.dataSource = self;
    [self.view addSubview:self.exampleTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.exampleTableView.frame = self.view.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    images = @[
                    @"http://img.banlvs.com/2017/2/14/148705717237956320.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705717654129699.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705718048581396.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705718486100064.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705718959395438.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705719478167947.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705719777066821.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705720225013684.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705720796009342.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705721189756551.jpg",
                    
                    @"http://img.banlvs.com/2017/2/14/148705721696217918.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705722259259382.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705722748283193.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705723684616509.jpg",
                    @"http://img.banlvs.com/2017/2/8/148653841891151521.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705725256216664.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705726150823564.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705822674058825.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705726991174124.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705727205245441.jpg",
                    
                    @"http://img.banlvs.com/2017/2/14/148705727433581910.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705727999900819.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705728245297650.jpg",
                    @"http://img.banlvs.com/2017/2/14/148705728903936684.jpg"
                    
                    ];
    
    [self.exampleTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IDENTIFIER];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
