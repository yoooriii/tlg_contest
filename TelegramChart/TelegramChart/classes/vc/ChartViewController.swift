//
//  ViewController.swift
//  TelegramChart
//
//  Created by Yu Lo on 3/12/19.
//  Copyright © 2019 Horns & Hoovs. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
    @IBOutlet var sliderView: ScaleSliderView!
    var nextIndex = -1
    var graphicsContainer:GraphicsContainer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func loadData(_ sender: AnyObject) {
        print("load")
        let url = Bundle.main.url(forResource: "chart_data", withExtension: "json")
        if let url = url { do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            do {
                graphicsContainer = try decoder.decode(GraphicsContainer.self, from: jsonData)
                print("graphicsContainer: \(graphicsContainer)")
                nextIndex = 0
                showPlane(index: 0)
            } catch {
                print("cannot decode json")
            }
        } catch {
            print("cannot read file at \(url)")
            } } else {
            print("no json")
        }

    }

    @IBAction func showNextPlane(_ sender: AnyObject) {
        self.showPlane(index: nextIndex)
        nextIndex += 1
        if let container = graphicsContainer {
            let plCount = container.planes.count
            if nextIndex >= plCount {
                nextIndex = 0
            }
        } else {
            nextIndex = -1
        }
    }

    func showPlane(index:Int) {
        if let container = graphicsContainer {
            let plCount = container.planes.count
            if index < 0 || index >= plCount {
                print("wrong index \(index)")
            }

            let plane = container.planes[index]
            sliderView.setPlane(plane)

        } else {
            print("no graphicsContainer")
        }


    }

}

