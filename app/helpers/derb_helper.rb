module DerbHelper

  def call_tag(tagname, *attrs, &block)
    begin
      content = capture(&block)

      if (tag_def = DerbCustomTag.all[tagname])
        #Get attributes for inline render
        options = attrs.extract_options!
        attributes = tag_def[:attrs].inject({}) do |attribs, attr|
          attribs.merge({attr => options[attr]})
        end.symbolize_keys

        #Store information about passed params
        params_present = content.scan(/(<param:[a-z]+>)/i).flatten.map{|p| p[7..-2]}
        attributes[:params_present]= params_present

        #Render custom tag
        new_content = render(:inline => process_tag(tag_def[:tag_template], parametrize_content(content, params_present)), :layout => false, :locals => attributes)
        concat(new_content)
      else
        raise DerbTemplateString::TagNotDefined, "Following tag has not been defined -> #{tag}"
      end
    rescue => exc
      #TODO Message breaks.... Damn - I mean it is repeated twice somehow ;)
      puts "Template exception \n ---------------- \n#{exc.message}\n ---------------- \n\n"
      puts %{ Problem occured during tag call! \n
              Tag: #{tagname}\n Attrs: #{attributes}\n
              All tags regex: #{DerbCustomTag.regex} \n
              Custom tag: #{DerbCustomTag.all[tagname]} \n\n
              ============================ \n}
      raise exc
    end
  end


  def derby_defaults(*args)
    args.include?(:fluid) ? stylesheet_link_tag("/rcss/tderby_fluid.css") : stylesheet_link_tag("/rcss/tderby.css")
  end

  private

  def process_tag(original_template, content_hash)
    template = original_template.clone
    content_hash.each do |param_name, content_sub|
      #template.gsub!("<param:#{param_name}/>", content_sub.gsub(/\\\&/o, '\\\\\&\2\1'))
      template.gsub!("<param:#{param_name}/>"){content_sub}
    end
    template.gsub!(/<param:[a-z]+\/>/i, "")
    template
  end

  def parametrize_content(content, params_present)
    if content =~ /<param:[a-z]+>/i
      return params_present.inject({}) do |acc, param_name|
        acc.merge({param_name.to_sym => content.match(/<param:#{param_name}>([\s\S<]*)<\/param:#{param_name}>/i)[1]})
      end
    else
      return {:content => content}
    end
  end

end