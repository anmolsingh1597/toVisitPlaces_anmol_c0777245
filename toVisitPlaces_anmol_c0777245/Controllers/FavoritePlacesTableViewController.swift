//
//  FavoritePlacesTableViewController.swift
//  toVisitPlaces_anmol_c0777245
//
//  Created by Anmol singh on 2020-06-14.
//  Copyright © 2020 Swift Project. All rights reserved.
//

import UIKit

class FavoritePlacesTableViewController: UITableViewController {
        var favoritePlaces: [FavoritePlace]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

    }

    override func viewWillAppear(_ animated: Bool) {
        loadData()
        self.tableView.reloadData()
        
    }
    
    func deleteData(_ newArray: [FavoritePlace]){
        
        let filePath = getDataFilePath()
                   
                   var saveString = ""
                   
                   for favoritePlace in newArray {
                       saveString = "\(saveString)\(favoritePlace.lat),\(favoritePlace.long),\(favoritePlace.speed),\(favoritePlace.course),\(favoritePlace.altitude),\(favoritePlace.address)\n"
                   }
                   
                   do{
                       try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
                   } catch {
                       print(error)
                   }
                   
    }
    
    func getDataFilePath() -> String {
         let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
         
         let filePath = documentPath.appending("/Favorite-Place-Data.txt")
         return filePath
     }
    
    func loadData(){
          favoritePlaces = [FavoritePlace]()
          
          let filePath = getDataFilePath()
          if FileManager.default.fileExists(atPath: filePath) {
              
              do{
                  //creating string of file path
                  let fileContent = try String(contentsOfFile: filePath)
                  // seperating books from each other
                  let contentArray = fileContent.components(separatedBy: "\n")
                  for content in contentArray {
                      //seperating each book's content
                      let favoritePlaceContent = content.components(separatedBy: ",")
                      if favoritePlaceContent.count == 6 {
                          let favoritePlace = FavoritePlace(lat: Double(favoritePlaceContent[0])!, long: Double(favoritePlaceContent[1])!, speed: Double(favoritePlaceContent[2])!, course: Double(favoritePlaceContent[3])!, altitude: Double(favoritePlaceContent[4])!, address: favoritePlaceContent[5])
                          favoritePlaces?.append(favoritePlace)
                      }
                  }
                  
              }catch {
                  print(error)
              }
          }
      }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favoritePlaces?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
                let favoritePlace = self.favoritePlaces![indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "favoritePlaceCell")
               
               cell?.textLabel?.text =  favoritePlace.address
        cell?.detailTextLabel?.text = "Lat: " + String(favoritePlace.lat) + " Long: " + String(favoritePlace.long)
               

               return cell!
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var newArray = self.favoritePlaces!
        
        newArray.remove(at: indexPath.row)
        
        if editingStyle == .delete {
            // Delete the row from the data source
            self.favoritePlaces?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.deleteData(newArray)
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
