
//
//  TVContentViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVContentViewController.h"

@interface TVContentViewController ()

@end

@implementation TVContentViewController

- (id)initWithImage:(UIImage *)image Index:(NSUInteger)index {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        self.contentImageView = [[UIImageView alloc] initWithImage:image];
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self setView:self.contentImageView];

        
        return self;
    }
    
    return nil;
}

- (void)loadImage:(UIImage *)image {
    
    [self.contentImageView setImage:image];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.contentImageView = [[UIImageView alloc] initWithImage:nil];
//    self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self setView:self.contentImageView];
    
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
