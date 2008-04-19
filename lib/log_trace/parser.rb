module LogTrace
  module Parser
    def self.parse_log(environment = ENV['RAILS_ENV'], log_file = nil)
      if !environment.nil? && !log_file.nil? then raise "Cannot pass an environment and a log file." end
      
      log_file ||= RAILS_ROOT + '/log/' + environment + '.log'
      File.exists?(log_file) ? log = File.read(log_file) : \
        (raise "Log file not found.")
      
      regular_expression = /Processing (.+?)#(.+?) \(for (.+?) at (.+?) (.+?)\) \[(.+?)\]\n  Session ID: .*\n  Parameters: (.+?)\n/
      matches = log.scan(regular_expression)
      results = matches.map do |match|
          {
            :controller => match[0].match(/(.+?)Controller/)[1],
            :action => match[1],
            :ip => match[2],
            :datetime => Time.parse(match[3] + " " + match[4]),
            :method => match[5],
            :parameters => match[6]
          }
        end
      
      results
    end
    
    def self.method_missing(method, *args)
      if (match = method.to_s.match(/parse_log_and_return_by_(\w+)/)) && %w{controller action ip date time datetime method}.include?(match[1])
        self.parse_log_and_return_by(match[1])
      else
        super
      end
    end
    
    def self.parse_log_and_return_by(key)
      results, ordered = self.parse_log, {}
      results.each do |result|
        ordered[result[key.to_sym]] ||= []
        ordered[result[key.to_sym]] << result
      end
      
      ordered
    end
  end
end