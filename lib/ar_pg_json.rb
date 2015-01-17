class ArPgJson
  def self.wrap(query, key = "objects")
    ActiveRecord::Base.connection.execute(
      "SELECT json_agg(query_results) as #{key}
        FROM (
          #{query.to_sql}
        ) query_results"
    ).first
  end

  def self.wrap_find(query, key = "objects")
    results = self.wrap(query, key)[key]
    results[1..-1][0..-2] if results
  end

  def self.wrap_array(query, key = "objects")
    ActiveRecord::Base.connection.execute(
      "SELECT to_json(array(#{query.to_sql})) as #{key}"
    ).first
  end

  def self.package(objs)
    json = ""
    objs.each do |obj|
      key = obj.keys.first
      if json == ""
        if obj[key].nil?
          json = "\"#{key}\":null"
        else
          json = "\"#{key}\":#{obj[key]}"
        end
      else
        if obj[key].nil?
          json = "#{json},\"#{key}\":null"
        else
          json = "#{json},\"#{key}\":#{obj[key]}"
        end
      end
    end
    "{#{json}}"
  end
end
