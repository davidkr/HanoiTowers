//
//  Step.m
//  HanoiTowers
//  
//  Created by David Kramf on 13/04/2016.
//  Copyright © 2016 David Kramf. All rights reserved.
//

#import "Step.h"

@implementation Step
-(NSString*)describe{
    NSString *st = [NSString stringWithFormat:@"Move ring %fX%f From: %d To: %d" ,_ring.frame.size.width ,_ring.frame.size.height, _from,_to ];
    return st;
}

-(instancetype)initMoveOfRing:(UIView*)ring from:(int)from to:(int)to {
    self = [super init];
    if (self) {
        _from=from; _to=to; _ring = ring;
    }
    return self;
}
@end
