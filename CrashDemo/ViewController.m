//
//  ViewController.m
//  CrashDemo
//
//  Created by Bruce on 16/12/29.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    NSString *password = nil;
    //    NSDictionary *dict = @{
    //                           @"userName": @"bruce",
    //                           @"password": password
    //                           };
    //    NSLog(@"dict is : %@", dict);
    
    
    //    NSData *data = nil;
    //    NSError *error;
    //    NSDictionary *orginDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    //    NSLog(@"originDict is : %@", orginDict);
    
    
    //    NSArray  *emptyArr = [NSArray new];
    //    NSLog(@"%@",[emptyArr objectAtIndex:10]);
    
    //    NSArray *arr = @[@"FlyElephant",@"keso"];
    //    NSString *result = [arr objectAtIndex:10];
    //    NSLog(@"=======%@",result);
    
    //    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:arr];
    //    NSLog(@"%@", mutableArr[100]);
    //    NSString *obj;
    //    [mutableArr addObject:obj];
    
    //    NSMutableArray *array = [NSMutableArray array];
    //    [array addObject:@"Q"];
    //    [array addObject:@"I"];
    //    NSLog(@"数组测试结果：%@", array[2]);
    //    NSLog(@"数组测试结果：%@", array[1]);
    
    //    NSString *str = @"我是一只小鸟";
    //    NSLog(@"字符串长度length: %ld", (long)str.length);
    //    NSLog(@"字符串截取测试: %@", [str substringToIndex:1]);
    //    NSLog(@"字符串截取测试: %@", [str substringToIndex:10]);
    
    //    NSMutableString *mutableStr = [NSMutableString new];
    //    [mutableStr insertString:@"A" atIndex:0];
    //    [mutableStr insertString:@"B" atIndex:1];
    //    [mutableStr insertString:@"C" atIndex:2];
    //    NSLog(@"替换前字符串长度: %@", mutableStr);
    //    NSLog(@"====%s", class_getName([mutableStr class]));
    //    [mutableStr replaceCharactersInRange:NSMakeRange(1, 1) withString:@"b"];
    //    NSLog(@"替换后字符串长度: %@", mutableStr);
    
    //    NSMutableAttributedString *attributedStr = [NSMutableAttributedString new];
    //    [attributedStr insertAttributedString:[[NSAttributedString alloc] initWithString:@"A"] atIndex:0];
    //    [attributedStr insertAttributedString:[[NSAttributedString alloc] initWithString:@"B"] atIndex:1];
    //    [attributedStr insertAttributedString:[[NSAttributedString alloc] initWithString:@"C"] atIndex:2];
    //    NSLog(@"替换前字符串长度: %@", attributedStr);
    
    
    //    NSLog(@"====%s", class_getName([attributedStr class]));
    //    NSLog(@"length: %ld", (long)attributedStr.length);
    //    [attributedStr replaceCharactersInRange:NSMakeRange(10, 9) withString:@"a"];
    //    NSLog(@"替换后字符串长度: %@", attributedStr);
    
    //    NSDictionary *dict = @{@"userName": @"bruce", @"password": @"123456"};
    //    id obj = dict[@"password"];
    //    NSLog(@"class name : %s", class_getName([dict class]));
    //    NSLog(@"obj : %@", obj);
    
    //    id testObj = @"123456";
    //    NSLog(@"testObj : %@", testObj[@"password"]);
    
    //    NSString *test = @"test123";
    //    NSLog(@"className: %s", class_getName([test class]));
    
    //    id str = [[NSMutableString alloc] initWithString:@"test123"];
    //    NSLog(@"className: %s", class_getName([str class]));
    //    NSLog(@"test obj : %@", str[@"password"]);
    
    //    id obj = @{@"test": @"123456"};
    //    NSLog(@"length: %ld", ((NSString *)obj).length);
    
    //    UIWebView *webView = [[UIWebView alloc] init];
    //    NSLog(@"className: %s", class_getName([webView class]));
    
    //    NSMutableString *str = [[NSMutableString alloc] initWithString:@"ABC"];
    //    NSLog(@"class name : %s", class_getName([str class]));
    //    NSLog(@"是否包含: %d", [str containsString:@"D"]);
    
    //    id obj = [NSMutableArray arrayWithObjects:@"A", @"B", @"C", nil];
    //    NSLog(@"className: %s", class_getName([obj class]));
    //    NSLog(@"长度测试: %ld", [obj integerValue]);
    
    //    UISearchBar *searchBar = [[UISearchBar alloc] init];
    //    searchBar.returnKeyType = UIReturnKeySearch;
    
    //    id obj = [[NSNull alloc] init];
    //    NSLog(@"class name: %s", class_getName([obj class]));
    //    NSLog(@"length: %ld", (long)[obj length]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(id)sender {
    UIViewController *test01 = [[UIViewController alloc] init];
    [self.navigationController pushViewController:test01 animated:YES];
    [self.navigationController pushViewController:test01 animated:YES];
    
    //    [self.view addSubview:self.view];
}

@end
