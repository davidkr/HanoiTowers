//
//  RootViewController.m
//  HanoiTowers
//
//  Created by David Kramf on 10/04/2016.
//  Copyright © 2016 David Kramf. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()
@property NSMutableArray *towers;
//@property CGRect baseFrame;
@property CGSize screenOrientation;
@property CGFloat floor;
@property NSMutableArray *steps;
@property int numberOfRings;
@property NSMutableArray *bases;
@end

@implementation RootViewController
#define radians(degrees) (degrees * M_PI/180)
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)loadView{
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.alpha = 1.0;
    v.opaque = NO;
    v.backgroundColor = [UIColor redColor];
    self.view = v;
    _screenOrientation = frame.size;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Set selector for screen orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    //Build bases
    _bases = [[NSMutableArray alloc] initWithCapacity:3];
    [self buildBases];

    //Build a tower with rings
    _numberOfRings = 5;
    [self buildTowers];
    
    //Draw the rings
    //CGRect currentFrame = CGRectMake(self.view.frame.size.width*10/100, _baseFrame.origin.y, 100, 100);
    //CGRect currentFrame = CGRectMake(self.view.frame.size.width*10/100, _floor-10, 100, 100);
    CGRect currentFrame = CGRectMake(self.view.frame.size.width*0.04, _floor-20, 100, 100);
    for(int ind = 0;ind<_numberOfRings;ind++){
        NSLog(@"%f,%f",currentFrame.size.width,currentFrame.size.height);
        Ring *v  = [[Ring alloc] initWithFrame:currentFrame];
        v.originalIndex = ind;
        v.backgroundColor = [UIColor redColor];
        [self drawRingInView:v];
        [self.view addSubview:v];
        CGRect frame = v.frame;
        [_towers[0] add:v];
        currentFrame = CGRectMake(v.frame.origin.x+2.5, v.frame.origin.y-5, v.frame.size.width-5, v.frame.size.height-5);
     }

 
    //Perform the algorithm whose output is an array os Steps whic will be animated later
    _steps = [[NSMutableArray alloc] init];
    Tower *from = _towers[0];
    [self moveRings:from.holding fromTower:0 toTower:1 viaTower:2];
    for (Step *step in _steps){
        NSString *st = [step describe];
        NSLog(@"%@",st);
    }
    
    //Before Animation Reload the Towers to initial state.
    [self buildTowers];
    for (int ind=0; ind<self.view.subviews.count;ind++){
        UIView *v = self.view.subviews[ind];
        [_towers[0] add:v];
    }

    
    //Perform the animation
    [self animateNextStep];

}
//Bases are repsented as number at bottom of screen
-(void)buildBases{
    _floor = self.view.frame.size.height * 0.90 - 10;
    for (int ind= 1;ind<=3;ind++){
        CATextLayer *l = [[CATextLayer alloc] init];

        //Frame
        CGFloat third = self.view.frame.size.width/3;
        CGFloat percent = self.view.frame.size.width*0.01;
        CGFloat x = third * (ind-1)+percent*1.5;
        CGFloat y = self.view.frame.size.height * 0.90;
        CGFloat h = self.view.frame.size.height * 0.07;
        CGFloat w = third * 0.9;
        CGRect frame = CGRectMake(x, y, w, h);
        l.frame = frame;

        
        //String
        l.string = [[NSString alloc] initWithFormat:@"%d",ind ];
        l.fontSize = lroundf(h * 0.9);
        l.alignmentMode = kCAAlignmentCenter;
        
        
        //Color
        l.backgroundColor = self.view.backgroundColor.CGColor;
        l.foregroundColor = [UIColor blackColor].CGColor;
                NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];

        [self.view.layer addSublayer:l];
        [_bases addObject:l];
    }
}

//Needed when performing a rotation
-(void)removeBases{
    NSArray *a = self.view.layer.sublayers;
    for (int ind=0;ind<3;ind++){
        [(CALayer*)_bases[ind] removeFromSuperlayer ];
    }
    _bases = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *b = self.view.layer.sublayers;
}

//Towers are build above their bases
-(void)buildTowers{
    CGFloat third = self.view.frame.size.width/3;
    _towers = [[NSMutableArray alloc] initWithCapacity:3];
    for (int ind=0; ind<3; ind++) {
        CGRect base = CGRectMake(ind*third + (third-100)/2, _floor-20, 100, 100);
        Tower *t = [[Tower alloc] initWithbase:base capacity:_numberOfRings];
        _towers[ind] = t;
    }
}

//Main recursive loop. It's output is a Step (a command ) added to the steps array. The steps will be done
//used to create the animation on screen.
-(void)moveRings:(int)numOfRings fromTower:(int)from toTower:(int)to viaTower:(int)via{
    if (numOfRings>1){
        [self moveRings:numOfRings-1 fromTower:from toTower:via viaTower:to];
        [self stepFrom:from to:to];
        [self moveRings:numOfRings-1 fromTower:via toTower:to viaTower:from];
        return;
    }
    if(numOfRings ==1){
        [self stepFrom:from to:to];
    }
}

//Add a command to the Steps array
-(void)stepFrom:(int)from to:(int)to{
    UIView *ring = [_towers[from] remove];
    Step *step = [[Step alloc] initMoveOfRing:ring from:from to:to];
    NSLog(@"%@",[step describe]);
    [_towers[to] add:ring];
    [_steps addObject:step];
}

//Main animation method. A ring is moved from it base to the top of screen and then to it's place
-(void)moveRingForView:(UIView *)v  fromTower:(int)from toTower:(int)ind{
      Tower *fromTower = _towers[from];
      [fromTower remove];
      [UIView animateWithDuration:5.0
      animations:^{
        CGRect topFrame = CGRectMake(self.view.frame.size.width/2-50,self.view.frame.size.height*0.13 ,v.frame.size.height , v.frame.size.width);
        v.frame = topFrame;
      }
      completion:^(BOOL finished){
        [UIView animateWithDuration:5.0
           animations:^{
               CGFloat third = self.view.frame.size.width/3;
               Tower *tower = _towers[ind];
               CGRect destinationFrame;
               if (tower.holding==0) {
                   CGFloat percent = self.view.frame.size.width*0.01;
                   destinationFrame = CGRectMake(third*ind+(third-v.frame.size.width)/2, _floor-15,v.frame.size.width, v.frame.size.height);
               }else{
                   UIView *top = [tower top];
                   destinationFrame = CGRectMake(top.frame.origin.x+(top.frame.size.width-v.frame.size.width)/2,
                                                 top.frame.origin.y-5,
                                                 v.frame.size.width,
                                                 v.frame.size.height);
              }
             v.frame = destinationFrame;
        }
         completion:^(BOOL finished){
             NSLog(@"Before removing");
             Tower *tower = _towers[ind];
             [tower add:v];
             NSLog(@"After addingg");
            [self animateNextStep];
             
         }
       ];
    }
     ];
    
 }

//Animate each step in the Steps array
-(void)animateNextStep{
    if (_steps.count>0){
       Step *step = _steps[0];
       NSLog(@"Animating %@",[step describe]);
       [_steps removeObjectAtIndex:0];
        NSLog(@"After removing a step");
       [self moveRingForView:step.ring fromTower:step.from toTower:step.to];
    }
}

//Ring Composed of 7 white eclipse layers rotated to give some 3d illusion
- (void)drawRingInView:(UIView *)v{
    CATransform3D t3D = CATransform3DMakeRotation(radians(75), 1,0,0);
    CAShapeLayer *lbase = [[CAShapeLayer alloc] init];
    lbase.frame = v.bounds;
    //l.position = CGPointMake(self.view.frame.size.width*10/100,self.view.frame.size.height-120);
    lbase.position = CGPointMake(0,0);
    lbase.anchorPoint = CGPointMake(0.0,0.0);
    lbase.backgroundColor =  v.backgroundColor.CGColor;
    UIBezierPath *ellipse1 = [UIBezierPath bezierPathWithOvalInRect:lbase.bounds];
    //UIBezierPath *ellipse2 = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(lbase.bounds,15 , 10)];
    UIBezierPath *ellipse2 = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(lbase.bounds,5 , 5)];
    lbase.strokeColor = [UIColor whiteColor].CGColor;
    lbase.fillColor = [UIColor whiteColor].CGColor;
    lbase.fillRule = kCAFillRuleEvenOdd;
    CAShapeLayer *mask = [[CAShapeLayer alloc]initWithLayer:lbase];
    lbase.lineWidth = 3;
    mask.lineWidth = 20;
    [ellipse1 appendPath:ellipse2];
    lbase.path = ellipse1.CGPath;
    mask.path = ellipse1.CGPath;
    [lbase setNeedsDisplay];
    [v.layer addSublayer:lbase];
    lbase.transform = t3D;
    mask.transform = t3D;
    for (UInt32 ind =1;ind<10;ind++){
        CAShapeLayer *l1 = [[CAShapeLayer alloc] initWithLayer:lbase];
        l1.frame = v.bounds;
        l1.position = CGPointMake(lbase.position.x, lbase.position.y-ind);
        l1.anchorPoint = CGPointMake(0, 0);
        UIBezierPath *ellipse1 = [UIBezierPath bezierPathWithOvalInRect:lbase.bounds];
        UIBezierPath *ellipse2 = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(lbase.bounds, 15, 10)];
        l1.strokeColor = [UIColor whiteColor].CGColor;
        l1.fillColor = [UIColor whiteColor].CGColor;
        l1.fillRule = kCAFillRuleEvenOdd;
        l1.lineWidth = 3;
        [ellipse1 appendPath:ellipse2];
        l1.path = ellipse1.CGPath;
        l1.transform = t3D;
        // [l1 addAnimation:moveAnim forKey:@"position"];
        [l1 setNeedsDisplay];
        UInt32 i = v.layer.sublayers.count;
        [v.layer insertSublayer:l1 atIndex:i];
    }
    
    v.layer.mask = mask;
}


-(void)detectOrientation{
    NSLog(@"Orientation Changed");
    CGRect frame = [[UIScreen mainScreen] bounds];
    NSLog(@"Scrren size is %fx%f",frame.size.height,frame.size.width);
    if (_screenOrientation.height == frame.size.height) return;
    [self pauseLayer:self.view.layer];
    _screenOrientation = frame.size;
    
    //keep tower rings
    NSMutableArray *arraysOfRings = [[NSMutableArray alloc] initWithCapacity:3];
    for (int ind=0; ind<3; ind++) {
        NSArray *a = [(Tower*)_towers[ind] allRings ];
        [arraysOfRings addObject:a];
    }
    //initialize  base and towers
    [self removeBases];
    [self buildBases];
    [self buildTowers];
    
    for (int ind=0; ind<3; ind++) {
        NSArray *rings = arraysOfRings[ind];
        for (Ring *v in rings){
            Tower *tower = _towers[ind];
            CGRect destinationFrame;
            CGFloat third = self.view.frame.size.width/3;
            
            if (tower.holding==0) {
                destinationFrame = CGRectMake(third*ind+(third-v.frame.size.width)/2, _floor-20,v.frame.size.width, v.frame.size.height);
            }else{
                UIView *top = [tower top];
                CGRect frame = top.frame;
                destinationFrame = CGRectMake(top.frame.origin.x+(top.frame.size.width-v.frame.size.width)/2,
                                              top.frame.origin.y-5,
                                              v.frame.size.width,
                                              v.frame.size.height);
            }
            v.frame = destinationFrame;
            [(Tower *)_towers[ind] add:v];
            [v setNeedsDisplay];
        }
    }
    [self resumeLayer:self.view.layer];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
