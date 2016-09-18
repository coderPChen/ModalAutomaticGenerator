#import <UIKit/UIKit.h> 
#import <Foundation/Foundation.h> 
@interface Testmodal : NSObject 

@property (strong, nonatomic) NSDictionary *dic;

@property (strong, nonatomic) NSArray *array;

@property (strong, nonatomic) NSString *text;

+ (instancetype)modalWithDiction:(NSDictionry *)dic ;

@end