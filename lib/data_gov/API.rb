module DataGov
  class API
    ##
    # @return [Enumerator]
    def search(params = {})
      client.paginated_get('/api/3/action/package_search', 'results', params)
    end

    def client
      @client ||= DataGov::Client.new
    end
  end
end
