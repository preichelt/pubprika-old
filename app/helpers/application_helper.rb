module ApplicationHelper
  def title(value)
    unless value.nil?
      @title = "#{value} | Pubprika"      
    end
  end
end
