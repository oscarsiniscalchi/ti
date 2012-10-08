if ENV['TIMELOG']
  require 'net/http'
  require 'json'
  timer = Ti::Timer

  module Ti
    class  << Timer

      def post_time (user, pass, options = {})

        puts "Uploading..."

        postdata = {
          project:         options[:project] || self.client,
          description:     self.task,
          minutes:      self.minutes,
          user_auth_email: user,
          user_auth_pass:  pass
        }

        uri = URI('http://nr-tt.herokuapp.com/api/tracktime')
        res = Net::HTTP.post_form(uri, postdata )
      end

    end
  end

  timer.on :finish do
    puts "Do you want to submmit your working hours to NeonTracker now? | Y/n"
    answer = STDIN.gets.chomp
    if answer == 'Y'

      puts "Enter your username:"
      user = STDIN.gets.chomp
      puts "Password: "
      pass = STDIN.gets.chomp

      errors = true
      options = {}
      while errors do
        res = timer.post_time(user, pass, options)

        errors = false

       if res.body[:response] == "success"
         puts res.body[:message].color(:green)
         errors = false
       else
         errors = true
         puts res.body[:message].color(:red)

         case res.body[:error_type]
         when "invalid_project"
           puts "Choose one of this projects"
           puts res.body[:options]
           project = STDIN.gets.chomp
           options[:project] = project

         when "invalid_user"
           puts "Invalid username or password, try again"
         end
       end
      end

    end
  end
end
