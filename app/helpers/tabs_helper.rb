module TabsHelper

  def tab
    controller.tab
  end

  def subtab
    controller.subtab
  end

  def tab?(t)
    if  t.kind_of?(Array)
      return t.include?(tab)
    else
      return tab==t
    end
  end

  def subtab?(t)
    if t.kind_of?(Array)
      return t.include?(subtab)
    else
      return subtab==t
    end
  end

end