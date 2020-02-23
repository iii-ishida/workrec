//
//  Network.swift
//  WorkrecSDK
//
//  Created by ishida on 2020/02/19.
//

import Apollo
import Foundation

class Network {
  static let shared = Network()
  private(set) lazy var apollo = ApolloClient(url: URL(string: "http://localhost:4000/graph")!)
}
