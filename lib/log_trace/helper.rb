module LogTrace
  module Helper
    def title(title, content_title = nil)
      if content_title.nil? then content_title = title end
      
      content_for(:title) { title }
      content_for(:content_title) { content_title }
    end
    
    def last_visit_indicator(datetime)
      date = pretty_date(datetime)
      
      (Time.now - 15.minutes) > datetime ? tag_class = 'inactive_user' : tag_class = 'active_user'
      content_tag(:span, date, :class => tag_class)
    end
    
    def pretty_date(datetime)
      datetime.strftime("%B %d, %Y at %I:%M:%S %p")
    end
    
    def ip_link(ip)
      ip + sub_link("more", :action => 'show', :id => clean_ip(ip))
    end
    
    def sub_link(text, *link_params)
      link_to(content_tag(:span, text, :class => 'sub_link'), *link_params)
    end
    
    def clean_ip(ip)
      ip.gsub(/\./, '-')
    end

    def more_link(group)
      link_to_function "&darr;" do |page|
        page.hide "visit_#{group}"
        page.show "hits_#{group}"
      end
    end
    
    def less_link(group)
      link_to_function "&uarr;" do |page|
        page.show "visit_#{group}"
        page.hide "hits_#{group}"
      end
    end
  
    def show_time_span(last_visit)
      result = pretty_date(last_visit)
      result << " (" + distance_of_time_in_words(Time.now, last_visit) + ")"
      
      if (Time.now - 15.minutes) < last_visit 
        content_tag(:span, result, :class => 'active_user')
      elsif (Time.now - last_visit) <= 1.day
        result
      else
        content_tag(:span, result, :class => 'inactive_user')
      end
    end
  
    def show_difference_in_time(last, first)
      if (last - first) == 0.0 then return "00:00:01" end
      
      # thanks to the legendary manveru who was taught by shevy (mtodd's fault) in ruby-lang  
      seconds = last - first
      minutes, seconds = seconds.divmod(60)
      hours, minutes = minutes.divmod(60)
      
      [hours, minutes, seconds].collect {|i| i.round.to_s.rjust(2, '0') }.join(":")
    end
  
    def show_flash(name, container = nil, splitter = '|||', css_class = 'flash_' + name.to_s)
      if flash[name].blank? then return '' end

      result = [content_tag(:span, flash[name.to_sym], :class => css_class)]
  
      if container == nil
        return result
      else
        items = container.split(splitter)
        result.insert(0, items[0])
        result.push items[1]
        return result.join
      end
    end
  end
end