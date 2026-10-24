import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingImporter = false
    @State private var importedFileName: String?
    @State private var readerStatus = "Считыватель не подключён"
    @State private var cardStatus = "Карта не вставлена"
    @State private var uploadStatus = "Файл не загружен"
    @State private var showReaderInfo = false
    @State private var reportMessage = "Здесь появятся отчёты после импорта файла .ddd."

    private let navy = Color(red: 0.08, green: 0.12, blue: 0.23)
    private let panel = Color(red: 0.11, green: 0.16, blue: 0.29)
    private let accent = Color(red: 0.30, green: 0.43, blue: 0.88)

    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Group {
                    switch selectedTab {
                    case 0: downloadScreen
                    case 1: reportsScreen
                    case 2: deadlinesScreen
                    default: settingsScreen
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                bottomBar
            }
        }
        .preferredColorScheme(.dark)
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [UTType.data, UTType.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                importedFileName = url.lastPathComponent
                uploadStatus = "Файл импортирован"
                cardStatus = "Данные доступны из файла"
                reportMessage = "Импортирован файл: \(url.lastPathComponent)\nПроверка содержимого .ddd пока не реализована."
            case .failure(let error):
                uploadStatus = "Ошибка импорта: \(error.localizedDescription)"
            }
        }
        .alert("Подключение считывателя", isPresented: $showReaderInfo) {
            Button("Понятно", role: .cancel) { }
        } message: {
            Text("Автоматическое чтение карты пока не подключено. Нужны точная модель считывателя и совместимый iOS API/SDK. Сейчас можно импортировать ранее считанный файл .ddd.")
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "rectangle.stack.badge.person.crop")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Driver Card Reader")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                Text("Тахограф • карта водителя")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
            }
            Spacer()
            Image(systemName: "person.crop.circle")
                .font(.system(size: 27))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    private var downloadScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Загрузка")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    statusCard(title: "КАРТРИДЕР", value: readerStatus, symbol: "cable.connector")
                    statusCard(title: "КАРТА ВОДИТЕЛЯ", value: cardStatus, symbol: "person.text.rectangle")
                    statusCard(title: "СТАТУС ФАЙЛА", value: uploadStatus, symbol: "doc.badge.arrow.up")
                    Button {
                        showReaderInfo = true
                    } label: {
                        Label("Проверить считыватель", systemImage: "magnifyingglass")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(accent)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Импортировать файл .ddd", systemImage: "folder")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.10))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }
                    if let importedFileName {
                        Text("Выбран файл: \(importedFileName)")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
                .background(panel)
                .clipShape(RoundedRectangle(cornerRadius: 26))

                Text("Для чтения карты требуется совместимый считыватель. Не используйте демонстрационные статусы как подтверждение фактического чтения.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
    }

    private var reportsScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Отчёты").font(.largeTitle.bold()).foregroundStyle(.white)
                infoPanel(title: "Данные загрузки", text: reportMessage, icon: "chart.bar.xaxis")
                Text("Анализ режима труда и отдыха появится после реализации парсера файлов тахографа. Импорт файла сам по себе не подтверждает корректность данных.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.65))
            }
            .padding(18)
        }
    }

    private var deadlinesScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Сроки").font(.largeTitle.bold()).foregroundStyle(.white)
                infoPanel(title: "Следующая загрузка", text: "Срок пока не рассчитан — требуется прочитать данные карты и определить дату последней загрузки.", icon: "calendar")
                infoPanel(title: "Отдых и вождение", text: "Расчёт будет добавлен после проверки и реализации анализатора данных.", icon: "clock")
            }
            .padding(18)
        }
    }

    private var settingsScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Настройки").font(.largeTitle.bold()).foregroundStyle(.white)
                infoPanel(title: "Язык", text: "Русский", icon: "globe")
                infoPanel(title: "Хранение", text: "Вы выбираете файл для импорта. Отправка данных на сервер не реализована.", icon: "lock.shield")
                infoPanel(title: "Считыватель", text: "Подключение устройства будет добавлено после определения модели и проверки совместимости с iOS.", icon: "cable.connector")
            }
            .padding(18)
        }
    }

    private func statusCard(title: String, value: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color(red: 0.45, green: 0.68, blue: 1.0))
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.6))
                Text(value)
                    .font(.body)
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 4)
            Circle().fill(Color.gray).frame(width: 9, height: 9)
        }
        .padding(16)
        .background(Color.white.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func infoPanel(title: String, text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 23))
                .foregroundStyle(Color(red: 0.45, green: 0.68, blue: 1.0))
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.headline).foregroundStyle(.white)
                Text(text).font(.subheadline).foregroundStyle(.white.opacity(0.72))
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            tabButton("Загрузка", icon: "arrow.down.to.line", index: 0)
            tabButton("Отчёты", icon: "chart.bar.fill", index: 1)
            tabButton("Сроки", icon: "calendar", index: 2)
            tabButton("Настройки", icon: "slider.horizontal.3", index: 3)
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.black.opacity(0.24))
    }

    private func tabButton(_ title: String, icon: String, index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20, weight: .semibold))
                Text(title).font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(selectedTab == index ? Color.orange : .white.opacity(0.68))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(selectedTab == index ? Color.black.opacity(0.35) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
