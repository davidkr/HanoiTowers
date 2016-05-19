//
//  Step.h
//  HanoiTowers
//
//  Created by David Kramf on 13/04/2016.
//  Copyright © 2016 David Kramf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//A step is a coomand to move a ring from one tower to another
@interface Step : NSObject
@property UIView* ring;
@property int from;
@property int to;
-(instancetype)initMoveOfRing:(UIView*)ring from:(int)from to:(int)to;
-(NSString*)describe;
@end
