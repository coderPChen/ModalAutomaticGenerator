//
//  ViewController.m
//  testModal
//
//  Created by yjin on 16/6/27.
//  Copyright © 2016年 pchen. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *TextView;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;

// 存放文件路劲
@property (weak, nonatomic) IBOutlet UITextField *textFieldModalPath;


@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [_TextView resignFirstResponder];
    [_textFieldName resignFirstResponder];
}

- (IBAction)ButtonOKClick:(id)sender {
    
    [_TextView resignFirstResponder];
    [_textFieldName resignFirstResponder];
    if (_TextView.text.length == 0 || _textFieldName.text.length == 0|| _textFieldModalPath.text.length == 0) {
        
        [self showTitle:@"输入对应的数据"];
        return;
    }
    
    
    [self cleateModalFile];
    
}


- (void)showTitle:(NSString *)title {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.margin = 10.f;
    hud.yOffset = 100.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:3];
  
    
}

- (NSString *)dealKey:(NSString *)key {
    
    if ([key isEqualToString:@"id"]) {
        
        return @"idModal";
    }
    return key;
    
}


- (void)dealHFileKey:(NSArray *)arrayKey  dic:(NSDictionary *)dic string:(NSMutableString *)stringM{
    
    for (NSString *key in arrayKey) { // 设置 .h 文件
        
        NSString *keyClass =  NSStringFromClass([dic[key] class]);
        if ( [keyClass rangeOfString:@"NSDictionary"].length != 0) {
            
            keyClass = @"NSDictionary";
            
        }else if ([keyClass rangeOfString:@"NSArray"].length != 0 ) {
            
            keyClass = @"NSArray";
        }else {
            keyClass = @"NSString";
        }
        
        
        NSString *stringKey = [NSString stringWithFormat:@"@property (strong, nonatomic) %@ *%@;\n\n",keyClass,[self dealKey:key]];
        
        [stringM appendString:stringKey];
        
    }
    
}


- (void)cleateModalFile {
    
    // 需要设置这个ModalName
    NSString *modalName = _textFieldName.text;
    // 存放文件路径
    NSString *documentsDirectory =   _textFieldModalPath.text; ;
    
    NSData *data =  [_TextView.text dataUsingEncoding:NSUTF8StringEncoding];
    
     id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSAssert([object isKindOfClass:[NSDictionary class]] == YES, @"json 返回的类型只能是字典 ");
    
    NSDictionary *dic = object;
    
    NSArray *arrayKey = [dic allKeys];
    
    NSString *stringMethod = @"+ (instancetype)modalWithDiction:(NSDictionry *)dic ";
    
    [self ctreateHFile:documentsDirectory modalName:modalName stringMethod:stringMethod array:arrayKey dic:dic] ;


    [self ctreateModalForMFile:documentsDirectory modalName:modalName stringMethod:stringMethod array:arrayKey];
    
    [self showTitle:@"生成完成"];
    
}



- (void)ctreateHFile:(NSString *)documentsDirectory  modalName:(NSString *)modalName stringMethod:(NSString *)stringMethod array:(NSArray *)arrayKey dic:(NSDictionary *)dic{
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    [[NSFileManager defaultManager]   createDirectoryAtPath: documentsDirectory attributes:nil];
    
    NSString *filePathH= [documentsDirectory
                          stringByAppendingPathComponent:    [NSString stringWithFormat:@"%@.h",modalName]];
    
    
    [fileManager createFileAtPath:filePathH contents:nil attributes:nil];
    
    NSFileHandle *writeFile = [NSFileHandle fileHandleForWritingAtPath:filePathH];
    
    NSAssert(writeFile != nil, @"文件路劲出现错误,最好填写绝对路径：");
    
    // 开头：
    
    NSMutableString *bodyH = [NSMutableString stringWithFormat:@"#import <UIKit/UIKit.h> \n#import <Foundation/Foundation.h> \n@interface %@ : NSObject \n\n",modalName];
    
    
    NSAssert(arrayKey.count != 0, @"json 数组为 空");
    
    [self dealHFileKey:arrayKey dic:dic string:bodyH];
    
    NSError *error = nil;

    
    [bodyH appendString:[NSString stringWithFormat:@"%@;\n",stringMethod]];
    
    [bodyH appendString:@"\n@end"];
    [bodyH writeToFile:filePathH atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    
    
}



- (void)ctreateModalForMFile:(NSString *)documentsDirectory  modalName:(NSString *)modalName stringMethod:(NSString *)stringMethod array:(NSArray *)arrayKey {
    
    NSString *filePathM= [documentsDirectory
                          stringByAppendingPathComponent:    [NSString stringWithFormat:@"%@.m",modalName]];
    
    
    [[NSFileManager defaultManager] createFileAtPath:filePathM contents:nil attributes:nil];
    
    NSFileHandle *writeFileM = [NSFileHandle fileHandleForWritingAtPath:filePathM];
    
    NSAssert(writeFileM != nil, @"");
    
    NSMutableString *bodyM = [NSMutableString stringWithFormat:@"#import \"%@.h\" \n@implementation %@ \n \n \n",modalName,modalName];
    
    [bodyM appendString:[NSString stringWithFormat:@"%@{ \n\n\n",stringMethod]];
    
    NSString *objectName = @"modal";
    NSString *cleateObject = [NSString stringWithFormat:@"%@ *%@ = [[%@ alloc] init];\n",modalName,objectName,modalName];
    [bodyM appendString:cleateObject];
    
    for (NSString *key  in arrayKey) { // 处理.M Key
        
        
        NSString *oneKey = [NSString stringWithFormat:@"%@.%@ = dic[@\"%@\"];\n",objectName,[self dealKey:key],key];
        [bodyM appendString:oneKey];
    }
    
    [bodyM appendString: [NSString stringWithFormat:@"return %@;\n",objectName]];
    [bodyM appendString: @"\n} \n"];
    
    [bodyM appendString:@"\n \n @end"];
    
    [bodyM writeToFile:filePathM atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
