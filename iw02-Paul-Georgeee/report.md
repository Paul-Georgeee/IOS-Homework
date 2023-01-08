[TOC]

# iw02

## 实现的功能

- 从itsc官网爬取新闻，利用URLSession的task实现异步爬取的功能
- 每个新闻在被点击的时候异步拉取新闻内容和图片，并在本地做好缓存
- 采用stackView和scrollView布局，新闻内容页面可以整体上下滑动和横屏查看

## 实现细节

### ToolBar和Navigation

主要将每个页面要爬取的url传递给对应的tableViewController

```swift
class TabBar: UITabBarController {
    let urls = ["https://itsc.nju.edu.cn/xwdt/list.htm", "https://itsc.nju.edu.cn/tzgg/list.htm", "https://itsc.nju.edu.cn/wlyxqk/list.htm", "https://itsc.nju.edu.cn/aqtg/list.htm"]
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0..<self.viewControllers!.count{
            if let navigation = self.viewControllers![i] as? Navigation{
                navigation.url = self.urls[i]
            }
        }
    }
}
class Navigation: UINavigationController {
    var url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tableViewController = self.viewControllers[0] as? TableViewController {
            tableViewController.url = self.url
        }
    }
}
```

### TableViewController

实现新闻列表的主要逻辑，在这里会对每个新闻的内容和标题等信息进行缓冲，保存在`NewsCache`这个类下中。

```swift
class NewsCache{
    var url = ""
    var title = ""
    var date = ""
    var cache = false
    var contentCache = [ContentsCache]()
}
```

cache适用于标志新闻的详情内容是否已被拉取下来保存，而新闻的内容由文字和图片构成

