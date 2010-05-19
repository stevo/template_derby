module DERB
  module DerbPreprocessor
    def self.preprocess(template_source)
      template = DerbTemplateString.new template_source

      #Sub all custom tag with call_tag helper (i.e. <wow> to <% call_tag('wow') do %>)
      template.sub_custom_tags!

      #Change all yielding tags (i.e. <column-mc:/>) to proper yields
      template.sub_yielding_tags!

      #Change all injection tags to proper content_for declarations
      template.sub_injection_tags!

      template.to_s
    end
  end
end