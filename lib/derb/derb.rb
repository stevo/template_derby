module ActionView
  module TemplateHandlers
    class DERB < ERB

      def compile(template)
        template_source = ::DERB::DerbPreprocessor.preprocess(template.source)
        src = ::ERB.new("<% __in_erb_template=true %>#{template_source}", nil, erb_trim_mode, '@output_buffer').src
        # Ruby 1.9 prepends an encoding to the source. However this is
        # useless because you can only set an encoding on the first line
        RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src
      end

    end

  end

end