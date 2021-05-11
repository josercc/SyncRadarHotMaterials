//
//  main.swift
//  
//
//  Created by joser on 2021/5/10.
//

import Foundation
import ArgumentParser
import Logging
import Alamofire

let logging = Logging.Logger(label: "[同步香港雷达热门物料]")


/// 用来同步香港雷达的热门物料
struct SyncRadarHotMaterials: ParsableCommand {
    
    @Option(help: "设置配置环境默认为debug")
    var configuration:String?
    
    var envPreix:String {configuration ?? "debug"}
    
    func run() throws {
        guard let pwd = ProcessInfo.processInfo.environment["PWD"] else {
            logging.error("当前运行目录不存在")
            SyncRadarHotMaterials.exit()
        }
        logging.info("当前运行目录\(pwd)")
        let configationFile = "\(pwd)/\("\(envPreix).SyncRadarHotMaterials")"
        logging.info("正在读取配置文件\(configationFile)")
        let url = URL(fileURLWithPath: configationFile)
        guard let content = try? String(contentsOf: url), let configation = try? SyncRadarHotMaterialsConfigation(content: content) else {
            logging.error("\(configationFile)不存在或者内容为空")
            SyncRadarHotMaterials.exit()
        }
        let group = DispatchGroup()
        group.enter()
        let requestUrl = configation.get(key: "url")
        AF.request(requestUrl).responseJSON { response in
            defer {
                group.leave()
            }
            guard let headers = response.response?.headers, let eTag = headers[configation.get(key: "response_etag")] else {
                logging.error("请求返回头没有Etag字段")
                SyncRadarHotMaterials.exit()
            }
            guard let data = response.value else {
                logging.error("\(requestUrl)没有数据返回")
                SyncRadarHotMaterials.exit()
            }
            let jsonMap:[String:Any] = [
                "eTag":eTag,
                "data":data
            ]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonMap, options: .fragmentsAllowed),
                  let jsonText = String(data: jsonData, encoding: .utf8) else {
                logging.error("序列化数据失败")
                SyncRadarHotMaterials.exit()
            }
            do {
                try jsonText.write(toFile: "\(configation.get(key: "local_path"))/\(envPreix)_SyncRadarHotMaterials.json", atomically: true, encoding: .utf8)
            } catch(let e) {
                logging.error("\(e.localizedDescription)")
            }
            logging.info("同步数据完成")
            SyncRadarHotMaterials.exit()
        }
        dispatchMain()
    }
    
}

SyncRadarHotMaterials.main()

struct SyncRadarHotMaterialsConfigation {
    let env:[String:Any]
    init(content:String) throws {
        let lineContents = content.components(separatedBy: "\n")
        var env:[String:Any] = [:]
        lineContents.forEach { element in
            let list = element.components(separatedBy: "=")
            guard list.count == 2 else {
                return
            }
            env[list[0]] = list[1]
        }
        self.env = env
    }
    
    func get(key:String) -> String {
        guard let value = env[key] as? String else {
            logging.error("\(key)没有设置")
            SyncRadarHotMaterials.exit()
        }
        return value
    }
}
