import UIKit
import WebKit

class collecViewCell: UICollectionViewCell {

    @IBOutlet var container1: UIView!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var textLbl: UILabel!
    
    @IBOutlet var black_screen: UIView!
    
    let urls : [URL] = [
                        URL(string: "https://d.ibtimes.co.uk/en/full/1464094/baby-hand.jpg?w=700")!,
                        URL(string: "https://www.youtube.com/embed/ucts039wCPo" )!,
                        URL(string: "https://www.yumama.com/thumbnail.php?file=2014/07/najpopularnija_zenska_imena_u_hrvatskoj_aps_978079305.jpg&size=article_large" )!,
                        URL(string: "http://alwaysbusymama.com/images/content/383-zdorovyj-detskij-son-10-pravil.jpg")!,
                        URL(string: "https://m.static.lagardere.cz/frekvence1/edee/clanky/21974/kluk.jpg")!
                        ]
    
    let stories : [String] = [
        "חשוב שתדעו... תינוק נלקח מהוריו אם הם לא דואגים לצרכיו, לכן ההורים לא מדווחים לרשויות. הרשויות לא יודעות על קיומם של תינוקות נזקקים. זו הסיבה שבגללה הקמנו את הבנק החברתי למזון לתינוקות.",
        "",
        "יחד מעלים את המודעות של הציבור לתינוקות רעבים. שתפו עם חברים, תמליצו על הפרויקט, התינוקות האלו בידיים שלנו, בואו נראה להם למה אנחנו מסוגלים.",
        "גיוס תרומות מהציבור לטובת הקמת בנק חברתי למזון תינוקות",
        "עלות מזון תינוקות לחודש כ 300 - 400 ש״ח, התינוקות האלו זקוקים לך. בעזרת תרומתך תינוק נוסף יוכל לישון שבע."
]

    override func awakeFromNib() {
        super.awakeFromNib()
       
        DispatchQueue.main.async {
            //self.container1.layer.cornerRadius = 15.0
            //self.container1.layer.shadowColor = UIColor.lightGray.cgColor
            //self.container1.layer.shadowOpacity = 0.2
            //self.container1.layer.shadowOpacity = 0.2
            //self.container1.layer.shadowOffset = .zero
            //self.container1.layer.shadowPath = UIBezierPath(rect: self.container1.bounds).cgPath
            self.container1.layer.shouldRasterize = true
        }
        
    }

}
