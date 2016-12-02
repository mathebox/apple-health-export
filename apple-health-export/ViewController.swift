//
//  ViewController.swift
//  apple-health-export
//
//  Created by Max Bothe on 02/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let shareTypes = Set<HKSampleType>()
            var readTypes = Set<HKObjectType>()
            readTypes.insert(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)

            healthStore.requestAuthorization(toShare: shareTypes, read: readTypes, completion: { (success, error) -> Void in
                if success {
                    print("success")

                    let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
                    let past = NSDate.distantPast
                    let now = NSDate()
                    print("steps from \(past) unitl \(now)")
                    let predicate = HKQuery.predicateForSamples(withStart: past, end:now as Date, options: [])
                    let interval: NSDateComponents = NSDateComponents()
                    interval.minute = 10
                    let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: past as Date, intervalComponents: interval as DateComponents)
                    query.initialResultsHandler = { query, results, error in

                        if error != nil {
                            print("error: query")
                            return
                        }

                        if let myResults = results {
                            let statistics = myResults.statistics()
                            print("\(statistics.count)")
                            for statistic in statistics {
                                if let quantity = statistic.sumQuantity() {
                                    let steps = quantity.doubleValue(for: HKUnit.count())
                                    print("Start = \(statistic.startDate) | End = \(statistic.endDate) | Steps = \(steps)")
                                }
                            }
                        }
                    }
                    
                    HKHealthStore().execute(query)

                } else {
                    print("failure")
                    if let error = error {
                        print(error)
                    }
                }
            })
        }
    }

}

