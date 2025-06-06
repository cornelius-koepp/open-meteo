import Foundation

/// Represent a variable combined with a pressure level and helps decoding it
protocol PressureVariableRespresentable: RawRepresentable where RawValue == String, Variable.RawValue == String {
    associatedtype Variable: RawRepresentable

    var variable: Variable { get }
    var level: Int { get }

    init(variable: Variable, level: Int)
}

extension PressureVariableRespresentable {
    init?(rawValue: String) {
        guard let pos = rawValue.lastIndex(of: "_"), let posEnd = rawValue[pos..<rawValue.endIndex].range(of: "hPa") else {
            return nil
        }
        let variableString = rawValue[rawValue.startIndex ..< pos]
        guard let variable = Variable(rawValue: String(variableString)) else {
            return nil
        }

        let start = rawValue.index(after: pos)
        let levelString = rawValue[start..<posEnd.lowerBound]
        guard let level = Int(levelString) else {
            return nil
        }
        self.init(variable: variable, level: level)
    }

    var rawValue: String {
        return "\(variable.rawValue)_\(level)hPa"
    }

    init(from decoder: Decoder) throws {
        let s = try decoder.singleValueContainer().decode(String.self)
        guard let initialised = Self(rawValue: s) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot initialize \(Self.self) from invalid String value \(s)", underlyingError: nil))
        }
        self = initialised
    }

    func encode(to encoder: Encoder) throws {
        var e = encoder.singleValueContainer()
        try e.encode(rawValue)
    }
}

/// Represent a variable combined with a pressure level and helps decoding it
protocol HeightVariableRespresentable: RawRepresentable where RawValue == String, Variable.RawValue == String {
    associatedtype Variable: RawRepresentable

    var variable: Variable { get }
    var level: Int { get }

    init(variable: Variable, level: Int)
}

extension HeightVariableRespresentable {
    init?(rawValue: String) {
        guard let pos = rawValue.lastIndex(of: "_"), let posEnd = rawValue[pos..<rawValue.endIndex].range(of: "m") else {
            return nil
        }
        let variableString = rawValue[rawValue.startIndex ..< pos]
        guard let variable = Variable(rawValue: String(variableString)) else {
            return nil
        }

        let start = rawValue.index(after: pos)
        let levelString = rawValue[start..<posEnd.lowerBound]
        guard let level = Int(levelString) else {
            return nil
        }
        self.init(variable: variable, level: level)
    }

    var rawValue: String {
        return "\(variable.rawValue)_\(level)m"
    }

    init(from decoder: Decoder) throws {
        let s = try decoder.singleValueContainer().decode(String.self)
        guard let initialised = Self(rawValue: s) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot initialize \(Self.self) from invalid String value \(s)", underlyingError: nil))
        }
        self = initialised
    }

    func encode(to encoder: Encoder) throws {
        var e = encoder.singleValueContainer()
        try e.encode(rawValue)
    }
}

protocol RawRepresentableString {
    init?(rawValue: String)
    var rawValue: String { get }
}

/// Enum with surface and pressure variable
enum SurfaceAndPressureVariable<Surface: Sendable, Pressure: Sendable>: Sendable {
    case surface(Surface)
    case pressure(Pressure)
}

extension SurfaceAndPressureVariable: RawRepresentableString where Pressure: RawRepresentableString, Surface: RawRepresentableString {
    init?(rawValue: String) {
        if let variable = Pressure(rawValue: rawValue) {
            self = .pressure(variable)
            return
        }
        if let variable = Surface(rawValue: rawValue) {
            self = .surface(variable)
            return
        }
        return nil
    }

    var rawValue: String {
        switch self {
        case .surface(let variable): return variable.rawValue
        case .pressure(let variable): return variable.rawValue
        }
    }
}

extension SurfaceAndPressureVariable: Hashable, Equatable where Pressure: Hashable, Surface: Hashable {
}

extension SurfaceAndPressureVariable: GenericVariable where Surface: GenericVariable, Pressure: GenericVariable {
    var asGenericVariable: GenericVariable {
        switch self {
        case .surface(let surface):
            return surface
        case .pressure(let pressure):
            return pressure
        }
    }

    var storePreviousForecast: Bool {
        asGenericVariable.storePreviousForecast
    }

    var omFileName: (file: String, level: Int) {
        asGenericVariable.omFileName
    }

    var scalefactor: Float {
        asGenericVariable.scalefactor
    }

    var interpolation: ReaderInterpolation {
        asGenericVariable.interpolation
    }

    var unit: SiUnit {
        asGenericVariable.unit
    }

    var isElevationCorrectable: Bool {
        asGenericVariable.isElevationCorrectable
    }
}

extension SurfaceAndPressureVariable: GenericVariableMixable where Surface: GenericVariableMixable, Pressure: GenericVariableMixable {
    var requiresOffsetCorrectionForMixing: Bool {
        switch self {
        case .surface(let surface):
            return surface.requiresOffsetCorrectionForMixing
        case .pressure(let pressure):
            return pressure.requiresOffsetCorrectionForMixing
        }
    }
}

/// Enum with surface and pressure variable
enum SurfacePressureAndHeightVariable<Surface: Sendable, Pressure: Sendable, Height: Sendable>: Sendable {
    case surface(Surface)
    case pressure(Pressure)
    case height(Height)
}

extension SurfacePressureAndHeightVariable: RawRepresentableString where Pressure: RawRepresentableString, Surface: RawRepresentableString, Height: RawRepresentableString {
    init?(rawValue: String) {
        if let variable = Pressure(rawValue: rawValue) {
            self = .pressure(variable)
            return
        }
        if let variable = Surface(rawValue: rawValue) {
            self = .surface(variable)
            return
        }
        if let variable = Height(rawValue: rawValue) {
            self = .height(variable)
            return
        }
        return nil
    }

    var rawValue: String {
        switch self {
        case .surface(let variable): return variable.rawValue
        case .pressure(let variable): return variable.rawValue
        case .height(let variable): return variable.rawValue
        }
    }
}

extension SurfacePressureAndHeightVariable: Hashable, Equatable where Pressure: Hashable, Surface: Hashable, Height: Hashable {
}

extension SurfacePressureAndHeightVariable: GenericVariable where Surface: GenericVariable, Pressure: GenericVariable, Height: GenericVariable {
    var asGenericVariable: GenericVariable {
        switch self {
        case .surface(let surface):
            return surface
        case .pressure(let pressure):
            return pressure
        case .height(let height):
            return height
        }
    }

    var storePreviousForecast: Bool {
        asGenericVariable.storePreviousForecast
    }

    var omFileName: (file: String, level: Int) {
        asGenericVariable.omFileName
    }

    var scalefactor: Float {
        asGenericVariable.scalefactor
    }

    var interpolation: ReaderInterpolation {
        asGenericVariable.interpolation
    }

    var unit: SiUnit {
        asGenericVariable.unit
    }

    var isElevationCorrectable: Bool {
        asGenericVariable.isElevationCorrectable
    }
}

extension SurfacePressureAndHeightVariable: GenericVariableMixable where Surface: GenericVariableMixable, Pressure: GenericVariableMixable, Height: GenericVariableMixable {
    var requiresOffsetCorrectionForMixing: Bool {
        switch self {
        case .surface(let surface):
            return surface.requiresOffsetCorrectionForMixing
        case .pressure(let pressure):
            return pressure.requiresOffsetCorrectionForMixing
        case .height(let height):
            return height.requiresOffsetCorrectionForMixing
        }
    }
}

enum VariableOrDerived<Raw: RawRepresentableString & Sendable, Derived: RawRepresentableString & Sendable>: RawRepresentableString, Sendable {
    case raw(Raw)
    case derived(Derived)

    init?(rawValue: String) {
        if let val = Derived(rawValue: rawValue) {
            self = .derived(val)
            return
        }
        if let val = Raw(rawValue: rawValue) {
            self = .raw(val)
            return
        }
        return nil
    }

    var rawValue: String {
        switch self {
        case .raw(let raw):
            return raw.rawValue
        case .derived(let derived):
            return derived.rawValue
        }
    }

    var name: String {
        switch self {
        case .raw(let variable): return variable.rawValue
        case .derived(let variable): return variable.rawValue
        }
    }
}
