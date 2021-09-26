//
//  FilterViewModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

/// Used to handle filtering logic
open class FilterViewModel {
    /// Initializes with the currently selected filter condition.
    ///
    /// - Parameter model: currently selected filter condition.
    public init(selectedFilter model: FilterModel) {
        self.selectedFilter = model
    }
    
    /// currently selected filter condition.
    private var selectedFilter: FilterModel
}
