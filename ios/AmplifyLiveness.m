#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AmplifyLiveness, NSObject)
RCT_EXTERN_METHOD(startLiveness:(NSDictionary *)input
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end
