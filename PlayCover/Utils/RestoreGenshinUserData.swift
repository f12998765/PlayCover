//
//  RestoreGenshinUserData.swift
//  PlayCover
//
//  Created by José Elias Moreno villegas on 20/07/22.
//

import Foundation

func restoreUserData( folderName:String ){
    let MIHOYO_ACCOUNT_INFO_PLIST_2_Encryption = "MIHOYO_ACCOUNT_INFO_PLIST_2_Encryption"
    let MIHOYO_KIBANA_REPORT_ARRAY_KEY_Encryption = "MIHOYO_KIBANA_REPORT_ARRAY_KEY_Encryption"
    let MIHOYO_LAST_ACCOUNT_MODEL_Encryption = "MIHOYO_LAST_ACCOUNT_MODEL_Encryption"
    
    let GameDataPath = NSHomeDirectory() + "/Library/Containers/com.miHoYo.GenshinImpact/Data/Documents/"
    let StorePath = NSHomeDirectory() + "/Library/Containers/io.playcover.PlayCover/storage/" + folderName + "/"
    
    let MIHOYO_ACCOUNT_INFO_PLIST_2_Encryption_URL = URL(fileURLWithPath: GameDataPath + MIHOYO_ACCOUNT_INFO_PLIST_2_Encryption)
    let MIHOYO_KIBANA_REPORT_ARRAY_KEY_Encryption_URL = URL(fileURLWithPath: GameDataPath + MIHOYO_KIBANA_REPORT_ARRAY_KEY_Encryption)
    let MIHOYO_LAST_ACCOUNT_MODEL_Encryption_URL = URL(fileURLWithPath: GameDataPath + MIHOYO_LAST_ACCOUNT_MODEL_Encryption)
    
    let fileManager = FileManager.default
    
    //remove existent user data from genshin impact
    do{
        try fileManager.removeItem(at: MIHOYO_ACCOUNT_INFO_PLIST_2_Encryption_URL )
        try fileManager.removeItem(at: MIHOYO_KIBANA_REPORT_ARRAY_KEY_Encryption_URL)
        try fileManager.removeItem(at: MIHOYO_LAST_ACCOUNT_MODEL_Encryption_URL)
    }
    catch{
        print("Error removing file: \(error)")
    }
    
    // move data from StorePath to  GameDataPath
    do {
        try fileManager.copyItem(at: URL(fileURLWithPath: StorePath + MIHOYO_ACCOUNT_INFO_PLIST_2_Encryption),
                                 to: MIHOYO_ACCOUNT_INFO_PLIST_2_Encryption_URL)
        
        try fileManager.copyItem(at: URL(fileURLWithPath: StorePath + MIHOYO_KIBANA_REPORT_ARRAY_KEY_Encryption),
                                 to: MIHOYO_KIBANA_REPORT_ARRAY_KEY_Encryption_URL)
        
        try fileManager.copyItem(at: URL(fileURLWithPath: StorePath + MIHOYO_LAST_ACCOUNT_MODEL_Encryption),
                                 to: MIHOYO_LAST_ACCOUNT_MODEL_Encryption_URL)
        let region = try String(contentsOf: URL(fileURLWithPath: StorePath + "region.txt"), encoding: .utf8)
        modifyPlist(region: region)
    } catch {
        print("Error moving file: \(error)")
    }
}

func modifyPlist (region:String){
    do{
        // path of plist file
        //let url = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Containers/com.miHoYo.GenshinImpact/Data/Library/MihoyoDownload/Persistent/com.miHoYo.GenshinImpact.plist")
        let url = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Containers/com.miHoYo.GenshinImpact/Data/Library/Preferences/com.miHoYo.GenshinImpact.plist")
        
        // read plist file
        let data = try Data(contentsOf: url)
        var plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]

        let GENERAL_DATA = plist["GENERAL_DATA"] as! String
        var modifiedValue: String
        // modified GENERAL_DATA
        if region == "os_usa"{
            if GENERAL_DATA.contains("os_usa"){
                modifiedValue = GENERAL_DATA.replacingOccurrences(of: "os_usa", with: "\(region)", options: .literal, range: nil)
            } else{
                modifiedValue = GENERAL_DATA.replacingOccurrences(of: "os_euro", with: "\(region)", options: .literal, range: nil)
            }
        } else{ // euro
            if GENERAL_DATA.contains("os_euro"){
                modifiedValue = GENERAL_DATA.replacingOccurrences(of: "os_euro", with: "\(region)", options: .literal, range: nil)
            } else{
                modifiedValue = GENERAL_DATA.replacingOccurrences(of: "os_usa", with: "\(region)", options: .literal, range: nil)
            }
        }
        
        // write modified value to GENERAL_DATA key of plist
        plist["GENERAL_DATA"] = modifiedValue

        // write plist to file
        let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try plistData.write(to: url, options: .atomic)
    } catch{
        print("Error editing plist file: \(error)")
    }
}


func getAccountList () -> Array<String>{
    let StorePath = NSHomeDirectory() + "/Library/Containers/io.playcover.PlayCover/storage/"
    var accountStored:Array<String>
    do{
        accountStored = try FileManager.default.contentsOfDirectory(atPath: StorePath)
        
    } catch{
        accountStored = []
    }
    return accountStored
}
