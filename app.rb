require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/config_file'
require './db/models'
require 'twilio-ruby'
require 'pry'
require 'rufus/scheduler'

config_file 'config.yml'
set :database, 'sqlite:///whatareyoudoing.db'

scheduler = Rufus::Scheduler.start_new
twilio_client = Twilio::REST::Client.new settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN

get '/' do
  erb :index
end

get '/signup' do
  phone_number = params[:phone_number]
  twilio_client.account.sms.messages.create(:from => settings.TWILIO_NUMBER, :to => phone_number, :body => "Please reply with 'start' to start tracking your life.")
end

post '/sms' do
  from = params[:From]
  body = params[:Body]
  if body.downcase == 'start'
    scheduler.every '1m', :tags => from do
      twilio_client.account.sms.messages.create(:from => settings.TWILIO_NUMBER, :to => from, :body => "What are you doing?")                                              
    end
  elsif body.downcase == 'stop'
    puts "STOPPING NOW FOR #{from}"
    scheduler.find_by_tag(from).each do |job|
      job.unschedule
    end
  elsif body.downcase == 'download'
    puts "DOWNLOAD LINK"
  else
    Doing.create(:phone_number => from, :thing => body)
  end
end
