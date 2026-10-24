import Foundation

/// Точка интеграции реального USB CCID / CryptoTokenKit / vendor SDK.
/// Здесь намеренно нет фиктивного чтения карты: статус меняется только
/// после реализации и тестирования реального протокола.
final class CardReaderService {
    enum ReaderError: LocalizedError {
        case notImplemented
        var errorDescription: String? {
            switch self {
            case .notImplemented:
                return "Считыватель пока не подключён к приложению. Нужны модель устройства и совместимый iOS API/SDK."
            }
        }
    }

    func discoverReaders() async throws -> [String] {
        throw ReaderError.notImplemented
    }

    func readDriverCard() async throws -> URL {
        throw ReaderError.notImplemented
    }
}
