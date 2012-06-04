//
//  MIAtabSecondViewController.m
//  MIAtab
//
//  Created by Kjartan Vestvik on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MIAtabSecondViewController.h"

@implementation MIAtabSecondViewController

@synthesize dummyArray;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self setupArray];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) setupArray
{
    dummyArray = [[NSMutableArray alloc] init];
    [dummyArray addObject:@"Object 1"];
    [dummyArray addObject:@"Object 2"];
    [dummyArray addObject:@"Object 3"];
    [dummyArray addObject:@"Object 4"];
    [dummyArray addObject:@"Object 5"];
    [dummyArray addObject:@"Object 6"];
    [dummyArray addObject:@"Object 7"];
    [dummyArray addObject:@"Object 8"];
    [dummyArray addObject:@"Object 9"];
    [dummyArray addObject:@"Object 10"];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dummyArray count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [dummyArray objectAtIndex:indexPath.row];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
