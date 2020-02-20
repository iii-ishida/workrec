//
//  Network.swift
//  WorkrecSDK
//
//  Created by ishida on 2020/02/19.
//

import Foundation
import Apollo

class Network {
  static let shared = Network()
  private(set) lazy var apollo = ApolloClient(url: URL(string: "http://localhost:4000/graph")!)
}
