module Lbuilder
  module LayoutEngine
    def self.included(base)
      base.extend(ClassMethods)
    end

    def tab
      self.class.get_tab
    end

    def subtab
      self.class.get_subtab || action_name
    end

    def set_subtab(tab)
      self.class.set_subtab(tab)
    end

    def set_tab(tab)
      self.class.set_tab(tab)      
    end

    module ClassMethods
      @tab = nil
      @subtab = nil

      def set_tab(tab)
        @tab = tab
      end

      def set_subtab(tab)
        @subtab = tab
      end

      def get_tab
        @tab || @tab = controller_name
      end

      def get_subtab
        @subtab
      end

    end
  end
end