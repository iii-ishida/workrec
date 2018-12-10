import Foundation
import RxSwift
import RxCocoa

public struct WorkList {
  public let works: [WorkListItem]
  public let nextPageToken: String

  init(works: [WorkListItem], nextPageToken: String) {
    self.works = works
    self.nextPageToken = nextPageToken
  }

  init(pb: WorkListPb) {
    self.init(works: pb.works.map { WorkListItem(pb: $0) }, nextPageToken: pb.nextPageToken)
  }
}

public struct WorkListItem {
  public let id: String
  public let title: String

  init(id: String, title: String) {
    self.id = id
    self.title = title
  }

  init(pb: WorkListItemPb) {
    self.init(id: pb.id, title: pb.title)
  }
}

public struct API {
    public static func getWorkList() -> Observable<WorkList> {
      let url = URL(string: "\(Env.apiOrigin)/v1/works")!
      return URLSession.shared.rx.data(request: URLRequest(url: url)).map {
        print("DATA: \($0)")
        let list = try WorkListPb(serializedData: $0)
        return WorkList(pb: list)
      }
    }

    public static func addWork(title: String) -> Observable<Data> {
      let url = URL(string: "\(Env.apiOrigin)/v1/works")!
      var req = URLRequest(url: url)
      req.httpMethod = "POST"
      req.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
      req.httpBody = try! CreateWorkRequestPb.with {
        $0.title = title
      }.serializedData()

      return URLSession.shared.rx.response(request: req).map { 
        print("DATA: \($1), RET: \($0)"  )
        return $1
      }
    }

    public static func deleteWork(workId: String) -> Observable<Data> {
      let url = URL(string: "\(Env.apiOrigin)/v1/works/\(workId)")!
      var req = URLRequest(url: url)
      req.httpMethod = "DELETE"

      return URLSession.shared.rx.response(request: req).map { 
        print("DATA: \($1), RET: \($0)"  )
        return $1
      }
    }
}
