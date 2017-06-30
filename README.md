# ATPluginToggler

Simple Objective-C class to enable or disable plugins on macOS (wrapping the pluginkit command line tool).

## Interface

```
@interface ATPluginToggler : NSObject

/**
 @return YES if a plugin with the given bundleIdentifier is enabled, otherwise NO.
 */
+(BOOL)isPluginWithBundleIdentifierEnabled:(nonnull NSString*)bundleIdentifier;

/**
 Call to enable a plugin with the given bundle identifier.
 */
+(BOOL)enablePluginWithBundleIdentifier:(nonnull NSString*)bundleIdentifier;

/**
 Call to disable a plugin with the given bundle identifier.
 */
+(BOOL)disablePluginWithBundleIdentifier:(nonnull NSString*)bundleIdentifier;

@end
```