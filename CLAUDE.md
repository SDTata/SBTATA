# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PhoneLive is a comprehensive iOS live streaming social platform application built primarily in Objective-C with some Swift components. It supports multiple channel configurations (c700LIVE, c601PLAY, c608PLAY, c609PLAY, c623PLAY, c625PLAY, c627PLAY, c628PLAY) with independent configurations and resources for each.

## Development Environment Setup

### Prerequisites
- macOS 10.15 or later
- Xcode 12.0 or later
- CocoaPods 1.10 or later
- Ruby 2.6+ (for fastlane)
- iOS 12.0+ deployment target

### Initial Setup
```bash
# Clone the repository
git clone <repository-url>
cd Live_iOS2

# Install CocoaPods dependencies
pod install

# Open the workspace (NOT the .xcodeproj file)
open phonelive2.xcworkspace
```

### Dependency Installation
```bash
# Update CocoaPods specs
pod repo update

# Install/update all dependencies
pod install

# Clean pods and reinstall (if needed)
rm -rf Pods Podfile.lock
pod install
```

## Key Build Commands

### Building and Running
```bash
# Build for specific channel (e.g., c700LIVE)
xcodebuild -workspace phonelive2.xcworkspace \
  -scheme c700LIVE \
  -configuration Release \
  -derivedDataPath build

# Build for testing
xcodebuild -workspace phonelive2.xcworkspace \
  -scheme c700LIVE \
  -configuration Debug \
  build-for-testing

# Run tests
xcodebuild -workspace phonelive2.xcworkspace \
  -scheme c700LIVE \
  test
```

### Fastlane Build Automation
The project uses fastlane for automated building, versioning, and deployment. Key commands:

```bash
# Install fastlane
bundle install

# Build for specific channel (visitor version)
fastlane ios c700_live_ios
fastlane ios c601_visitors_ios
fastlane ios c608_visitors_ios
fastlane ios c609_visitors_ios
fastlane ios c623_visitors_ios
fastlane ios c625_visitors_ios
fastlane ios c627_visitors_ios

# Build for TestFlight deployment
fastlane ios c700_livetf_ios
fastlane ios c601_visitortf_ios
fastlane ios c608_visitortf_ios
fastlane ios c609_visitortf_ios

# Version management
fastlane ios ios_setVersionNum              # Set version number
fastlane ios ios_addShourtVersionBuild      # Increment build number
fastlane ios ios_addversionnumber           # Add version number
fastlane ios ios_cutversionnumber           # Cut/decrement version number

# Build all targets
fastlane ios allTargets

# Dependency and utilities
fastlane ios podsInstall                    # Install CocoaPods
fastlane ios filesUpload                    # Upload files
fastlane ios telegramMsg                    # Send Telegram notifications
```

## Project Structure

### Main Directories
- **PhoneLive/** - Main application entry point
  - `appdelegate/` - App delegate implementation
  - `Supporting Files/` - Configuration and resources
  - `Info_Resources/` - Channel-specific configuration files
  - `启动图/` - Launch screen assets

- **PhoneLiveSDK/** - Core SDK implementation
  - `Project/` - All functional modules organized by feature
    - `Categories/` - Extension categories
    - `SDK/` - Third-party SDK integrations
    - `开始观看直播/` - Live streaming viewer
    - `个人中心/` - User profile and center
    - `游戏中心/` - Game center module
    - `消息/` - Messaging system
    - `工具类/` - Utility classes
    - `支付相关/` - Payment processing (moved to `新支付相关/`)
    - Other feature modules (video, login, rankings, etc.)

- **fastlane/** - Automated build and deployment configuration
  - `Fastfile` - Build automation lanes for each channel

- **Pods/** - CocoaPods dependencies (generated)

### Multi-Channel Architecture
The project uses a multi-target approach where each channel (c700LIVE, c601PLAY, etc.) has:
- Separate build schemes in the Xcode project
- Channel-specific configuration in `Info_Resources/c{channel}_info.plist`
- Potentially separate assets and localization files
- Distinct bundle identifiers and provisioning profiles

## Core Technologies & Dependencies

### Networking & Data
- **AFNetworking** - HTTP networking framework
- **MJExtension** - JSON/Dictionary serialization
- **OpenSSL-Universal** - Encryption for API communications
- **FFAES** - AES encryption utilities

### UI Components
- **Masonry** - Auto layout constraints
- **YYWebImage** - Image loading and caching
- **MBProgressHUD** - Loading and progress indicators
- **IQKeyboardManager** - Keyboard management
- **JXCategoryView** - Tab/category view controller
- **JXPagingView** - Paging view layouts
- **TZImagePickerController** - Image/video picker
- **LEEAlert**, **SCLAlertView** - Alert dialogs
- **STPopup** - Popup containers
- **DZNEmptyDataSet** - Empty state handling

### Media & Animation
- **SVGAPlayer** - Gift animations (SVGA format)
- **DTCoreText** - Rich text rendering
- **NTESVerifyCode** - Verification code UI

### Analytics & Tracking
- **UMCommon**, **UMDevice**, **UMAPM** - Umeng analytics
- **GrowingAnalytics/Tracker** - Growing.io analytics
- **HappyDNS** - DNS optimization for Qiniu

### Cloud & Storage
- **Qiniu** (v8.7.2+) - Cloud storage and CDN

### Utilities
- **RyukieSwifty** - Swift compatibility layer
- **EBBannerView** - Banner notifications
- **CRBoxInputView** - Input views
- **WMZDialog** - Custom dialogs
- **SwipeTableView** - Swipeable table views
- **JKCountDownButton** - Countdown button component

## API Architecture

### Request Format
- **Base URL**: `{domain}/v1/?service={ServiceName}.{MethodName}`
- **Encryption**: AES encryption for request/response bodies
- **Authentication**: Token-based authentication
- **Domain Management**: Dynamic domain configuration with domain blocking protection

### Main API Modules
- `User.*` - User profile, info, preferences
- `Home.*` - Home feed and discovery content
- `Live.*` - Live streaming operations
- `Login.*` - Authentication and login
- `Message.*` - Messaging and chat
- `Task.*` - Tasks and activities
- `Video.*` - Short video operations
- `Game.*` - Game center functionality

## Debugging & Common Issues

### Pod Installation Issues
```bash
# Clear cache and reinstall
rm -rf ~/Library/Developer/Xcode/DerivedData
pod cache clean --all
pod install --repo-update
```

### Build Failures
- Ensure you're using the workspace (`phonelive2.xcworkspace`) not the project file
- Check that all required frameworks are linked: check Build Phases > Link Binary With Libraries
- For arm64 simulator issues, check `Podfile` post_install hooks (currently commented out)

### Code Signing
- Code signing is disabled for pods in `Podfile` post_install (see lines 95-96)
- Ensure provisioning profiles match the channel's bundle identifier
- Check `Info_Resources/c{channel}_info.plist` for correct provisioning profile settings

## Version Control & Branching

### Current Branch
- Working branch: `3.0.0打包` (3.0.0 packaging branch)
- Main branch: `main`

### Version Number Format
- Major.Minor.Patch (e.g., 3.0.0)
- Use fastlane lanes for version management
- Each channel can have independent version numbers in their plist files

## Multi-Language Support

The application supports multiple locales:
- Simplified Chinese (默认)
- Traditional Chinese
- English
- Japanese
- Indonesian
- Vietnamese

Localized strings are typically handled through `.strings` files or localization frameworks in the SDK.

## Important Notes

### Performance Considerations
- Recent commits (f8d6225b, 218bb168) show focus on concurrent socket operations and WebView request optimization
- The codebase recently removed concurrency limits for full parallel WebView loading (218bb168)
- Socket initialization race conditions have been addressed (f8d6225b)

### Data Security
- All API requests use AES encryption
- Sensitive data stored locally should be encrypted
- Private user information is protected through appropriate permission checks

### Key Permissions
- Camera: Live streaming and recording
- Microphone: Live audio and co-streaming
- Photo Library: Image/video selection
- Notifications: Push notifications
- Location: Nearby features

### Content & Compliance
- Live content goes through a moderation system
- Virtual currency (diamonds, coins) requires proper transaction handling
- Age restrictions apply to certain features
- Multi-region deployment requires compliance verification

## Common Development Tasks

### Adding a New Feature Module
1. Create a new directory under `PhoneLiveSDK/Project/`
2. Follow the existing module organization pattern
3. Update the appropriate scheme's build phases if needed
4. Test with the relevant channel configuration

### Building for Specific Channel
1. Identify the channel code (e.g., c700 for main live)
2. Use corresponding fastlane lane: `fastlane ios c{code}_live_ios` or `fastlane ios c{code}_visitors_ios`
3. For TestFlight: use the `_tf` variant (e.g., `c700_livetf_ios`)

### Debugging Network Issues
- Check domain blocking protection in domain configuration
- Verify AES encryption keys are correctly set
- Use network debugging tools to inspect encrypted payloads
- Review socket connection state in chat listener (`socket 聊天监听` folder)

## File Locations Reference

- Main app delegate: `PhoneLive/appdelegate/`
- Channel info configs: `PhoneLive/Info_Resources/c{channel}_info.plist`
- Categories/extensions: `PhoneLiveSDK/Project/Categories/`
- Utility classes: `PhoneLiveSDK/Project/工具类/`
- Socket chat listener: `PhoneLiveSDK/Project/socket 聊天监听/`
- Domain detection: `PhoneLiveSDK/Project/域名检测/`
- Resource management: `PhoneLiveSDK/Project/资源管理/`
- Payment implementation: `PhoneLiveSDK/Project/新支付相关/`
- Third-party SDKs: `PhoneLiveSDK/Project/SDK/`
