class DerbTemplateString < String
  YIELDING_TAG_REGEX = /<[a-zA-Z0-9\-]+:\/>/i #ex. <column-mc:/>
  INJECTION_START_TAG_REGEX = /<[a-zA-Z0-9\-]+:>/i #ex. <column-mc:>
  INJECTION_END_TAG_REGEX = /<\/[a-zA-Z0-9\-]+:>/i #ex. </column-mc:>
  TAG_RESTRICTED_CHARS = /[<:>\\\/]/

  #========= Errors ===========

  class TagNotClosed < StandardError;
  end
  class TagNotDefined < StandardError;
  end

  #==============================


  def sub_paired_tags!(arr, &block)
    processing_stack = Array.new
    arr.each do |paired_tag|
      if paired_tag.is_closing_tag?
        #if opening matches closing
        if (opening_tag = processing_stack.pop).tag_name == paired_tag.tag_name
          block.call(opening_tag, paired_tag)
        else
          raise DerbTemplateString::TagNotClosed, "Opened tag has not been properly closed -> missing closing tag for #{opening_tag}. Got #{paired_tag} instead!"
        end
      elsif paired_tag.is_closed_tag?
        block.call(paired_tag, paired_tag)
      else
        processing_stack.push(paired_tag)
      end
    end
    raise DerbTemplateString::TagNotClosed, "Opened tag has not been properly closed -> missing closing tag for #{processing_stack.pop}!" unless processing_stack.empty?
  end


  def sub_custom_tags!
    sub_paired_tags!(scan(DerbCustomTag.regex).map(&:first)) do |opening_tag, closing_tag|
      if opening_tag == closing_tag #if tag is content-less
        sub!(opening_tag, opening_tag.tag_translation + closing_translation)
      else
        sub!(opening_tag, opening_tag.tag_translation)
        sub!(closing_tag, closing_translation)
      end
    end
  end

  def sub_injection_tags!
    sub_paired_tags!(scan(/(#{INJECTION_START_TAG_REGEX}|#{INJECTION_END_TAG_REGEX})/).flatten) do |opening_tag, closing_tag|
      sub!(opening_tag, opening_tag.injection_translation)
      sub!(closing_tag, closing_translation)
    end
  end

  def sub_yielding_tags!
    scan(YIELDING_TAG_REGEX).each do |yielding_tag|
      gsub!(yielding_tag, yielding_tag.yielding_translation)
    end
  end

  protected

  def normalize
    gsub("-", "_")
  end

  def normalized_tag_name
    tag_name.normalize
  end

  def tag_name
    match(/([a-zA-Z0-9\-_]+)/i).to_s
  end

  def tag_attrs
    unless (pairs = gsub(/(<|>)/, '').scan(/[a-z]+=["'][^'"]+["']/i)).blank?
      ',' + pairs.map do |pair|
        key, val = pair.split('=');
        %{"#{key}" => #{val}}
      end.join(', ')
    end
  end

  #closing tag's second character is always /  (as in "</div>")
  def is_closing_tag?
    strip[1, 1] == '/'
  end

  def is_closed_tag?
    strip[-2..-1] == '/>'
  end

#========= Translations ===========
  def tag_translation
    %{<%- call_tag('#{tag_name}' #{tag_attrs}) do -%>}
  end

  def yielding_translation
    %{<%= yield :#{normalized_tag_name} -%>}
  end

  def injection_translation
    %{<%- content_for :#{normalized_tag_name} do -%>}
  end

  def closing_translation
    "<%- end -%>"
  end

end