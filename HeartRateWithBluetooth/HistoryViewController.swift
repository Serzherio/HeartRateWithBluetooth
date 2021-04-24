import UIKit
import RealmSwift
import DZNEmptyDataSet

class HistoryViewController: UIViewController {
    
    let tableView = UITableView.init(frame: .zero, style: .grouped)
    let formatter = DateFormatter()
    var trains: Results<Train>!
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { (contex) in
            self.updateLayout(with: size)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateStyle = .short
        trains = realm.objects(Train.self)
        
        self.view.addSubview(self.tableView)
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.updateLayout(with: self.view.frame.size)
        
        setupBackground()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc private func loadList(){
            //load data here
            self.tableView.reloadData()
        }
    
    private func updateLayout(with size: CGSize) {
        self.tableView.frame = CGRect.init(origin: .zero, size: size)
    }
    
    
    func setupBackground() {
        let image = UIImage(named: "Background")
        let imageView = UIImageView(image: image)
        tableView.backgroundView = imageView
        tableView.tableFooterView = UIView()
        imageView.alpha = 1
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "train" {
            
            _ = segue.destination as! ShowTrainViewController
            guard tableView.indexPathForSelectedRow != nil else { return }
//            VC.currentPet = pets[indexPath.row]
            
        } else {return}
    }
    
}





extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.isEmpty ? 0 : trains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
//        let train = Train()
        let train = trains[indexPath.row]
        
        if train != nil {
//            cell.dateOfTrainLabel.text = "Дата тренировки - 11.11.2011"
            cell.dateOfTrainLabel.text = formatter.string(from: train.dateOfTrain!)
//            cell.duringTimeLabel.text = "Продолжительность - 3 часа"
            cell.duringTimeLabel.text = train.duringTime
            cell.heartRateLabel.text = "Средний пульс - 133 уд/мин"
            
        }

        cell.backgroundColor = .clear
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "train", sender: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .destructive, title: "Удалить") {  (contextualAction, view, boolValue) in
            let swipeEditAlertController = UIAlertController (title: "Хотите удалить данные тренировки", message: "", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Удалить", style: .destructive, handler: {_ in
                let train = self.trains[indexPath.row]
                StorageManager.deleteObject(train)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
            let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: {_ in
            })
            swipeEditAlertController.addAction(delete)
            swipeEditAlertController.addAction(cancel)
            self.present(swipeEditAlertController, animated: true)
        }
        editAction.backgroundColor = UIColor.purple
        let swipeActions = UISwipeActionsConfiguration(actions: [editAction])
        return swipeActions
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension HistoryViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Скорее запишите свою первую тренировку!"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), NSAttributedString.Key.foregroundColor: UIColor.systemPink]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        .black
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Подключите Bluetooth пульсометр и нажмите <Начать тренировку> на главном экране"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body), NSAttributedString.Key.foregroundColor: UIColor.white]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "Стрелка")
    }
}
