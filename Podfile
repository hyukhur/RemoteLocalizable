
target "RemoteLocalizable" do
    platform :ios, "6.0"
    pod 'ZipArchive'
    pod 'TCBlobDownload', '~> 1.4.0'
end

target "RemoteLocalizableTests", :exclusive => true do
    link_with :RemoteLocalizable
    
    pod 'AGAsyncTestHelper'
    # pod 'Expecta',     '~> 0.2.3'   # expecta matchers
    # pod 'OCMock',      '~> 2.2.1'   # OCMock
    # pod 'OCHamcrest',  '~> 3.0.0'   # hamcrest matchers
    # pod 'OCMockito',   '~> 1.0.0'   # OCMock
    # pod 'LRMocky',     '~> 0.9.1'   # LRMocky
    # pod 'Specta'
    pod 'OCMock'
    # pod 'OCHamcrest'
end

