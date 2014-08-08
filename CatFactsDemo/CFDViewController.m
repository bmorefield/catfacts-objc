//
//  CFDViewController.m
//  CatFactsDemo
//
//  Created by Bill Morefield on 6/5/14.
//  Copyright (c) 2014 Bill Morefield. All rights reserved.
//

#import "CFDViewController.h"

@interface CFDViewController ()

@property (weak, nonatomic) IBOutlet UILabel *catFact;
@property (weak, nonatomic) IBOutlet UIImageView *catImage;

@end

@implementation CFDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get size of the image view in pixels
    NSInteger imageWidth = self.catImage.frame.size.width * [UIScreen mainScreen].scale;
    NSInteger imageHeight = self.catImage.frame.size.height * [UIScreen mainScreen].scale;
    
    // Load photo
    [self loadCatPhoto:imageWidth imageHeight:imageHeight];
    
    // Load Fact
    [self loadCatFact];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCatPhoto:(NSInteger)imageWidth imageHeight:(NSInteger)imageHeight
{
    NSString *placeKittenUrl = [NSString stringWithFormat:@"http://placekitten.com/g/%zd/%zd", imageWidth, imageHeight];
    NSURL *url = [NSURL URLWithString:placeKittenUrl];
    NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:url];
    NSURLSessionConfiguration *urlConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConfig];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error)
        {
            UIImage *downloadedImage = [UIImage imageWithData:data];
            if(downloadedImage)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.catImage setImage:downloadedImage];
                    [self.catImage setNeedsDisplay];
                });
                NSLog(@"Loaded Cat Image Sized %zd x %zd", imageWidth, imageHeight);
            }
            else
            {
                NSString *returnedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"No image returned. Received: %@", returnedText);
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.catImage.image = nil;
                [self.catImage setNeedsDisplay];
            });
            NSLog(@"Error Getting Image %@", error);
        }
    }];
    
    // Start the download
    [dataTask resume];
}

- (void)loadCatFact
{
    NSString *catFactUrl = @"http://catfacts-api.appspot.com/api/facts?number=1";
    NSURL *url = [NSURL URLWithString:catFactUrl];
    NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:url];
    NSURLSessionConfiguration *urlConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConfig];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error)
        {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSArray *returnedFact = dataDictionary[@"facts"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.catFact.text = returnedFact[0];
                self.catFact.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
                [self.catFact setNeedsDisplay];
            });
            NSLog(@"Returned Fact: %@", returnedFact[0]);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.catFact.text = @"Unable to load fact at this time.";
                self.catFact.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
                [self.catFact setNeedsDisplay];
            });
            NSLog(@"Error Loading Fact: %@", error);
        }
    }];
    
    // Start the download
    [dataTask resume];
}

@end
