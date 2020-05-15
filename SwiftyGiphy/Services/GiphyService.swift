import Foundation

// 2 новых строки подряд и более - это многовато, одной вполне достаточно
protocol GiphyService {
    func getTrends(offset: Int, completion: @escaping (Result<[GifData], Error>) -> Void)
    func search(query: String, offset: Int, completion: @escaping (Result<[GifData], Error>) -> Void)
}


final class GiphyServiceImpl {
    enum QueryType {
        case trending
        case search(query: String)
    }
    
    private let api: API
    private let objectsLimit = Constants.queryDataLimit
    
    init(api: API) {
        self.api = api
    }

  // объявление методов должно следовать в порядке их вызова
    private func getQueryData(for type: QueryType) -> QueryData {
        switch type {
        case .trending:
            return QueryData(parameters: ["limit": objectsLimit], path: "/trending")
        case .search(let query):
            return QueryData(parameters: ["q": "\(query)", "limit": objectsLimit], path: "/search")
        }
    }
    
    private func getGifs(type: QueryType, offset: Int, completion: @escaping (Result<[GifData], Error>) -> Void) {
        let queryData = getQueryData(for: type)
        var parameters = queryData.parameters
        parameters["offset"] = offset
        
        api.get(path: queryData.path, parameters: parameters) { result in
            completion(
                result.flatMap { data in
                    do {
                      // сервис не должен заниматься кодированием/декодированием данных. для этого есть API
                      // тем более, что при добавлении новых сервисов, этот код будет копироваться
                        let dataResponse = try JSONDecoder().decode(DataResponse<GifData>.self, from: data)
                        
                        guard dataResponse.meta?.status == 200 else {
                            print("ERROR",
                                  "status:",
                                  dataResponse.meta?.status ?? "unknown",
                                  "message:",
                                  dataResponse.meta?.msg ?? "unknown")
                            return .failure(NetworkingError.default)
                        }
                      // cервис что-то знает про свое окружение?
                      // лучше вообще не использовать неявные знания,
                      // а все, что требуется сущности, передавать как параметры в конструкторе
                        if ProcessInfo.processInfo.environment["UI_TESTS"] != nil {
                            return .failure(NetworkingError.default)
                        } else {
                            return .success(dataResponse.data)
                        }
                    } catch {
                        print(error.localizedDescription)
                        return .failure(error)
                    }
                }.mapError { _ in return CommonError.default }
            )
        }
    }
}

// было бы логичнее сразу объявить GiphyServiceImpl: GiphyService
extension GiphyServiceImpl: GiphyService {
    func getTrends(offset: Int, completion: @escaping (Result<[GifData], Error>) -> Void) {
        getGifs(type: .trending, offset: offset, completion: completion)
    }
    
    func search(query: String, offset: Int, completion: @escaping (Result<[GifData], Error>) -> Void) {
        getGifs(type: .search(query: query), offset: offset, completion: completion)
    }
}
