
import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        initActivityIndicator()
        loadPageInWebView(url: "https://unsplash.com/")
        TestClass.shared().printTest()
        
    }
    
    @IBAction func refreshWebView(_ sender: Any) {
        webView.reload()
    }
    
    @IBAction func stopLoadingWebView(_ sender: Any) {
        webView.stopLoading()
    }
    
    @IBAction func forwardWebView(_ sender: Any) {
        webView.goForward()
    }
    
    @IBAction func backWebView(_ sender: Any) {
        webView.goBack()
    }
    
    func loadPageInWebView(url: String) {
        if let requestUrl = URL(string: url) {
            webView.loadRequest(URLRequest(url: requestUrl))
        }
    }
    
    func initActivityIndicator() {
        activityIndicator.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        activityIndicator.backgroundColor = UIColor.gray
        activityIndicator.layer.cornerRadius = 20.0
        activityIndicator.frame = .init(x: self.view.bounds.size.width/2 - 20, y: self.view.bounds.size.height/2 - 20, width: 40.0, height: 40.0)
    }
    
    func showActivityIndicator() {
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
    
    func hideActivityIndicator() {
        self.view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadErrorHtmlPage() {
        let htmlFile = Bundle.main.path(forResource: "index", ofType: "html")
        if let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8) {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func handleWebViewResponse() {
        if let request = webView.request {
            if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
                if let response = cachedResponse.response as? HTTPURLResponse {
                    
                    if response.statusCode >= 200 || response.statusCode < 300 {
                        print("Success")
                    } else if response.statusCode >= 300 && response.statusCode < 400 {
                        print("Redirection")
                    } else if response.statusCode >= 400 && response.statusCode < 500 {
                        print("Client error")
                    } else if response.statusCode >= 500 {
                        print("Server error")
                    }
                    
                }
            }
        }
    }

}

extension MainViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        showActivityIndicator()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideActivityIndicator()
        handleWebViewResponse()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hideActivityIndicator()
        
        if error.code == NSURLErrorCancelled {
            print("catch 999 error")
            return
        }
        
        handleWebViewResponse()
        showErrorAlert(error: error)
    }
    
}

extension Error {
    var code: Int {
        return (self as NSError).code
    }
}

