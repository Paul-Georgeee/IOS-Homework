//
//  TableViewController.swift
//  ITSC
//
//  Created by nju on 2022/11/17.
//

import UIKit

class ContentsCache:NSObject{
}
class ParagraphCache: ContentsCache{
    var paragraph = ""
}
class ImageCache: ContentsCache{
    var image :UIImage? = nil
}

class NewsCache{
    var url = ""
    var title = ""
    var date = ""
    var cache = false
    var contentCache = [ContentsCache]()
    init(_url: String, _title: String, _date: String)
    {
        self.url = _url
        self.title = _title
        self.date = _date
    }
}

class TableViewController: UITableViewController {

    
    var newsCache = [NewsCache]()
    var newsCnt = 0
    var defaultImage = UIImage(named: "./logo.jpeg", in: nil, with: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadList(url)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.newsCache.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell

        // Configure the cell..
        if indexPath.row < self.newsCache.count
        {
            cell.dateLabel.text! = self.newsCache[indexPath.row].date
            cell.titleLabel.text! = self.newsCache[indexPath.row].title
            var flag = true
            for content in self.newsCache[indexPath.row].contentCache{
                if let image = content as? ImageCache{
                    cell.newsImage.image = image.image
                    flag = false
                    break
                }
            }
            if flag{
                cell.newsImage.image = self.defaultImage
            }
        }
        return cell
    }
    
    
    // Mark:
    func ParseHTML(_ re: String, _ text: String) -> [NSTextCheckingResult]
    {
        let regex = try! NSRegularExpression(pattern: re)
        let range = NSRange(location: 0, length: text.count)
        return regex.matches(in: text, options: [], range: range)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableCell = sender as? TableViewCell{
            let dest = segue.destination as! ViewController
            dest.dateStr = tableCell.dateLabel.text!
            
            let indexPath = self.tableView.indexPath(for: tableCell)!
            let newsContent = self.newsCache[indexPath.row]
            //if cached
            if indexPath.row < self.newsCache.count && self.newsCache[indexPath.row].cache
            {
                dest.cached = true      //cacahe flag
                dest.titleStr = newsContent.title      //title
                //paragraph and image
                for cachedItem in newsContent.contentCache{
                    if let paragraphCache = cachedItem as? ParagraphCache{
                        let contentLabel = UILabel()
                        contentLabel.numberOfLines = 0
                        contentLabel.text = paragraphCache.paragraph
                        dest.contents.append(contentLabel)
                    }
                    else if let imageCache = cachedItem as? ImageCache{
                        let contentImage = UIImageView()
                        contentImage.image = imageCache.image
                        dest.contents.append(contentImage)
                    }
                }
                return
            }
            
            //request for the news contents
            let task = URLSession.shared.dataTask(with: URL(string: newsContent.url)!, completionHandler: {
                data, response, error in
                if error != nil{
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else{
                    return
                }
                if let mimeType = httpResponse.mimeType, mimeType == "text/html", let data = data, let text = String(data: data, encoding: .utf8){
                    //Get Title
                    var newsTitle = ""
                    let titleRes = self.ParseHTML("<h1 class=\"arti_title\">([\\S\\s]*?)</h1>", text)
                    if(titleRes.count == 1 && titleRes[0].numberOfRanges == 2){
                        newsTitle = String(text[Range(titleRes[0].range(at: 1), in: text)!])
                    }
                    DispatchQueue.main.async {
                        newsContent.title = newsTitle.count == 0 ? newsContent.title : newsTitle
                        dest.titleStr = newsContent.title
                    }
                    
                    //Get Contents
                    var res = self.ParseHTML("<div class='wp_articlecontent'>([\\s\\S]*?)</div>", text)
                    if(res.count == 1 && res[0].numberOfRanges == 2){
                        let paragraphs = String(text[Range(res[0].range(at: 1), in: text)!])
                       
                        //split into paragraph
                        res = self.ParseHTML("<p [\\S\\s]*?>[\\S\\s]*?</p>", paragraphs)
                        var flag = false
                        for (i, match) in res.enumerated()
                        {
                            var paragraph = String(paragraphs[Range(match.range(at: 0), in: paragraphs)!])
                            //this paragraph is an image
                            if(paragraph.contains("<img")){
                                //To remain the order of between the image and words,
                                //we should insert the view before requesting for the image
                                DispatchQueue.main.async {
                                    dest.contents.append(UIImageView())
                                    let cachedImage = ImageCache()
                                    newsContent.contentCache.append(cachedImage)
                                }
                                
                                //get the url of image
                                let result = self.ParseHTML("src=\"([\\s\\S]*?)\"", paragraph)
                                for matchImage in result{
                                    if matchImage.numberOfRanges != 2{
                                        continue
                                    }
                                    
                                    var imageurl =  String(paragraph[Range(matchImage.range(at: 1), in: paragraph)!])
                                    if imageurl.hasPrefix("/"){
                                        imageurl.insert(contentsOf: "https://itsc.nju.edu.cn",  at: imageurl.startIndex)
                                    }
                                    
                                    //request for the image
                                    let imageTask = URLSession.shared.dataTask(with: URL(string: imageurl)!, completionHandler: {
                                        data, response, error in
                                        
                                        if error != nil {
                                            return
                                        }

                                        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else{
                                            return
                                        }
                                        
                                        let image = UIImage(data: data!)
                                        //cache and update
                                        DispatchQueue.main.async {
                                            let imageView = dest.contents[i] as! UIImageView
                                            imageView.image = image
                                            
                                            let cachedImage = newsContent.contentCache[i] as! ImageCache
                                            cachedImage.image = image
                                            
                                            //let the first image of the news become the news cover
                                            if flag == false{
                                                flag = true
                                                tableCell.newsImage.image = image
                                            }
                                        }
                                    })
                                    imageTask.resume()
                                }
                                
                            }
                            else{
                                //this paragraph is a string
                                //first filter the html label
                                let result = self.ParseHTML("<[\\s\\S]*?>", paragraph)
                                var deleteLen = 0
                                
                                for filterRange in result{
                                    let rangeBegin = filterRange.range(at: 0).lowerBound
                                    let rangeEnd = filterRange.range(at: 0).upperBound
                                    let strBegin = paragraph.index(paragraph.startIndex, offsetBy: rangeBegin - deleteLen)
                                    let strEnd = paragraph.index(paragraph.startIndex, offsetBy: rangeEnd - deleteLen)
                                    deleteLen = deleteLen + rangeEnd - rangeBegin
                                    paragraph.removeSubrange(strBegin..<strEnd)
                                }
                                //replace some special charaters in html, here only handle the space
                                paragraph = paragraph.replacingOccurrences(of: "&nbsp;", with: " ")
                                //cached and update the content view
                                DispatchQueue.main.async {
                                    let labelView = UILabel()
                                    labelView.numberOfLines = 0
                                    labelView.text = paragraph
                                    dest.contents.append(labelView)
                                    
                                    let paragraphCache = ParagraphCache()
                                    paragraphCache.paragraph = paragraph
                                    newsContent.contentCache.append(paragraphCache)
                                }
                                
                            }
                        }
                        
                        
                    }
                        //finally done, let content view update
                        DispatchQueue.main.async {
                            dest.load()
                            newsContent.cache = true
                        }
                }
                    
            })
            task.resume()
            
        }
    }

   
    var url = ""
    func loadList(_ url: String)
    {
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {
            data, response, error in
            if error != nil {
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else{
                
                return
            }
            var indexPaths = [IndexPath]()
            if let mimeType = httpResponse.mimeType, mimeType == "text/html", let data = data, let text = String(data: data, encoding: .utf8){
                let re = "<li class=\"news n[0-9]* clearfix\">[\\s]*?<span class=\"news_title\">[\\s]*?<a href='([\\S]*?)' [\\s\\S]*?>([\\S\\s]*?)</a>[\\s]*?</span>[\\s]*?<span class=\"news_meta\">([\\S]*?)</span>[\\s]*?</li>"
                let res = self.ParseHTML(re, text)
                for match in res{
                    if match.numberOfRanges != 4
                    {
                        return
                    }
                    let url = "https://itsc.nju.edu.cn" + String(text[Range(match.range(at: 1), in: text)!])
                    let title = String(text[Range(match.range(at: 2), in: text)!])
                    let date = String(text[Range(match.range(at: 3), in: text)!])
                    indexPaths.append(IndexPath(item: self.newsCache.count, section: 0))
                    self.newsCache.append(NewsCache(_url: url, _title: title, _date: date))
                }
                DispatchQueue.main.async {
                    self.tableView.insertRows(at: indexPaths, with: .fade)
                }
                
                let nextPage = self.ParseHTML("<a class=\"next\" href=\"([\\S\\s]*?)\" target=\"_self\">[\\S\\s]*?<span>[\\S\\s]*?下一页[\\S\\s]*?</span>[\\S\\s]*?</a>", text)
                if(nextPage.count == 1)
                {
                    let nextPageUrl = "https://itsc.nju.edu.cn" + String(text[Range(nextPage[0].range(at: 1), in: text)!])
                    if nextPageUrl.hasSuffix("htm"){
                        DispatchQueue.main.async {
                            self.loadList(nextPageUrl)
                        }
                    }
                }
                
            }
            
        })
        task.resume()
    }

}
