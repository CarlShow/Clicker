import UIKit
import FirebaseFirestore
class ViewController: UIViewController
{
    @IBOutlet weak var tapable: UIButton!
    @IBOutlet weak var barTimer: UIProgressView!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var reset: UIBarButtonItem!
    let database = Firestore.firestore()
    var timer: Timer!
    var mass = 0
    var clicks = 0
    var interval = 5
    var actTimecreep = 0.00
    var isActive = false
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
    }
    // MARK: - Intermediate Functions
    @IBAction func start(_ sender: Any)
    {
        if isActive
        {
            if ((clicks)%50) == 0
            {
                interval *= 2
            }
            barTimer.progress -= 0.0005
        }
        else
        {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
            isActive = true
            pauseButton.image = UIImage(systemName: "pause.fill")
        }
        if clicks%(10 + interval/100) == 0 && clicks > 25
        {
            tapable.tintColor = #colorLiteral(red: 0.4700741768, green: 0.7019193769, blue: 0.192442596, alpha: 1)
            UIView.animate(withDuration: 1, delay: 0.13, options: .curveEaseOut, animations:
                {
                    self.tapable.tintColor = #colorLiteral(red: 0.8101776838, green: 0.5641495585, blue: 1, alpha: 1)
                }
              , completion:
                {
                    _ in self.tapable.tintColor = #colorLiteral(red: 0.8101776838, green: 0.5641495585, blue: 1, alpha: 1)
                }
            )
            mass += interval
        }
        else
        {
            mass += 1 + interval/100
        }
        clicks += 1
        amount.text = "\(mass)"
    }
    @IBAction func toReset(_ sender: Any)
    {
        invalidate()
    }
    @objc func onTimer()
    {
        if barTimer.progress >= 1
        {
            timer.invalidate()
            let err = UIAlertController(title: "Time limit reached!", message: "Would you like to submit a score?", preferredStyle: .alert)
            err.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { _ in self.submitScore()}))
            err.addAction(UIAlertAction(title: "Abstain", style: .default, handler: { _ in self.invalidate()}))
            present(err, animated: true, completion: nil)
        }
        else
        {
            if isActive == true
            {
            barTimer.progress += Float(timer.timeInterval/50)
            }
        }
    }
    @IBAction func toPause(_ sender: Any)
    {
        if isActive
        {
            isActive = false
            pauseButton.image = UIImage(systemName: "play.fill")
        }
        else
        {
            
            isActive = true
            pauseButton.image = UIImage(systemName: "pause.fill")
        }
    }
    // MARK: - Basic Functions
    func invalidate()
    {
        timer.invalidate()
        isActive = false
        barTimer.progress = 0.002
        amount.text = "- Your Score -"
        tapable.tintColor = #colorLiteral(red: 0.1300368011, green: 0.134795934, blue: 0.1339778006, alpha: 0.7961082206)
        mass = 0
        clicks = 0
        interval = 1
    }
    func submitScore()
    {
        var name = ""
        let err = UIAlertController(title: "Please print your name", message: "", preferredStyle: .alert)
        err.addTextField{(textField) in
            textField.placeholder = "Name"}
        err.addAction(UIAlertAction(title: "Submit", style: .default, handler: { alert -> Void in
            name = err.textFields![0].text ?? "Unknown"; self.submitScoreCon(name: name)}))
        present(err, animated: true, completion: nil)
    }
    func submitScoreCon(name: String)
    {
        var UserScore = 0
        let docRe = database.document("Scores/\(name)")
        docRe.getDocument{
            snapshot, error in
            guard let data = snapshot?.data(), error == nil else {return}
            UserScore = data["text"] as? Int ?? 0
        }
        if mass > UserScore
        {
            docRe.setData(["Score": mass])
        }
        invalidate()
    }
}
