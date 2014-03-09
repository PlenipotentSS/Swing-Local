//
//  SSCityEventController.m
//  Swing Local
//
//  Created by Stevenson on 3/3/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSCityEventController.h"
#import "SSEventTableView.h"
#import "SSMapView.h"
#import "SSPhotoBackgroundView.h"
#import "SSEventSubWrapperView.h"

#define MAP_RATIO 3.f/4.f
#define MAP_HEIGHT_OFFSET 69

@interface SSCityEventController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet SSEventSubWrapperView *contentView;
@property (weak, nonatomic) IBOutlet SSEventTableView *theTableView;
@property (nonatomic) NSOperationQueue *cellAnimationQueue;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (nonatomic) NSInteger lastCell;
@property (nonatomic) BOOL touchesMoved;
@property (nonatomic) SSMapView *mapView;
@property (nonatomic) BOOL mapShown;
@property (nonatomic) UITapGestureRecognizer *tableViewHideTapRecognizer;
@property (nonatomic) SSPhotoBackgroundView *photographyCover;

@end

@implementation SSCityEventController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setupBackground];
    [self setupTableView];
    [self setupCellAnimations];
    [self setupMap];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    usleep(200000);
    [self peekMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup methods
- (void)setupBackground
{
    self.photographyCover = [[[NSBundle mainBundle] loadNibNamed:@"PhotographerCoverView" owner:self options:nil] objectAtIndex:0];
    [self.photographyCover setAlpha:0.f];
    [self.photographyCover setHidden:YES];
    [self.contentView addSubview:self.photographyCover];
    
}

- (void)setupTableView
{
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.isVisible = YES;
    
    __block SSCityEventController *weakSelf = self;
    self.theTableView.recognizerBlock = ^void(NSSet *view) {
        if (weakSelf.theTableView.isVisible) {
            [weakSelf showBackground];
        }
    };
}

- (void)setupCellAnimations
{
    self.cellAnimationQueue = [NSOperationQueue new];
    self.cellAnimationQueue.maxConcurrentOperationCount = 1;
    self.lastCell = 0;
}

- (void)setupMap
{
    self.mapView = [[[NSBundle mainBundle] loadNibNamed:@"SSMapView" owner:self options:nil] objectAtIndex:0];
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = self.view.frame.size.height * MAP_RATIO;
    self.mapView.frame = mapFrame;
    self.mapView.center = CGPointMake(self.view.center.x, self.view.center.y * MAP_RATIO -CGRectGetHeight(self.mapView.frame));
    
    [self.view insertSubview:self.mapView belowSubview:[self.view viewWithTag:1]];
}

#pragma mark - gesture recognizers
- (IBAction)mapViewButton:(id)sender {
    if (!self.mapShown) {
        [self showMap];
    } else {
        [self peekMap];
    }
}

- (IBAction)buttonPin:(id)sender {
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[[button superview] superview] superview];
    NSIndexPath *indexPath = [self.theTableView indexPathForCell:cell];
    NSLog(@"row: %d",(int)indexPath.row);
    
    [self showMap];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![[[touches valueForKey:@"view"] anyObject] isKindOfClass:[SSMapView class]]) {
        if ( self.mapShown) {
            [self peekMap];
        } else {
            if (!self.theTableView.isVisible) {
                [self hideBackground];
            } else {
                [self showBackground];
            }
        }
    }
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - Background View displaying
- (void)hideBackground
{
    [UIView animateWithDuration:.4f animations:^{
        self.mapView.center = CGPointMake(self.mapView.center.x, self.mapView.center.y+MAP_HEIGHT_OFFSET);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4f animations:^{
            [self.photographyCover setAlpha:0.f];
            [self.photographyCover setHidden:YES];
            self.theTableView.center = CGPointMake(self.theTableView.center.x, self.theTableView.center.y);
            [self.theTableView setAlpha:1.f];
        } completion:^(BOOL finished) {
            self.theTableView.isVisible = YES;
        }];
    }];
    
}

- (IBAction)closeBackground:(id)sender
{
    [self hideBackground];
}

- (void)showBackground
{
    [UIView animateWithDuration:0.4f animations:^{
        self.theTableView.center = CGPointMake(self.theTableView.center.x, self.theTableView.center.y-50);
        [self.theTableView setAlpha:0.f];
    } completion:^(BOOL finished) {
        self.theTableView.isVisible = NO;
        [UIView animateWithDuration:0.4f animations:^{
            self.mapView.center = CGPointMake(self.mapView.center.x, self.mapView.center.y-MAP_HEIGHT_OFFSET);
            [self.photographyCover setAlpha:1.f];
            [self.photographyCover setHidden:NO];
        }];
    }];
}

#pragma mark - Map view
- (void)peekMap
{
    [UIView animateWithDuration:.4f animations:^{
        self.mapView.center = CGPointMake(self.mapView.center.x, self.view.center.y*MAP_RATIO-CGRectGetHeight(self.mapView.frame)+MAP_HEIGHT_OFFSET);
    } completion:^(BOOL finished) {
        self.mapShown = NO;
        [self.theTableView removeGestureRecognizer:self.tableViewHideTapRecognizer];
    }];
}

- (void)showMap
{
    [UIView animateWithDuration:.4f animations:^{
        self.mapView.center = CGPointMake(self.mapView.center.x, self.view.center.y*MAP_RATIO);
    } completion:^(BOOL finished) {
        self.mapShown = YES;
        
        if (!self.tableViewHideTapRecognizer) {
            self.tableViewHideTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(peekMap)];
        }
        if (![self.tableViewHideTapRecognizer view]) {
            [self.theTableView addGestureRecognizer:self.tableViewHideTapRecognizer];
        }
    }];
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"bouncyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    
    return cell;
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.lastCell-1 <= indexPath.row ) {
        self.lastCell = indexPath.row;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView setAlpha:0.f];
        [self.cellAnimationQueue addOperationWithBlock:^{
            usleep(100000);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [UIView animateWithDuration:0.f animations:^{
                    cell.transform = CGAffineTransformMakeTranslation(cell.bounds.size.width, 0);
                }];
                [UIView animateWithDuration:.6f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [cell.contentView setAlpha:.95f];
                    cell.transform = CGAffineTransformMakeTranslation(-10, 0);
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:.2 animations:^{
                        cell.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }];
    }
}


@end
