//
//  Ring.h
//  HanoiTowers
//
//  Created by David Kramf on 10/04/2016.
//  Copyright © 2016 David Kramf. All rights reserved.
//

#import <UIKit/UIKit.h>

//Adds 2 properties to UIView. Otherise nothing.
@interface Ring : UIView
@property CATransform3D transform;
@property  int originalIndex;
@end
