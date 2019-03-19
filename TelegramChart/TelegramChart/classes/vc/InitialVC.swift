//
//  InitialVC.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/19/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

class ChartPreviewCell: UITableViewCell {
    static let id = "kChartPreviewCell"

    var slice:Slice? {
        didSet { updateSlice() }
    }

    override class var layerClass: AnyClass { return ChartTileLayer.self }

    @IBOutlet var titleLabel: UILabel?

    var tileLayer: ChartTileLayer? {
        get { return layer as? ChartTileLayer }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.layer.isGeometryFlipped = true
    }

    override func prepareForReuse() {
        tileLayer?.clear()
        titleLabel?.text = ""
    }

    func setPathModels(_ paths:[PathModel]?) {
        tileLayer?.setPathModels(paths)
    }

    private func updateSlice() {
        guard let tileLayer = self.tileLayer else { return }
        if let slice = self.slice {
            tileLayer.setPathModels(slice.pathModels)
        } else {
            tileLayer.clear()
        }
    }
}

class ChartInfoCell: UITableViewCell {
    static let id = "kChartInfoCell"
    @IBOutlet weak var infoLabel: UILabel!
}

class InitialVC: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    var graphicsContainer:GraphicsContainer?
    let lineWidth = CGFloat(1)
    let cellPreviewHeight = CGFloat(100)
    let cellInfoHeight = CGFloat(40)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Telegram test project"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLoadingData()
    }

    @IBAction func loadData(_ sender: AnyObject) {
        startLoadingData()
    }

    @IBAction func showProjectInfo(_ sender: AnyObject) {
        print("showProjectInfo not implemented yet")
    }

    private func startLoadingData() {
        loadDataInBackground() { [weak self] container, error in
            if let error = error {
                let alert = UIAlertController(title:"Error", message:error.localizedDescription, preferredStyle:.alert)
                alert.addAction(UIAlertAction(title:"Dismiss", style:.cancel, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated:true, completion:nil)
            } else if let container = container {
                self?.graphicsContainer = container
                self?.tableView.reloadData()
            } else {
                print("OOPS!! something went really wrong")
            }
        }
    }

    private func loadDataInBackground(completion:@escaping (GraphicsContainer?, NSError?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            var err:NSError?
            var graphicsContainer:GraphicsContainer?
            let url = Bundle.main.url(forResource: "chart_data", withExtension: "json")
            if let url = url {
                do {
                    let jsonData = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    do {
                        graphicsContainer = try decoder.decode(GraphicsContainer.self, from: jsonData)
                    } catch {
                        err = NSError("cannot decode json")
                    }
                }
                catch {
                    err = NSError("cannot read file at \(url)")
                }
            } else {
                err = NSError("no json")
            }

            DispatchQueue.main.async {
                completion(graphicsContainer, err)
            }
        }
    }
}

extension InitialVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let container = graphicsContainer, 0 == indexPath.section {
            print("tap: \(indexPath.row)")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let _ = graphicsContainer, 0 == indexPath.section {
            return cellPreviewHeight
        }
        return cellInfoHeight
    }
}

extension InitialVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = graphicsContainer {
            return 2
        }
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let container = graphicsContainer, 0 == section {
            return container.size
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let container = graphicsContainer {
            if 0 == indexPath.section {
                let cell = tableView.dequeueReusableCell(withIdentifier:ChartPreviewCell.id)
                configPreviewCell(cell as! ChartPreviewCell, index:indexPath.row)
                return cell!
            }

            // show chart info
            let cell = tableView.dequeueReusableCell(withIdentifier:ChartInfoCell.id)
            if let infoCell = cell as? ChartInfoCell {
                infoCell.infoLabel.text = "\(container.size) charts loaded"
            }
            return cell!
        }

        // nothing loaded, empty table
        let cell = tableView.dequeueReusableCell(withIdentifier:ChartInfoCell.id)
        if let infoCell = cell as? ChartInfoCell {
            infoCell.infoLabel.text = "No charts loaded"
        }
        return cell!
    }

    private func configPreviewCell(_ cell:ChartPreviewCell, index:Int) {
        if let container = graphicsContainer {
            let plane = container.planes[index]
            // new logic canvas, create and init
            let logicCanvas = LogicCanvas(plane: plane)
            logicCanvas.lineWidth = lineWidth
            let contentWidth = tableView.frame.width - 10
            let rect = CGRect(x:0, y:0, width:contentWidth, height:cellPreviewHeight)
            logicCanvas.viewSize = rect.size
            let slice = logicCanvas.slice(rect:rect)
//            let p3d = logicCanvas.createPlane3d()
            cell.slice = slice
            // debug info
            if let slice = slice {
                cell.titleLabel?.text = "\(slice.pathModels.count)"
            } else {
                cell.titleLabel?.text = "?"
            }
        }
    }
}
