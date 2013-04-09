module Campfiyah
  module Adapters
    class HTTP < Campfiyah::Adapters::Adapter
      def connection
        @connection ||= connection!
      end

      def connection!
        endpoint = "https://#{subdomain}.campfirenow.com"
        Faraday.new endpoint do |conn|
          conn.request  :json
          conn.response :json, :content_type => /\bjson$/

          conn.basic_auth token, 'X'
          conn.adapter Faraday.default_adapter
        end
      end

      def rooms
        rooms = [ ]
        response = connection.get("/rooms.json")
        if response.status == 200
          rooms = response.body["rooms"]
        end

        rooms.sort { |a,b| b['updated_at'] <=> a['updated_at'] }
      end

      def message(room_id, message)
        response = connection.post("/room/#{room_id}/speak.json") do |req|
          req.headers['Content-Type'] = 'application/json'
          req.body = %{{"message":{"body":#{quote(message)}}}}
        end
      end

      private

      def quote(string)
        if string.respond_to?(:to_json)
          string.to_json
        else
          string.inspect
        end
      end
    end
  end
end