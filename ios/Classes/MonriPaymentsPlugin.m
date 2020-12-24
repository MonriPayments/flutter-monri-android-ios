#import "MonriPaymentsPlugin.h"
#if __has_include(<MonriPayments/MonriPayments-Swift.h>)
#import <MonriPayments/MonriPayments-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "MonriPayments-Swift.h"
#endif

@implementation MonriPaymentsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMonriPaymentsPlugin registerWithRegistrar:registrar];
}
@end
