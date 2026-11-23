import SwiftUI

// MARK: - Bảng màu đồng bộ với ảnh nền Tokyo Drift (Car1)
extension Color {
    static let driftPurple = Color(red: 0.68, green: 0.35, blue: 0.98)
    static let driftPink = Color(red: 0.95, green: 0.25, blue: 0.55)
    static let driftCyan = Color(red: 0.22, green: 0.78, blue: 0.98)
    static let driftEmerald = Color(red: 0.20, green: 0.85, blue: 0.55)
    static let driftAmber = Color(red: 0.98, green: 0.65, blue: 0.20)
    static let cardDarkBg = Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.84)
}

// MARK: - Nền ảnh Car1 được làm dịu để nổi bật nội dung
struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            Image("Car1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Lớp phủ tối chuyển sắc giúp các dòng chữ trên nền tạp chí không gây rối mắt
            LinearGradient(
                colors: [
                    Color.black.opacity(0.75),
                    Color.black.opacity(0.62),
                    Color(red: 0.12, green: 0.04, blue: 0.18).opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Tiêu đề trang cố định, không bao giờ đè lên nội dung
struct ScreenHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subtitle.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundColor(.driftPink)

            Text(title)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

struct ContentView: View {
    @State private var system = RentalSystem()
    @State private var refreshID = UUID()

    // State đặt thuê xe
    @State private var selectedCustomerId = "C01"
    @State private var selectedVehicleId = "V01"
    @State private var rentalStartDate = Date()
    @State private var rentalDays = 3
    @State private var statusMessage = "Sẵn sàng xử lý giao dịch thuê & trả xe."
    @State private var isError = false

    // State thống kê
    @State private var filterDate = Date()
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        TabView {
            // MARK: - TAB 1: ĐỘI XE CHO THUÊ (FR1 & FR4)
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    ScreenHeaderView(title: "Đội Xe Cho Thuê", subtitle: "Fleet Management")

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            // Thanh tóm tắt nhanh đội xe
                            HStack(spacing: 10) {
                                SummaryBadge(
                                    title: "Tổng xe",
                                    value: "\(system.allVehicles.count)",
                                    color: .driftCyan
                                )
                                SummaryBadge(
                                    title: "Sẵn sàng",
                                    value: "\(system.allVehicles.filter { $0.isAvailable }.count)",
                                    color: .driftEmerald
                                )
                                SummaryBadge(
                                    title: "Đang thuê",
                                    value: "\(system.allVehicles.filter { !$0.isAvailable }.count)",
                                    color: .driftAmber
                                )
                            }
                            .padding(.horizontal, 16)

                            // Danh sách thẻ xe
                            ForEach(system.allVehicles, id: \.id) { vehicle in
                                VehicleCardView(vehicle: vehicle)
                            }
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                    }
                    .id(refreshID)
                }
            }
            .tabItem {
                Label("Đội xe", systemImage: "car.2.fill")
            }

            // MARK: - TAB 2: THUÊ & TRẢ XE (FR3, FR4, FR5)
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    ScreenHeaderView(title: "Thuê & Trả Xe", subtitle: "Rental Operations")

                    Form {
                        Section(header: Text("Tạo giao dịch mới")
                            .font(.caption.bold())
                            .foregroundColor(.driftCyan)) {
                            Picker("Khách hàng", selection: $selectedCustomerId) {
                                ForEach(system.allCustomers, id: \.id) { cust in
                                    Text("\(cust.name) (\(cust.id))").tag(cust.id)
                                }
                            }

                            Picker("Phương tiện", selection: $selectedVehicleId) {
                                ForEach(system.allVehicles, id: \.id) { v in
                                    Text("[\(v.id)] \(v.brand) \(v.model)").tag(v.id)
                                }
                            }

                            DatePicker("Ngày nhận xe", selection: $rentalStartDate, displayedComponents: .date)
                                .tint(.driftPink)

                            Stepper("Thời hạn: \(rentalDays) ngày", value: $rentalDays, in: 0...30)

                            Button(action: handleRentVehicle) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "checkmark.seal.fill")
                                    Text("Xác Nhận Thuê Xe")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                            }
                            .listRowBackground(
                                LinearGradient(colors: [.driftPurple, .driftPink], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                        }
                        .listRowBackground(Color.cardDarkBg)

                        Section(header: Text("Trạng thái thao tác")
                            .font(.caption.bold())
                            .foregroundColor(.driftCyan)) {
                            HStack(spacing: 10) {
                                Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                    .foregroundColor(isError ? .driftPink : .driftEmerald)
                                Text(statusMessage)
                                    .font(.subheadline)
                                    .foregroundColor(isError ? .driftPink : .white)
                            }
                        }
                        .listRowBackground(Color.cardDarkBg)

                        Section(header: Text("Danh sách hợp đồng (\(system.allRentals.count))")
                            .font(.caption.bold())
                            .foregroundColor(.driftCyan)) {
                            ForEach(system.allRentals, id: \.rentalId) { rental in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("\(rental.rentalId) • \(rental.vehicle.brand) \(rental.vehicle.model)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(rental.status == .active ? "Đang thuê" : "Đã trả")
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(rental.status == .active ? Color.driftAmber.opacity(0.22) : Color.white.opacity(0.12))
                                            .foregroundColor(rental.status == .active ? .driftAmber : .gray)
                                            .cornerRadius(6)
                                    }

                                    Text("Khách: \(rental.customer.name) • \(formatDate(rental.startDate)) → \(formatDate(rental.endDate)) (\(rental.durationDays) ngày)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.75))

                                    HStack {
                                        Text("Thành tiền: $\(String(format: "%.2f", rental.totalCost))")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.driftCyan)
                                        Spacer()
                                        if rental.status == .active {
                                            Button("Trả xe") {
                                                handleReturnVehicle(rentalId: rental.rentalId)
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.driftAmber)
                                            .foregroundColor(.black)
                                            .controlSize(.small)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listRowBackground(Color.cardDarkBg)
                    }
                    .scrollContentBackground(.hidden)
                    .id(refreshID)
                }
            }
            .tabItem {
                Label("Thuê xe", systemImage: "key.fill")
            }

            // MARK: - TAB 3: BÁO CÁO & THỐNG KÊ
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    ScreenHeaderView(title: "Báo Cáo & Thống Kê", subtitle: "Analytics & Revenue")

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // PHẦN 1: DOANH THU THEO THÁNG & LOẠI XE
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "chart.bar.xaxis")
                                        .foregroundColor(.driftPink)
                                    Text("Doanh Thu Theo Tháng")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }

                                HStack(spacing: 10) {
                                    Picker("Tháng", selection: $selectedMonth) {
                                        ForEach(1...12, id: \.self) { m in
                                            Text("Tháng \(m)").tag(m)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.driftCyan)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)

                                    Picker("Năm", selection: $selectedYear) {
                                        ForEach(2025...2027, id: \.self) { y in
                                            Text("Năm \(String(y))").tag(y)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.driftCyan)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)

                                    Spacer()
                                }

                                let report = system.getMonthlyRevenue(month: selectedMonth, year: selectedYear)

                                // Thẻ tổng doanh thu nổi bật
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TỔNG DOANH THU THÁNG \(selectedMonth)/\(String(selectedYear))")
                                            .font(.caption2.bold())
                                            .tracking(0.8)
                                            .foregroundColor(.white.opacity(0.85))
                                        Text("$\(String(format: "%.2f", report.totalRevenue))")
                                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 38))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding()
                                .background(
                                    LinearGradient(colors: [.driftPurple, .driftPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(14)

                                // Biểu đồ thanh ngang trực quan
                                RevenueBarRow(
                                    title: "Ô tô (Car)",
                                    icon: "car.fill",
                                    amount: report.carRevenue,
                                    total: report.totalRevenue,
                                    color: .driftCyan
                                )
                                RevenueBarRow(
                                    title: "Xe máy (Motorcycle)",
                                    icon: "bicycle",
                                    amount: report.motorcycleRevenue,
                                    total: report.totalRevenue,
                                    color: .driftAmber
                                )
                                RevenueBarRow(
                                    title: "Xe đạp điện (E-Bike)",
                                    icon: "bolt.car.fill",
                                    amount: report.eBikeRevenue,
                                    total: report.totalRevenue,
                                    color: .driftEmerald
                                )
                            }
                            .padding()
                            .background(Color.cardDarkBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .cornerRadius(16)
                            .padding(.horizontal, 16)

                            // PHẦN 2: TÌNH TRẠNG ĐỘI XE THEO NGÀY
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundColor(.driftEmerald)
                                    Text("Tình Trạng Đội Xe Theo Ngày")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }

                                DatePicker("Chọn ngày kiểm tra", selection: $filterDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .foregroundColor(.white)
                                    .tint(.driftPink)

                                let dailyStatuses = system.getDailyFleetStatus(for: filterDate)
                                let availableCount = dailyStatuses.filter { $0.isAvailableOnDate }.count
                                let rentedCount = dailyStatuses.count - availableCount

                                HStack(spacing: 10) {
                                    HStack(spacing: 6) {
                                        Circle().fill(Color.driftEmerald).frame(width: 8, height: 8)
                                        Text("Xe trống: \(availableCount)")
                                            .font(.caption.bold())
                                            .foregroundColor(.driftEmerald)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.driftEmerald.opacity(0.15))
                                    .cornerRadius(8)

                                    HStack(spacing: 6) {
                                        Circle().fill(Color.driftAmber).frame(width: 8, height: 8)
                                        Text("Đang thuê: \(rentedCount)")
                                            .font(.caption.bold())
                                            .foregroundColor(.driftAmber)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.driftAmber.opacity(0.15))
                                    .cornerRadius(8)

                                    Spacer()
                                }

                                Divider().background(Color.white.opacity(0.2))

                                ForEach(dailyStatuses) { item in
                                    HStack(spacing: 12) {
                                        Image(systemName: vehicleIcon(for: item.vehicle))
                                            .font(.title3)
                                            .foregroundColor(item.isAvailableOnDate ? .driftEmerald : .driftAmber)
                                            .frame(width: 30)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("[\(item.vehicle.id)] \(item.vehicle.brand) \(item.vehicle.model)")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.white)
                                            if let rental = item.activeRental {
                                                Text("Khách: \(rental.customer.name) • Trả ngày \(formatDate(rental.endDate))")
                                                    .font(.caption)
                                                    .foregroundColor(.driftAmber)
                                            } else {
                                                Text("Sẵn sàng đón khách")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.65))
                                            }
                                        }

                                        Spacer()

                                        Text(item.isAvailableOnDate ? "Trống" : "Bận")
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(item.isAvailableOnDate ? Color.driftEmerald.opacity(0.2) : Color.driftAmber.opacity(0.2))
                                            .foregroundColor(item.isAvailableOnDate ? .driftEmerald : .driftAmber)
                                            .cornerRadius(8)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding()
                            .background(Color.cardDarkBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                    }
                    .id(refreshID)
                }
            }
            .tabItem {
                Label("Thống kê", systemImage: "chart.bar.fill")
            }

            // MARK: - TAB 4: KHÁCH HÀNG (FR2)
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    ScreenHeaderView(title: "Khách Hàng", subtitle: "Customer Directory")

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(system.allCustomers, id: \.id) { customer in
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(colors: [.driftPurple.opacity(0.45), .driftPink.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                            .frame(width: 50, height: 50)
                                        Text(String(customer.name.prefix(1)))
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("[\(customer.id)] \(customer.name)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)

                                        HStack(spacing: 12) {
                                            Label(customer.phone, systemImage: "phone.fill")
                                            Label(customer.email, systemImage: "envelope.fill")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.75))
                                        .lineLimit(1)

                                        Text("Lịch sử thuê: \(customer.rentalHistory.count) chuyến")
                                            .font(.caption.bold())
                                            .foregroundColor(.driftCyan)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(Color.cardDarkBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                                .cornerRadius(14)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                    }
                    .id(refreshID)
                }
            }
            .tabItem {
                Label("Khách hàng", systemImage: "person.2.fill")
            }
        }
        .tint(.driftPink)
        .preferredColorScheme(.dark) // Đồng bộ giao diện tối với ảnh nền Car1
        .onAppear(perform: loadRichSampleData)
    }

    // MARK: - Nạp dữ liệu mẫu phong phú
    private func loadRichSampleData() {
        guard system.allVehicles.isEmpty else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        do {
            try system.addVehicle(Car(id: "V01", brand: "Toyota", model: "Camry 2.5Q", dailyRate: 65.0, seatingCapacity: 5, insuranceAndCleaningFee: 25.0))
            try system.addVehicle(Car(id: "V02", brand: "Ford", model: "Explorer", dailyRate: 90.0, seatingCapacity: 7, insuranceAndCleaningFee: 35.0))
            try system.addVehicle(Car(id: "V03", brand: "Mazda", model: "CX-5", dailyRate: 70.0, seatingCapacity: 5, insuranceAndCleaningFee: 25.0))
            try system.addVehicle(Motorcycle(id: "V04", brand: "Yamaha", model: "MT-03", dailyRate: 35.0, engineCC: 321))
            try system.addVehicle(Motorcycle(id: "V05", brand: "BMW", model: "R1250GS", dailyRate: 75.0, engineCC: 1254))
            try system.addVehicle(Motorcycle(id: "V06", brand: "Honda", model: "AirBlade 160", dailyRate: 18.0, engineCC: 160))
            try system.addVehicle(ElectricBicycle(id: "V07", brand: "Specialized", model: "Turbo Vado", dailyRate: 22.0, batteryRangeKm: 110, batteryFeePerDay: 4.0))
            try system.addVehicle(ElectricBicycle(id: "V08", brand: "VinFast", model: "DrgnFly", dailyRate: 18.0, batteryRangeKm: 95, batteryFeePerDay: 3.5))
            try system.addVehicle(ElectricBicycle(id: "V09", brand: "Giant", model: "Explore E+", dailyRate: 25.0, batteryRangeKm: 130, batteryFeePerDay: 4.5))

            try system.registerCustomer(Customer(id: "C01", name: "Nguyễn Minh Anh", phone: "0901-234-567", email: "minhanh@gmail.com"))
            try system.registerCustomer(Customer(id: "C02", name: "Trần Hoàng Nam", phone: "0912-345-678", email: "hoangnam@gmail.com"))
            try system.registerCustomer(Customer(id: "C03", name: "Lê Thu Thảo", phone: "0987-654-321", email: "thuthao@gmail.com"))
            try system.registerCustomer(Customer(id: "C04", name: "Phạm Quốc Bảo", phone: "0933-112-233", email: "quocbao@gmail.com"))
            try system.registerCustomer(Customer(id: "C05", name: "Vũ Hải Yến", phone: "0977-889-900", email: "haiyen@gmail.com"))

            try system.rentVehicle(customerId: "C01", vehicleId: "V01", days: 4, startDate: today)
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
                try system.rentVehicle(customerId: "C02", vehicleId: "V04", days: 3, startDate: yesterday)
            }
            if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) {
                try system.rentVehicle(customerId: "C03", vehicleId: "V07", days: 5, startDate: twoDaysAgo)
            }
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
                try system.rentVehicle(customerId: "C04", vehicleId: "V02", days: 3, startDate: tomorrow)
            }

            if let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: today) {
                let r1 = try system.rentVehicle(customerId: "C05", vehicleId: "V03", days: 3, startDate: tenDaysAgo)
                try system.returnVehicle(rentalId: r1.rentalId)

                let r2 = try system.rentVehicle(customerId: "C01", vehicleId: "V05", days: 2, startDate: tenDaysAgo)
                try system.returnVehicle(rentalId: r2.rentalId)
            }

            if let lastMonth = calendar.date(byAdding: .month, value: -1, to: today) {
                let r3 = try system.rentVehicle(customerId: "C02", vehicleId: "V02", days: 4, startDate: lastMonth)
                try system.returnVehicle(rentalId: r3.rentalId)

                let r4 = try system.rentVehicle(customerId: "C03", vehicleId: "V06", days: 5, startDate: lastMonth)
                try system.returnVehicle(rentalId: r4.rentalId)

                let r5 = try system.rentVehicle(customerId: "C04", vehicleId: "V08", days: 6, startDate: lastMonth)
                try system.returnVehicle(rentalId: r5.rentalId)
            }

            if let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: today) {
                let r6 = try system.rentVehicle(customerId: "C05", vehicleId: "V01", days: 5, startDate: twoMonthsAgo)
                try system.returnVehicle(rentalId: r6.rentalId)

                let r7 = try system.rentVehicle(customerId: "C01", vehicleId: "V09", days: 4, startDate: twoMonthsAgo)
                try system.returnVehicle(rentalId: r7.rentalId)
            }

            refreshID = UUID()
        } catch {
            statusMessage = "\(error)"
            isError = true
        }
    }

    // MARK: - Actions
    private func handleRentVehicle() {
        do {
            let rental = try system.rentVehicle(customerId: selectedCustomerId, vehicleId: selectedVehicleId, days: rentalDays, startDate: rentalStartDate)
            statusMessage = "Thuê thành công \(rental.rentalId)! Tổng: $\(String(format: "%.2f", rental.totalCost))"
            isError = false
            refreshID = UUID()
        } catch {
            statusMessage = "\(error)"
            isError = true
        }
    }

    private func handleReturnVehicle(rentalId: String) {
        do {
            try system.returnVehicle(rentalId: rentalId)
            statusMessage = "Đã hoàn tất trả xe cho hợp đồng \(rentalId)."
            isError = false
            refreshID = UUID()
        } catch {
            statusMessage = "\(error)"
            isError = true
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    private func vehicleIcon(for vehicle: Vehicle) -> String {
        if vehicle is Car { return "car.fill" }
        if vehicle is Motorcycle { return "bicycle" }
        return "bolt.car.fill"
    }
}

// MARK: - Các Component Giao Diện Phụ Trợ
struct SummaryBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.cardDarkBg)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct VehicleCardView: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 52, height: 52)
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("[\(vehicle.id)] \(vehicle.brand) \(vehicle.model)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text(vehicle.isAvailable ? "Sẵn sàng" : "Đang thuê")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(vehicle.isAvailable ? Color.driftEmerald.opacity(0.22) : Color.driftPink.opacity(0.22))
                        .foregroundColor(vehicle.isAvailable ? .driftEmerald : .driftPink)
                        .cornerRadius(6)
                }

                Text(specDescription)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))

                Text("Đơn giá: $\(String(format: "%.2f", vehicle.dailyRate))/ngày")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.driftCyan)
            }
        }
        .padding()
        .background(Color.cardDarkBg)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }

    private var iconName: String {
        if vehicle is Car { return "car.fill" }
        if vehicle is Motorcycle { return "bicycle" }
        return "bolt.car.fill"
    }

    private var iconColor: Color {
        if vehicle is Car { return .driftCyan }
        if vehicle is Motorcycle { return .driftAmber }
        return .driftEmerald
    }

    private var specDescription: String {
        if let car = vehicle as? Car {
            return "Ô tô • \(car.seatingCapacity) chỗ • Phí dịch vụ: $\(String(format: "%.0f", car.insuranceAndCleaningFee))"
        } else if let moto = vehicle as? Motorcycle {
            return "Xe máy • \(moto.engineCC)cc (\(moto.category.rawValue))"
        } else if let ebike = vehicle as? ElectricBicycle {
            return "Xe đạp điện • Pin \(ebike.batteryRangeKm)km • Phí pin: $\(String(format: "%.2f", ebike.batteryMaintenanceFeePerDay))/ngày"
        }
        return ""
    }
}

struct RevenueBarRow: View {
    let title: String
    let icon: String
    let amount: Double
    let total: Double
    let color: Color

    var percentage: Double {
        guard total > 0 else { return 0 }
        return amount / total
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Spacer()
                Text("$\(String(format: "%.2f", amount)) (\(Int(percentage * 100))%)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: max(0, geo.size.width * CGFloat(percentage)), height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}
