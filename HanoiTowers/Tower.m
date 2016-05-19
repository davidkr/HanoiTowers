//
//  Tower.m
//  HanoiTowers
//
//  Created by David Kramf on 10/04/2016.
//  Copyright © 2016 David Kramf. All rights reserved.
//

#import "Tower.h"
@interface Tower ()
@property NSMutableArray *tower;
@property CGPoint baseOrigin;
@end

@implementation Tower
-(instancetype)initWithTower:(Tower*)tower {
    self = [super init];
    if (self){
        _tower = tower.tower;
        _origin = tower.origin;
        _baseOrigin = tower.baseOrigin;
        _holding = tower.holding;
        _base = tower.base;
    }
    return self;
}


-(instancetype)initWithbase:(CGRect)base capacity:(int)capacity{
    self = [super init];
    if (self){
        _tower = [[NSMutableArray alloc] initWithCapacity:capacity];
        _origin = CGPointMake(base.origin.x,base.origin.y);
        _baseOrigin = _origin;
        _holding = 0;
        _base = base;
    }
    return self;
}
-(void)add:(UIView*)ring{
    [_tower addObject:ring];
    _origin = CGPointMake(ring.frame.origin.x, ring.frame.origin.y);
    _holding=_holding+1;
}
-(UIView*)remove{
    UIView* r = self.tower[self.tower.count-1];
    [self.tower removeLastObject];
    if (self.tower.count==0){
        _origin = _baseOrigin;
    }else{
        UIView *v = _tower[_tower.count-1];
        _origin = v.frame.origin;
    }
    _holding = _holding-1;
    return r;
}
-(UIView*)top{
    UIView *tower;
    if (self.tower.count > 0){
        tower =  _tower[_tower.count-1];
    }
    return tower;
}
-(NSArray *)allRings{
    return _tower;
}
@end
