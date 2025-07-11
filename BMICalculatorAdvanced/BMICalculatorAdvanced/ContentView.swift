
//  ContentView.swift
//  BMICalculatorAdvancedApp
//
//  Created by Mohammad Moussa on July 11, 2025.
//  All rights reserved.
//
//  Description:
//  Feature-rich BMI Calculator app including animated results,
//  unit toggles, gauge visualization, haptic feedback, and export options.
//  Built using SwiftUI.
//
//  Author: Mohammad Moussa
//
import SwiftUI
import UIKit

struct ContentView: View {
    // Define available units for weight and height
    enum WeightUnit: String, CaseIterable {
        case kg = "kg"
        case lbs = "lbs"
    }

    enum HeightUnit: String, CaseIterable {
        case meters = "m"
        case centimeters = "cm"
        case inches = "in"
    }

    // User inputs and app state
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var bmiResult: Double = 0.0
    @State private var bmiCategory: String = ""
    @State private var showResult: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var exportText: String = ""
    @State private var weightUnit: WeightUnit = .kg
    @State private var heightUnit: HeightUnit = .meters

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Header
                Text("BMI Calculator")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.accentColor)
                    .padding(.top)

                // Input Section
                GroupBox(label: Label("Enter your details", systemImage: "person.crop.circle")) {
                    VStack(spacing: 15) {
                        // Weight input with unit picker
                        HStack {
                            TextField("Weight", text: $weight)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Picker("", selection: $weightUnit) {
                                ForEach(WeightUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 100)
                        }

                        // Height input with unit picker (now includes cm)
                        HStack {
                            TextField("Height", text: $height)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Picker("", selection: $heightUnit) {
                                ForEach(HeightUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 160)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .padding()

                // Calculate Button
                Button(action: {
                    calculateBMI()
                    withAnimation(.easeIn(duration: 0.5)) {
                        showResult = true
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Text("Calculate BMI")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // Result Section with gauge and export option
                if showResult {
                    VStack(spacing: 20) {
                        Text("Your BMI is")
                            .font(.headline)

                        Gauge(value: bmiResult, in: 10...40) {
                            Text("BMI")
                        } currentValueLabel: {
                            Text(String(format: "%.1f", bmiResult))
                                .font(.system(size: 32, weight: .bold))
                        }
                        .gaugeStyle(.accessoryCircular)
                        .tint(categoryColor())
                        .frame(width: 150, height: 150)

                        Text(bmiCategory)
                            .font(.title2)
                            .foregroundColor(categoryColor())
                            .bold()

                        // Export Button
                        Button("Export Result") {
                            exportText = """
                            BMI Report
                            Weight: \(weight) \(weightUnit.rawValue)
                            Height: \(height) \(heightUnit.rawValue)
                            BMI: \(String(format: "%.2f", bmiResult))
                            Category: \(bmiCategory)
                            """
                            showShareSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .sheet(isPresented: $showShareSheet) {
                            ActivityView(activityItems: [exportText])
                        }
                    }
                    .transition(.opacity.combined(with: .slide))
                    .padding()
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Main logic to calculate BMI, including unit conversions
    func calculateBMI() {
        guard let w = Double(weight), let h = Double(height), h > 0 else {
            bmiResult = 0.0
            bmiCategory = "Invalid"
            return
        }

        var weightInKg = w
        var heightInMeters = h

        // Convert weight to kg if necessary
        if weightUnit == .lbs {
            weightInKg = w * 0.453592
        }

        // Convert height to meters if necessary
        switch heightUnit {
        case .inches:
            heightInMeters = h * 0.0254
        case .centimeters:
            heightInMeters = h / 100
        case .meters:
            break
        }

        let bmi = weightInKg / (heightInMeters * heightInMeters)
        bmiResult = bmi

        // Classify BMI
        switch bmi {
        case ..<18.5:
            bmiCategory = "Underweight"
        case 18.5..<25:
            bmiCategory = "Normal weight"
        case 25..<30:
            bmiCategory = "Overweight"
        default:
            bmiCategory = "Obese"
        }
    }

    // Define color for BMI category
    func categoryColor() -> Color {
        switch bmiCategory {
        case "Underweight":
            return .blue
        case "Normal weight":
            return .green
        case "Overweight":
            return .orange
        case "Obese":
            return .red
        default:
            return .gray
        }
    }
}

// Share sheet wrapper for exporting BMI results
struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

