import AppIntents

struct GetDeviceDetailsExtended: AppIntent {
	static let title: LocalizedStringResource = "Get Device Details (Extended)"

	static let description = IntentDescription(
		"""
		Get details about the device.

		This is an extension to the built-in “Get Device Details” action. Unlike the built-in action, this one returns all the values at once instead of making you pick a single value in the action.

		You can access the individual values. For example, with the built-in “Show Result” action.

		Possible values for thermal state: Nominal, Fair, Serious, Critical

		Tip: Use the “Format Duration” action to format the “Uptime” and “Duration since boot” values.
		""",
		categoryName: "Device",
		searchKeywords: [
			"system",
			"info",
			"information",
			"uptime",
			"boot",
			"processor",
			"cpu",
			"memory",
			"hostname",
			"thermal",
			"state",
			"temperature",
			"heat"
		],
		resultValueName: "Device Details"
	)

	@MainActor
	func perform() async throws -> some IntentResult & ReturnsValue<DeviceDetailsAppEntity> {
		.result(value: .init())
	}
}

struct DeviceDetailsAppEntity: TransientAppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Device Details"

	@Property(title: "Uptime (not including sleep)")
	var uptime: Measurement<UnitDuration>

	@Property(title: "Duration since boot")
	var durationSinceBoot: Measurement<UnitDuration>

	@Property(title: "Active processor count")
	var activeProcessorCount: Int

	@Property(title: "Physical memory (bytes)")
	var physicalMemory: Int

	@Property(title: "Hostname")
	var hostname: String

	@Property(title: "Thermal state")
	var thermalState: ThermalState_AppEnum

	var displayRepresentation: DisplayRepresentation {
		.init(
			title:
				"""
				PREVIEW

				Uptime: \(uptime.toDuration.formatted(.units(allowed: [.days, .hours, .minutes], width: .wide)))
				Duration since boot: \(durationSinceBoot.toDuration.formatted(.units(allowed: [.days, .hours, .minutes], width: .wide)))
				Active processor count: \(activeProcessorCount)
				Physical memory: \(physicalMemory.formatted(.byteCount(style: .memory)))
				Hostname: \(hostname)
				Thermal state: \(thermalState.localizedStringResource)
				"""
		)
	}

	init() {
		self.uptime = Device.uptime.toMeasurement
		self.durationSinceBoot = Device.uptimeIncludingSleep.toMeasurement
		self.activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
		self.physicalMemory = Int(ProcessInfo.processInfo.physicalMemory)
		self.hostname = ProcessInfo.processInfo.hostName
		self.thermalState = .init(ProcessInfo.processInfo.thermalState)
	}
}

enum ThermalState_AppEnum: String, AppEnum {
	case nominal
	case fair
	case serious
	case critical

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Thermal State"

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.nominal: "Nominal",
		.fair: "Fair",
		.serious: "Serious",
		.critical: "Critical"
	]

	init(_ thermalState: ProcessInfo.ThermalState) {
		switch thermalState {
		case .nominal:
			self = .nominal
		case .fair:
			self = .fair
		case .serious:
			self = .serious
		case .critical:
			self = .critical
		@unknown default:
			self = .nominal
		}
	}
}
