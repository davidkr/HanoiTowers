//
//  Tower.h
//  HanoiTowers
//
//  Created by David Kramf on 10/04/2016.
//  Copyright © 2016 David Kramf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Ring.h"

//A tower has a place and a stack of ordered rings on it.
@interface Tower : NSObject
@property (readonly)  CGPoint  origin;
@property (readonly) int holding;
@property  (readonly) CGRect base;
-(instancetype)initWithbase:(CGRect)base capacity:(int)capacity;
-(instancetype)initWithTower:(Tower*)tower;
-(void)add:(UIView*)ring;
-(UIView*)remove;
-(UIView*)top;
-(NSArray *)allRings;
@end
