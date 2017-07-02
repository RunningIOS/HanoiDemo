//
//  ViewController.m
//  HanoiDemo
//
//  Created by dl on 2017/6/30.
//  Copyright © 2017年 dl. All rights reserved.
//

#import "ViewController.h"

static const CGFloat kDiskHeight = 3;
static const CGFloat kWidthDelta = 5;
static const CGFloat kDurationAnimation = 0.25;

@interface ViewController ()

@property (nonatomic, assign) NSInteger stepCount;

// 代表三根柱子， A B C z三根柱子
@property (nonatomic, strong) UIView *pillarA;
@property (nonatomic, strong) UIView *pillarB;
@property (nonatomic, strong) UIView *pillarC;

// 保存装在对应柱子上的圆盘
@property (nonatomic, strong) NSMutableArray *containerA;
@property (nonatomic, strong) NSMutableArray *containerB;
@property (nonatomic, strong) NSMutableArray *containerC;

// 圆盘个数
@property (nonatomic, assign) NSInteger count;

// 移动步数
@property (nonatomic, assign) NSInteger moveCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pillarA = [self createPillarView];
    self.pillarA.tag = 'A';
    
    self.pillarB = [self createPillarView];
    self.pillarB.tag = 'B';
    
    self.pillarC = [self createPillarView];
    self.pillarC.tag = 'C';
    
    NSArray *items= @[self.pillarA, self.pillarB, self.pillarC];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    for (NSInteger index = 0; index < items.count; index++) {
        UIView *view = items[index];
        view.center = CGPointMake(width * (1.0 / (items.count * 2) + (CGFloat)index / items.count), height / 2);
    }
    
    self.count = 35;
    self.moveCount = 0;
    self.containerA = [self createDisks];
    self.containerB = [NSMutableArray new];
    self.containerC = [NSMutableArray new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("com.hanoi.queue", NULL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(serialQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf moveDisks:strongSelf.containerA fromPillar:strongSelf.pillarA assistPillar:strongSelf.pillarB toPillar:strongSelf.pillarC];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 创建圆盘
- (NSMutableArray *)createDisks {
    NSMutableArray *items = [NSMutableArray new];
    CGFloat maxWidth = (CGRectGetWidth(self.view.bounds) - 40) / 3;
    for (int i = 0; i < self.count; i++) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor redColor];
        view.bounds = CGRectMake(0, 0, maxWidth - i * kWidthDelta, kDiskHeight);
        [self.view addSubview:view];
        view.tag = i;
        view.center = CGPointMake(self.pillarA.center.x, CGRectGetHeight(self.view.bounds) - (i * kDiskHeight + kDiskHeight / 2));
        [items addObject:view];
    }
    
    return items;
}

- (UIView *)createPillarView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor yellowColor];
    view.bounds = CGRectMake(0, 0, 10, CGRectGetHeight(self.view.bounds));
    [self.view addSubview:view];
    return view;
}

- (void)moveDisks:(NSArray *)disks fromPillar:(UIView *)fromPillar assistPillar:(UIView *)assitPillar toPillar:(UIView *)toPillar {
    NSMutableArray *toContainers;
    if (toPillar == self.pillarA) {
        toContainers = self.containerA;
    } else if (toPillar == self.pillarB){
        toContainers = self.containerB;
    } else {
        toContainers = self.containerC;
    }
    
    NSMutableArray *fromContrainters;
    if (fromPillar == self.pillarA) {
        fromContrainters = self.containerA;
    } else if (fromPillar == self.pillarB) {
        fromContrainters = self.containerB;
    } else {
        fromContrainters = self.containerC;
    }
    
    if (disks.count == 1) {
        UIView *view = disks.firstObject;
        [fromContrainters removeObjectsInArray:disks];
        [toContainers addObject:view];
        CGFloat y = CGRectGetHeight(self.view.bounds) - ((toContainers.count - 1) * kDiskHeight + kDiskHeight / 2);
        CGPoint center = CGPointMake(toPillar.center.x, y);
        NSLog(@"move %@ from %c to %c, y:%0.0f", @(view.tag), (char)(fromPillar.tag), (char)(toPillar.tag), y);

        [self moveView:view toCenter:center];
    } else {
        NSArray *retains = [disks subarrayWithRange:NSMakeRange(1, disks.count - 1)];
        [self moveDisks:retains fromPillar:fromPillar assistPillar:toPillar toPillar:assitPillar];
        UIView *first = disks.firstObject;
        [toContainers addObject:first];
        [fromContrainters removeObject:first];
        [fromContrainters removeObjectsInArray:retains];
        CGFloat y = CGRectGetHeight(self.view.bounds) - ((toContainers.count - 1) * kDiskHeight + kDiskHeight / 2);
        CGPoint center = CGPointMake(toPillar.center.x, y);
        NSLog(@"move %@ from %c to %c, y:%0.0f", @(first.tag), (char)(fromPillar.tag), (char)(toPillar.tag), y);
        [self moveView:first toCenter:center];
        
        [self moveDisks:retains fromPillar:assitPillar assistPillar:fromPillar toPillar:toPillar];
    }
}

- (void)moveView:(UIView *)view toCenter:(CGPoint)center {
    dispatch_semaphore_t semap = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kDurationAnimation delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            view.center = center;
            self.moveCount ++;
        } completion:^(BOOL finished) {
            dispatch_semaphore_signal(semap);
        }];
        
    });
    dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);
}

@end
