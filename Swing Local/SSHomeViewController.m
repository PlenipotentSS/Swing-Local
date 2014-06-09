//
//  SSHomeViewController.m
//  Swing Local
//
//  Created by Stevenson on 3/9/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSHomeViewController.h"
#import "SSPagedView.h"
#import "UIColor+SwingLocal.h"
#import "SSStackedPageView.h"
#import "UIColor+SwingLocal.h"

#define LOAD_LOGO_TRANSFORM CATransform3DMakeScale(.50, .50, .50)

@interface SSHomeViewController() <UITableViewDataSource,UITableViewDelegate,SSPagedViewDelegate,SSStackedViewDelegate>

@property (nonatomic) UIImageView *loadLogo;
@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (weak, nonatomic) SSPagedView *pagedView;
@property (nonatomic) NSMutableArray *views;
@property (weak, nonatomic) UIPageControl *thePageControl;
@property (nonatomic) SSStackedPageView *stackView;
@property (nonatomic) NSMutableArray *savedCities;


@end

@implementation SSHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.loadLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 88.f)];
    self.loadLogo.image = [UIImage imageNamed:@"TITLE_INLINE-07"];
    [self.loadLogo setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:self.loadLogo];
    BOOL newLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"newLaunch"];
    if (newLaunch) {
        [self.loadLogo setCenter:self.view.center];
        [self.theTableView setAlpha:0];
    } else {
        CGRect newFrame = self.loadLogo.frame;
        newFrame.origin.y = 0.f;
        self.loadLogo.frame = newFrame;
        self.loadLogo.layer.transform = LOAD_LOGO_TRANSFORM;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL newLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"newLaunch"];
    if (newLaunch) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"newLaunch"];
        
        CGRect newFrame = self.loadLogo.frame;
        newFrame.origin.y = 0.f;
        [UIView animateWithDuration:1.f animations:^{
            self.loadLogo.frame = newFrame;
            self.loadLogo.layer.transform = LOAD_LOGO_TRANSFORM;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.4f animations:^{
                [self.theTableView setAlpha:1.f];
            }];
        }];
    }
    [self.theTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 164.f;
    } else if (indexPath.row == 1) {
        return 200.f;
    } else if (indexPath.row == 2) {
        return 200.f;
    }
    else return 0.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"";
    if ( indexPath.row == 0 ){
        CellIdentifier = @"imagePeakCell";
    } else if (indexPath.row == 1){
        CellIdentifier = @"savedCitiesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (!self.stackView) {
            self.stackView = (SSStackedPageView*)[cell viewWithTag:1];
            [self.stackView setPagesHaveShadows:YES];
            self.stackView.delegate = self;
            self.savedCities = [[NSMutableArray alloc] init];
            for (int i=0;i<10;i++) {
                UIView *thisView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 100.f)];
                [self.savedCities addObject:thisView];
            }
        }
        
        return cell;
    } else if (indexPath.row == 2){
        CellIdentifier = @"favoriteOrgsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (!self.pagedView) {
            self.pagedView = (SSPagedView*)[cell viewWithTag:1];
            self.thePageControl = (UIPageControl*)[cell viewWithTag:2];
            
            self.pagedView.delegate = self;
            self.pagedView.pageControl = self.thePageControl;
            self.views = [[NSMutableArray alloc] init];
            for (int i=0;i<10;i++) {
                UIView *thisView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 150.f)];
                [self.views addObject:thisView];
            }
        }
        
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIScrollView *imageScroll = (UIScrollView*)[cell.contentView viewWithTag:1];
    imageScroll.contentSize = CGSizeMake(960.f, imageScroll.frame.size.height);
    // Configure the cell...
    
    return cell;
}

#pragma mark - IBActions Page Control
- (IBAction)pageControlChanged:(id)sender {
    [self.pagedView scrollToPage:[(UIPageControl*)sender currentPage]];
}

#pragma mark - paged delegate methods
- (void)pageView:(SSPagedView *)pagedView didScrollToPageAtIndex:(NSInteger)index
{
    
}

- (UIView *)pageView:(SSPagedView *)pagedView entryForPageAtIndex:(NSInteger)index
{
    UIView *thisView = [pagedView dequeueReusableEntry];
    if (!thisView) {
        thisView = [self.views objectAtIndex:index];
        thisView.backgroundColor = [UIColor burntScheme];
        thisView.layer.cornerRadius = 5;
        thisView.layer.masksToBounds = YES;
    }
    return thisView;
}

- (CGSize)sizeForPageInView:(SSPagedView *)pagedView
{
    return CGSizeMake(200, 150);
}

- (void)pageView:(SSPagedView *)pagedView selectedPageAtIndex:(NSInteger)index
{
    NSLog(@"%i",(int)index);
}

- (NSInteger)numberOfPagesInView:(SSPagedView *)pagedView
{
    return [self.views count];
}

#pragma mark - SSStackedView Delegate
- (UIView *)stackView:(SSStackedPageView *)stackView pageForIndex:(NSInteger)index
{
    UIView *thisView = [stackView dequeueReusablePage];
    if (!thisView) {
        thisView = [self.savedCities objectAtIndex:index];
        thisView.backgroundColor = [UIColor getRandomColor];
        thisView.layer.cornerRadius = 5;
        thisView.layer.masksToBounds = YES;
    }
    return thisView;
}

- (NSInteger)numberOfPagesForStackView:(SSStackedPageView *)stackView
{
    return [self.savedCities count];
}

- (void)stackView:(SSStackedPageView *)stackView selectedPageAtIndex:(NSInteger) index
{
    NSLog(@"selected page: %i",(int)index);
}

@end
