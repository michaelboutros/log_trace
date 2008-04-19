module LogTrace
  module Controller 
    def authenticate
      true
    end
     
    def index
      authenticate
      
      ips, @results = Parser.parse_log_and_return_by_ip, {}
      
      ips.each do |ip, hits|
        last_visit = hits.inject do |last, current|
         last[:datetime] > current[:datetime] ? last : current
        end
        
        last_visit_actions = hits.find_all do |hit|
          (last_visit[:datetime] - hit[:datetime]) < 1.hour
        end
        
        @results[ip] = {:last_visit => last_visit, :last_visit_actions => last_visit_actions.compact.size}
      end
    end
  
    def show
      authenticate
      
      if params[:id].blank?
        flash[:error_message] = 'Please provide an IP address.' 
        return redirect_to :action => 'index'
      end 
           
      @ip = params[:id].gsub(/-/, '.')
      
      entries = Parser.parse_log      
      visits = entries.find_all {|e| e[:ip] == @ip}.reverse
      if visits.empty?
        flash[:error_message] = 'Please provide a valid IP address.'
        return redirect_to :action => 'index'
      end
      
      @blocks, key, previous = [], 0, visits.shift
      
      visits.each do |current|      
        if (previous[:datetime] - current[:datetime]) < 10.minutes.to_i
          if @blocks[key].nil? then @blocks[key] = [] end
          @blocks[key] << current
        else
          key += 1 and @blocks[key] = []
          @blocks[key] << current
        end
        
        previous = current
      end
    end
    
    private
      def render(options = {})
        options.merge!({
          :file => RAILS_ROOT + '/vendor/plugins/log_trace/lib/views/controller/' + self.action_name + '.html.erb',   
          :layout => '../../vendor/plugins/log_trace/lib/views/layouts/log_trace.html.erb'})
        
        super options
      end
  end
end