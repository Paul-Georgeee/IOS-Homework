//
//  FetchNews.swift
//  ITSC
//
//  Created by nju on 2022/11/17.
//

import UIKit
import WebKit


struct News{
    var title: String
    var date: String
    var url: String
    var body: String
}
class FetchNews: NSObject {
    var newsList = [[News](), [News](), [News](), [News]()]
    var newsHtml = [String]()
    var newsUrl = ["https://itsc.nju.edu.cn/xwdt/list.htm", "https://itsc.nju.edu.cn/tzgg/list.htm", "https://itsc.nju.edu.cn/wlyxqk/list.htm", "https://itsc.nju.edu.cn/aqtg/list.htm"]
    var errorFlag = false
    var finishFlag = false
    func loadList(index: Int)
    {
        let task = URLSession.shared.dataTask(with: URL(string: self.newsUrl[index])!, completionHandler: {
            data, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.errorFlag = true
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else{
                DispatchQueue.main.async {
                    self.errorFlag = true
                }
                return
            }
            
            if let mimeType = httpResponse.mimeType, mimeType == "text/html", let data = data, let text = String(data: data, encoding: .utf8){
                let regex = try! NSRegularExpression(pattern: "<li class=\"news n[0-9]* clearfix\">[\\s]*?<span class=\"news_title\">[\\s]*?<a href='([\\S]*?)' [\\s\\S]*?>([\\S\\s]*?)</a>[\\s]*?</span>[\\s]*?<span class=\"news_meta\">([\\S]*?)</span>[\\s]*?</li>")

                let range = NSRange(location: 0, length: text.count)

                let res = regex.matches(in: text, options: [], range: range)
                for match in res{
                    if match.numberOfRanges != 4
                    {
                        DispatchQueue.main.async {
                            self.errorFlag = true
                        }
                        return
                    }
                    let url = String(text[Range(match.range(at: 1), in: text)!])
                    let title = String(text[Range(match.range(at: 2), in: text)!])
                    let date = String(text[Range(match.range(at: 3), in: text)!])
                    
                    DispatchQueue.main.async {
                        self.newsList[index].append(News(title: title, date: date, url: url, body: ""))
                    }
                }
        
                DispatchQueue.main.async {
                    self.finishFlag = true
                      }
            }
            
        })
        task.resume()
    }
    
}
