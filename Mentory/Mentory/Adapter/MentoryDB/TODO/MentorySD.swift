//
//  MentorySD.swift
//  Mentory
//
//  Created by 김민우 on 11/21/25.
//
import Foundation
import OSLog
import SwiftData


// MARK: Domain
//nonisolated actor MentorySD: MentoryDBInterface {
//    // MARK: core
//    private let context: ModelContext
//    private let logger = Logger(subsystem: "MentoryiOS.MentorySD",
//                          category: "Domain")
//
//    private let nameRecordKey = "MentoryDB.UniqueKey.v1"
//    private let container: ModelContainer
//    
//    init() {
//        self.container = try! ModelContainer(for: MentoryDBModel.self)
//        self.context = ModelContext(container)
//        self.context.autosaveEnabled = true
//        logger.debug("MentoryDBStore 초기화 완료")
//    }
//    
//    
//    // MARK: flow
//    func updateName(_ newName: String) throws {
//        logger.debug("updateName() 호출 — 새로운 이름: \(newName, privacy: .public)")
//
//        // id == nameRecordKey 인 레코드 조회
//        let descriptor = FetchDescriptor<MentoryDBModel>(
//            predicate: #Predicate { $0.id == nameRecordKey }
//        )
//
//        let results = try context.fetch(descriptor)
//
//        let model: MentoryDBModel
//        if let existing = results.first {
//            logger.debug("기존 이름 레코드 발견 — 업데이트 진행")
//            model = existing
//        } else {
//            logger.debug("기존 이름 레코드 없음 — 새 레코드 생성")
//            model = MentoryDBModel(id: nameRecordKey, userName: nil)
//            context.insert(model)
//        }
//
//        model.userName = newName
//
//        do {
//            try context.save()
//            logger.debug("updateName() 완료 — SwiftData에 저장됨")
//        } catch {
//            logger.error("updateName() 저장 실패: \(error.localizedDescription, privacy: .public)")
//            throw error
//        }
//    }
//    
//    func getName() throws -> String? {
//        logger.debug("getName() 호출")
//
//        let descriptor = FetchDescriptor<MentoryDBModel>(
//            predicate: #Predicate { $0.id == nameRecordKey }
//        )
//
//        let results = try context.fetch(descriptor)
//
//        guard let model = results.first else {
//            logger.debug("getName() — 레코드 없음, nil 반환")
//            return nil
//        }
//
//        let name = model.userName
//        logger.debug("getName() — 저장된 이름: \(name ?? "nil", privacy: .public)")
//        return name
//    }
//    
//    
//    // MARK: core
//    @Model
//    final class MentoryDBModel {
//        /// 항상 같은 레코드를 찾기 위한 고정 문자열 ID
//        @Attribute(.unique)
//        var id: String
//
//        /// 사용자 이름
//        var userName: String?
//
//        init(id: String, userName: String? = nil) {
//            self.id = id
//            self.userName = userName
//        }
//    }
//}
