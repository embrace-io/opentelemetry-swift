/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

#if os(iOS)
import Foundation
import CoreTelephony

public protocol INetworkStatus {
    var networkMonitor : INetworkMonitor { get }
    func getStatus() -> (String, CTCarrier?)
}
#endif
