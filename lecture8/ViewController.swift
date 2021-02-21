import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var feelsLikeTemp: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var prevCityBtn: UIButton!
    @IBOutlet weak var nextCityBtn: UIButton!
    
    let url = Constants.host
    var myData: Model?
    let cityArr=["Astana","Almaty","Shymkent"]
    var cityId=0
    private var decoder: JSONDecoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil),
                           forCellReuseIdentifier: "tableCell")
        tableView.rowHeight=71
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        cityName.text = cityArr[cityId]
        fetchData()
        style()
    }
    
    @IBAction func tapToPrev(_ sender: Any) {
        if cityId != 0{
            cityId -= 1
            cityName.text = cityArr[cityId]
        }
    }
    
    @IBAction func tapToNext(_ sender: Any) {
        if cityId != cityArr.count-1{
            cityId += 1
            cityName.text = cityArr[cityId]
        }
    }
    
    
    func updateUI(){
        temp.text = "\(myData?.current?.temp ?? 0.0)"
        feelsLikeTemp.text = "\(myData?.current?.feels_like ?? 0.0)"
        desc.text = myData?.current?.weather?.first?.description
        collectionView.reloadData()
    }
    
    func fetchData(){
        AF.request(url).responseJSON { (response) in
            switch response.result{
            case .success(_):
                guard let data = response.data else { return }
                guard let answer = try? self.decoder.decode(Model.self, from: data) else{ return }
                self.myData = answer
                self.updateUI()
            case .failure(let err):
                print(err.errorDescription ?? "")
            }
        }
    }
    
    func style()  {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "grom.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    func getDate(count: Int)->String{
        let today = Date()
        let nextDate = Calendar.current.date(byAdding: .day,value: count,to: today)
        let dateFormatter = DateFormatter()
        
        if count==0{
            return "Today"
        }else if count < 7{
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: nextDate!)
        }
        else{
            dateFormatter.dateFormat = "dd MMM"
            return dateFormatter.string(from: nextDate!)
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableViewCell
        
        let item = myData?.hourly?[indexPath.item]
        cell.dayLabel.text="\(getDate(count: indexPath.row))"
        cell.tempLabel.text="\(item?.temp ?? 0.0)ºC"
        cell.cloudsLabel.text=item?.weather?.first?.description
        cell.feelsLike.text="\(item?.feels_like ?? 0.0)"
        return cell
    }
}

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myData?.hourly?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        let item = myData?.hourly?[indexPath.item]
        cell.temp.text = "\(item?.temp ?? 0.0)"
        cell.feelsLike.text = "\(item?.feels_like ?? 0.0)"
        cell.desc.text = item?.weather?.first?.description
        
        return cell
        
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
