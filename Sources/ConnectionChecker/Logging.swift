/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

func dPrint(_ message: String, place: String = "") {
    #if DEBUG
    print("\(place.isEmpty ? "" : place + ": " )\(message)")
    #endif
}
