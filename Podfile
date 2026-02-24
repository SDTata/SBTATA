platform :ios, '12.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/ElfSundae/CocoaPods-Specs.git'
#post_install do |installer|
#  installer.pods_project.build_configurations.each do |config|
#    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#  end
#end

targetsArray = ['c700LIVE','c601PLAY','c608PLAY','c609PLAY','c628PLAY','c623PLAY','c625PLAY','c627PLAY','c629PLAY','c630PLAY','c631PLAY','AnchorLiveSDK',"PhoneSDK"]
#targetsArray = []


targetsArray.each do |t|
  target t do
#    use_frameworks!
use_modular_headers!
    #图片
#    pod 'SDWebImage'
    #网络请求
    pod 'AFNetworking'
    pod 'DTCoreText'
    pod 'OpenSSL-Universal'
  
#    , :configurations => ['Debug','Release','DebugPlay', 'ReleasePlay'] if !ENV['SIMULATOR_DEVICE_NAME']
#    pod 'CocoaAsyncSocket', '~> 7.6.5'
    #极光
#    pod 'JPush'
#    pod 'JMessage'
    #支付宝
#    pod 'AliPay'
    #分享
    pod 'YYWebImage'
    #友盟统计
    pod 'MBProgressHUD', '~> 1.0.0'
    pod 'EBBannerView'
    #开屏广告
#    pod 'FLAnimatedImage'
    pod 'CRBoxInputView', '1.1.5'
    pod 'WMZDialog'
    pod 'SwipeTableView'
#    pod 'LookinServer', :configurations => ['Debug']
 
    pod 'SVGAPlayer'
 
 
    pod 'MJExtension'
    pod 'IQKeyboardManager'
    
#    pod 'GrowingCoreKit'
#    pod 'JhtMarquee'
    pod 'GrowingAnalytics/Tracker'
  

#    pod 'LSSafeProtector' #中止崩溃
    pod 'FFAES'
#    pod 'Bugly'
    pod 'RyukieSwifty'
    
    pod 'UMCommon'
    pod 'UMDevice'
    pod 'UMAPM'
    
    pod 'SCLAlertView-Objective-C'
    pod "Qiniu", "~> 8.7.2"
#    pod 'AppsFlyerFramework'
#    pod 'AliyunLogProducer'

    pod 'DZNEmptyDataSet'
    pod 'LEEAlert'
    pod 'STPopup'
    pod 'JKCountDownButton'
    pod 'JXPagingView'
    pod 'TZImagePickerController'
    pod 'NTESVerifyCode', '~> 3.6.7'
    # 移到專案 SDK
    # pod 'ZFPlayer/ijkplayer', '~> 4.1.4' 
    # 移到專案 SDK
    # pod 'KTVHTTPCache', '~> 3.0.2'
    
#    if 'c700LIVE' == t || 'AnchorLiveSDK' == t
#      pod 'FURenderKit'
#    end
    
  end
  
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['CODE_SIGN_IDENTITY'] = ''
        
#         config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = ""
#          config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
       
      end
    end
  end
end
