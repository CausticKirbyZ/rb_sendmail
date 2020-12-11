#!/usr/bin/ruby
# ruby AIO email script tool

require 'mail'
require 'optparse'

options = {}

# default settins
options[:authentication] = 'login'
options[:port] = 587
options[:autostarttls] = true
options[:password] = ""
options[:username] = ""
options[:enable_starttls] = true
options[:enable_starttls_auto] = true
options[:attachments] = []
options[:emaildomain] = ""
options[:text_message] = nil
options[:html_message] = nil
options[:headers] = []

OptionParser.new do |opts|
    opts.banner = "Usage: rb_sendmail.rb [options]"

    opts.on("-s", "--subject [Sub]", String) do |s|
        options[:subject] = s
    end

    opts.on("-b", "--body [BODY]") do |b|
        options[:text_message] = b
        # options[:html_message] = b
    end

    opts.on("-f", "--send-from [fromaddr]",String) do |f|
        options[:from] = f
    end

    opts.on("-t", "--send-to [address]", String) do |b|
        options[:to] = b
    end

    opts.on("-T", "--autostarttls") do |tls|
        options[:autostarttls] = true
    end

    opts.on("-A", "--Authentication [auth]",String, "Authentication method") do |auth|
        options[:authentication] = auth
    end

    opts.on("-u", "--username [username]", String) do |username|
        options[:username] = username
    end

    opts.on("-p", "--password [password]", String) do |pass|
        options[:password] = pass
    end

    opts.on("-P", "--Port [portnum]", Integer) do |port|
        options[:port] = port
    end

    opts.on("-m", "--mailserver [mailserver]", String, "The mail server") do |ms|
        options[:mailserver] = ms
    end

    opts.on("-D", "--domain [domainname]",String, "local server domain. default is '' ") do |domain|
        options[:emaildomain] = domain
    end

    opts.on("-H", "--headers [header]",String, "added header format= header:val") do |header|
        puts header.split(':')
        options[:headers] << header.split(':')
    end

    opts.on("--html-message [message]") do |h|
        options[:html_message] = h
    end

    opts.on("--text-message [message]") do |t|
        options[:text_message] = t
    end

    opts.on("-a", "--attachments [attachments]", String, "Comma seperated list of files to attach") do |a|
        options[:attachments] = a.split(',')
        options[:attachments].each { |a| a.strip! }
    end

end.parse!

puts options
# exit


if( options == nil || options[:to] == "" || options[:subject] == "" || options[:from] == "")
    puts "Usage: rb_sendmail [options]"
    exit
end

if options[:password] == nil || options[:password] == ""
    puts "Enter Password: "
    options[:password] = gets.chomp
end

Mail.defaults do
  delivery_method :smtp, {
                         :address              => options[:mailserver],
                         :port                 => options[:port].to_i,
                         :user_name            => options[:username],
                         :password             => options[:password],
                         :domain               => options[:emaildomain],
                         :authentication       => options[:authentication],
                         :enable_starttls      => options[:enable_starttls],
                         :enable_starttls_auto => options[:enable_starttls_auto],
                         :autostarttls         => options[:autostarttls],
                         #:openssl_verify_mode  => "none"
                         }
end

Mail.deliver do
    to options[:to]
    from options[:from]
    subject options[:subject]


#    header[options[:headers][0][0] ] = options[:headers][0][1]

  if options[:text_message] != nil
    text_part do
      body options[:text_message]
    end
  end

  if options[:html_message] != nil
    html_part do
      content_type 'text/html; charset=UTF-8'
      body options[:html_message]
    end
  end

    if options[:attachments].length > 0
        options[:attachments].each do |a|
            add_file a
        end
    end
end