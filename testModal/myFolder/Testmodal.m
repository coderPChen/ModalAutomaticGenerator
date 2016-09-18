#import "Testmodal.h" 
@implementation Testmodal 
 
 
+ (instancetype)modalWithDiction:(NSDictionry *)dic { 


Testmodal *modal = [[Testmodal alloc] init];
modal.dic = dic[@"dic"];
modal.array = dic[@"array"];
modal.text = dic[@"text"];
return modal;

} 

 
 @end