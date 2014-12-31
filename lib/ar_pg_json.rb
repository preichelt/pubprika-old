class ArPgJson
  def self.wrap(query, key = "objects")
    ActiveRecord::Base.connection.execute(
      "SELECT json_agg(query_results) as #{key}
        FROM (
          #{query.to_sql}
        ) query_results"
    ).first
  end
end
