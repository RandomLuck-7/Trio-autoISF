import SwiftUI
import Swinject

extension AIMIB30Conf {
    struct RootView: BaseView {
        let resolver: Resolver
        @StateObject var state = StateModel()

        private var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }

        @State private var infoButtonPressed: InfoText?

        var body: some View {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Toggle("Activate AIMI B30", isOn: $state.enableB30)
                        }
                        .padding(.bottom, 2)
                        if !state.enableB30 {
                            VStack(alignment: .leading) {
                                Text(
                                    "Enables an increased basal rate after an EatingSoon TT and a manual bolus to saturate the infusion site with insulin to increase insulin absorption for SMB's following a meal with no carb counting."
                                )
                                BulletList(
                                    listItems: [
                                        "needs an EatingSoon TT with a specific GlucoseTarget",
                                        "once this TT is cancelled, B30 high TBR will be cancelled",
                                        "in order to activate B30 a minimum manual Bolus needs to be given",
                                        "you can specify how long B30 run and how high it is"
                                    ],
                                    listItemSpacing: 10
                                )
                                Text("Initiating B30 can be done by Apple Shortcuts")
                                BulletList(
                                    listItems: [
                                        "https://tinyurl.com/B30shortcut"
                                    ],
                                    listItemSpacing: 10
                                )
                            }
                        }
                    }
                } header: { Text("Enable") }
                if state.enableB30 {
                    ForEach(state.sections.indexed(), id: \.1.id) { sectionIndex, section in
                        Section(header: Text(section.displayName)) {
                            ForEach(section.fields.indexed(), id: \.1.id) { fieldIndex, field in
                                HStack {
                                    switch field.type {
                                    case .boolean:
                                        ZStack {
                                            Button("", action: {
                                                infoButtonPressed = InfoText(
                                                    description: field.infoText,
                                                    oref0Variable: field.displayName
                                                )
                                            })
                                            Toggle(isOn: self.$state.sections[sectionIndex].fields[fieldIndex].boolValue) {
                                                Text(field.displayName)
                                            }
                                        }
                                    case .decimal:
                                        ZStack {
                                            Button("", action: {
                                                infoButtonPressed = InfoText(
                                                    description: field.infoText,
                                                    oref0Variable: field.displayName
                                                )
                                            })
                                            Text(field.displayName)
                                        }
                                        TextFieldWithToolBar(
                                            text: self.$state.sections[sectionIndex].fields[fieldIndex].decimalValue,
                                            placeholder: "0",
                                            numberFormatter: formatter
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear(perform: configureView)
            .navigationTitle("AIMI B30 Configuration")
            .navigationBarTitleDisplayMode(.automatic)
            .onDisappear {
                state.saveIfChanged()
            }
        }

        func createParagraphAttribute(
            tabStopLocation: CGFloat,
            defaultTabInterval: CGFloat,
            firstLineHeadIndent: CGFloat,
            headIndent: CGFloat
        ) -> NSParagraphStyle {
            let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            let options: [NSTextTab.OptionKey: Any] = [:]
            paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: tabStopLocation, options: options)]
            paragraphStyle.defaultTabInterval = defaultTabInterval
            paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
            paragraphStyle.headIndent = headIndent
            return paragraphStyle
        }
    }
}
