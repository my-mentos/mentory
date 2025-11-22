//
//  MentorySwiftDataFlow.swift
//  Mentory
//
//  Created by 김민우 on 11/21/25.
//
import MentoryDB


// MARK: Domain
nonisolated struct MentorySwiftDataFlow: MentoryDBFlowInterface {
    @concurrent
    func updateName(_ newName: String) async throws {
        let api = MentoryDBAPI()
        
        try await api.updateName(newName)
    }
    
    @concurrent
    func getName() async throws -> String? {
        let api = MentoryDBAPI()
        
        let name = try await api.getName()
        
        return name
    }
}
