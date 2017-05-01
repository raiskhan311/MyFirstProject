//
//  DatabaseErrorEnum.swift
//  Airstrike
//
//  Created by Bret Smith on 12/16/16.
//  Copyright © 2016 Airstrike. All rights reserved.
//

import Foundation

enum DatabaseError: Error {
    case failureToCreateTable
    case failureToInsertIntoTable
    case failureToUpdateInTable
    case failureToGetFromTable
    case failureToDeleteFromTable
    case failureToDropTable
}

