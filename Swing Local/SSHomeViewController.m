//
//  SSHomeViewController.m
//  Swing Local
//
//  Created by Stevenson on 3/9/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSHomeViewController.h"

#define LOAD_LOGO_TRANSFORM CATransform3DMakeScale(.50, .50, .50)

@interface SSHomeViewController() <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) UIImageView *loadLogo;
@property (weak, nonatomic) IBOutlet UITableView *theTableView;


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
    self.loadLogo.image = [UIImage imageNamed:@"Inline-Logo"];
    [self.loadLogo setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:self.loadLogo];
    BOOL newLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"newLaunch"];
    if (newLaunch) {
        [self.loadLogo setCenter:self.view.center];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"imagePeakCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIScrollView *imageScroll = (UIScrollView*)[cell.contentView viewWithTag:1];
    imageScroll.contentSize = CGSizeMake(960.f, imageScroll.frame.size.height);
    // Configure the cell...
    
    return cell;
}


@end
