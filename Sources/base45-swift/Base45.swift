//
//  Base45-Swift
//
// Copyright 2021 Dirk-Willem van Gulik, Ministry of Public Health, the Netherlands.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

extension String {
    enum Base45Error: Error {
        case base64InvalidCharacter
        case base64InvalidLength
        case dataOverflow
    }
    
    public func fromBase45() throws -> Data {
        let charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"
        var data = Data()
        var output = Data()
        
        for character in self.uppercased() {
            if let at = charset.firstIndex(of: character) {
                let idx = charset.distance(from: charset.startIndex, to: at)
                data.append(UInt8(idx))
            } else {
                throw Base45Error.base64InvalidCharacter
            }
        }
        for i in stride(from: 0, to: data.count, by: 3) {
            if data.count - i < 2 {
                throw Base45Error.base64InvalidLength
            }
            var x: UInt32 = UInt32(data[i]) + UInt32(data[i + 1]) * 45
            if data.count - i >= 3 {
                x += 45 * 45 * UInt32(data[i + 2])
                
                guard x / 256 <= UInt8.max else {
                    throw Base45Error.dataOverflow
                }
                
                output.append(UInt8(x / 256))
            }
            output.append(UInt8(x % 256))
        }
        return output
    }
}

extension String {
    
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

extension Data {
    
    public func toBase45() -> String {
        
        let charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"
        var output = String()
        for i in stride(from: 0, to: self.count, by: 2) {
            if self.count - i > 1 {
                let x: Int = (Int(self[i]) << 8) + Int(self[i + 1])
                let e: Int = x / (45 * 45)
                let x2: Int = x % (45 * 45)
                let d: Int = x2 / 45
                let c: Int = x2 % 45
                output.append(charset[c])
                output.append(charset[d])
                output.append(charset[e])
            } else {
                let x2: Int = Int(self[i])
                let d: Int = x2 / 45
                let c: Int = x2 % 45
                output.append(charset[c])
                output.append(charset[d])
            }
        }
        return output
    }
}
