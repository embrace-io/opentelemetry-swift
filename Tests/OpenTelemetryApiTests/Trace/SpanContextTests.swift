/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import OpenTelemetryApi
import XCTest

final class SpanContextTests: XCTestCase {
  let firstTraceIdBytes: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, UInt8(ascii: "a")]
  let secondTraceIdBytes: [UInt8] = [0, 0, 0, 0, 0, 0, 0, UInt8(ascii: "0"), 0, 0, 0, 0, 0, 0, 0, 0]
  let firstSpanIdBytes: [UInt8] = [0, 0, 0, 0, 0, 0, 0, UInt8(ascii: "a")]
  let secondSpanIdBytes: [UInt8] = [UInt8(ascii: "0"), 0, 0, 0, 0, 0, 0, 0]

  var firstTraceState: TraceState!
  var secondTraceState: TraceState!
  var emptyTraceState: TraceState!

  var first: SpanContext!
  var second: SpanContext!
  var remote: SpanContext!

  override func setUp() {
    firstTraceState = TraceState().setting(key: "foo", value: "bar")
    secondTraceState = TraceState().setting(key: "foo", value: "baz")
    emptyTraceState = TraceState()

    first = SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags(), traceState: firstTraceState)
    second = SpanContext.create(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState)
    remote = SpanContext.createFromRemoteParent(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: emptyTraceState)
  }

  func testIsValid() {
    XCTAssertFalse(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId.invalid, traceFlags: TraceFlags(), traceState: emptyTraceState).isValid)
    XCTAssertFalse(SpanContext.create(traceId: TraceId.invalid, spanId: SpanId.invalid, traceFlags: TraceFlags(), traceState: emptyTraceState).isValid)
    XCTAssertFalse(SpanContext.create(traceId: TraceId.invalid, spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags(), traceState: emptyTraceState).isValid)
    XCTAssertTrue(first.isValid)
    XCTAssertTrue(second.isValid)
  }

  func testGetTraceId() {
    XCTAssertEqual(first.traceId, TraceId(fromBytes: firstTraceIdBytes))
    XCTAssertEqual(second.traceId, TraceId(fromBytes: secondTraceIdBytes))
  }

  func testGetSpanId() {
    XCTAssertEqual(first.spanId, SpanId(fromBytes: firstSpanIdBytes))
    XCTAssertEqual(second.spanId, SpanId(fromBytes: secondSpanIdBytes))
  }

  func testGetTraceFlags() {
    XCTAssertEqual(first.traceFlags, TraceFlags())
    XCTAssertEqual(second.traceFlags, TraceFlags().settingIsSampled(true))
  }

  func testGetTraceState() {
    XCTAssertEqual(first.traceState, firstTraceState)
    XCTAssertEqual(second.traceState, secondTraceState)
  }

  func testIsRemote() {
    XCTAssertFalse(first.isRemote)
    XCTAssertFalse(second.isRemote)
    XCTAssertTrue(remote.isRemote)
  }

  func testSpanContext_EqualsAndHashCode() {
    XCTAssertEqual(first, SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags(), traceState: emptyTraceState))
    XCTAssertEqual(first, SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(false), traceState: firstTraceState))
    XCTAssertEqual(second, SpanContext.create(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState))
    XCTAssertEqual(remote, SpanContext.createFromRemoteParent(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: emptyTraceState))
    XCTAssertNotEqual(first, second)
    XCTAssertNotEqual(first, SpanContext.create(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState))
    XCTAssertNotEqual(first, remote)
    XCTAssertNotEqual(first, SpanContext.createFromRemoteParent(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: emptyTraceState))
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags(), traceState: emptyTraceState), second)
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags(), traceState: emptyTraceState), SpanContext.create(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState))
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags(), traceState: emptyTraceState), remote)
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags(), traceState: emptyTraceState), SpanContext.createFromRemoteParent(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: emptyTraceState))
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(false), traceState: firstTraceState), second)
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(false), traceState: firstTraceState), SpanContext.create(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState))
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(false), traceState: firstTraceState), remote)
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: firstTraceIdBytes), spanId: SpanId(fromBytes: firstSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(false), traceState: firstTraceState), SpanContext.createFromRemoteParent(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: emptyTraceState))
    XCTAssertNotEqual(second, remote)
    XCTAssertNotEqual(second, SpanContext.createFromRemoteParent(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState))
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState), remote)
    XCTAssertNotEqual(SpanContext.create(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState), SpanContext.createFromRemoteParent(traceId: TraceId(fromBytes: secondTraceIdBytes), spanId: SpanId(fromBytes: secondSpanIdBytes), traceFlags: TraceFlags().settingIsSampled(true), traceState: secondTraceState))
  }

  func testSpanContext_ToString() {
    XCTAssert(first.description.contains(TraceId(fromBytes: firstTraceIdBytes).description))
    XCTAssert(first.description.contains(SpanId(fromBytes: firstSpanIdBytes).description))
    XCTAssert(first.description.contains(TraceFlags().description))
    XCTAssert(second.description.contains(TraceId(fromBytes: secondTraceIdBytes).description))
    XCTAssert(second.description.contains(SpanId(fromBytes: secondSpanIdBytes).description))
    XCTAssert(second.description.contains(TraceFlags().settingIsSampled(true).description))
  }

  func testSpanContext_Codable() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    XCTAssertEqual(first, try decoder.decode(SpanContext.self, from: encoder.encode(first)))
    XCTAssertEqual(second, try decoder.decode(SpanContext.self, from: encoder.encode(second)))
    XCTAssertEqual(remote, try decoder.decode(SpanContext.self, from: encoder.encode(remote)))
  }
}
