import Foundation
import UIKit
import FirebaseFirestore
class LeaderboardController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var leaderTable: UITableView!
    static var count = 0
    let database = Firestore.firestore()
    var counter = 0
    var mutable = ""
    override func viewDidLoad()
    {
        super.viewDidLoad()
        leaderTable.delegate = self
        leaderTable.dataSource = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        database.collection("Scores").getDocuments
        {
            snapshot, error in
            guard error == nil else {return}
            LeaderboardController.count = snapshot!.count
        }
        print(LeaderboardController.count)
        return LeaderboardController.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celSel", for: indexPath)
        let semibase = database.collection("Scores").order(by: "Score", descending: true).limit(to: 10)
        semibase.getDocuments
        {
            snapshot, error in
            guard error == nil else {return}
            let docco = snapshot!.documents[indexPath.row]
            self.mutable = docco.documentID
            self.counter = docco.data()["Score"] as! Int
            print(docco.data()["Score"]! )
            cell.textLabel?.text = "\(self.mutable)"
            cell.detailTextLabel?.text = "\(self.counter)"
        }
        return cell
    }
}
