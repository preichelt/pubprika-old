class ArPgJson
  def self.wrap(query, key = "objects", parsed = false)
    results = ActiveRecord::Base.connection.execute(
      "SELECT json_agg(query_results) as #{key}
        FROM (
          #{query.to_sql}
        ) query_results"
    ).first
    if parsed
      parsed_results = {}
      parsed_results[key] = JSON.parse(results[key])
      results = parsed_results
    end
    results
  end

  def self.wrap_find(query, key = "objects")
    results = self.wrap(query, key)[key]
    results[1..-1][0..-2] if results
  end
end
