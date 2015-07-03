require "dipsclient/version"
require 'rubygems'
require 'websocket-client-simple'
require 'json'
require 'securerandom'

module DiPS

	class DiPSClient

		def initialize serverUrl
			$dipsSubscriptions = Hash.new
			@clientId = SecureRandom.uuid
			@diPSservice = "#{serverUrl}/?clientid=#{@clientId}" #We send the clientid to the server
			@ws = WebSocket::Client::Simple.connect @diPSservice, {
								  :proxy => {
								    :origin  => 'http://console.org',
								    :headers => {'User-Agent' => 'ruby'}
								  }
								}
			#Process check if we have a scubscription for that event
			#if so, launch the proper callback
			@ws.on :message do |msg|
				begin
					#Parse the message as an object
					event = JSON.parse(msg.data)
					 eName = event["EventName"]
					if !$dipsSubscriptions[eName].nil?
						$dipsSubscriptions[eName].call(event["PayLoad"])
					end				
				rescue Exception => e
					#p e
				end			
			end

			@ws.on :open do
		 		#do nothing
			end

			@ws.on :close do |e|
		 		#do nothing		 
			end

			@ws.on :error do |e|
			  p e
			end
		end
		
		def Disconnect
			@ws.close
		end	

		#Subscribe to some event, a callback is executed when the event occurs
		def Subscribe eventName, &callback
			if $dipsSubscriptions[eventName].nil?
				$dipsSubscriptions[eventName] = callback	
				#send the subscription to the server
				event = { "EventName" => eventName , "ClientId" => @clientId, "MessageType" => "subscribe" }
				msg = JSON.generate(event)

				#send the event
				@ws.send msg
			else
				raise "You can only have one subscription to an event"
			end
		end

		#unscubscribe from some event
		def Unsubscribe eventName
			if !$dipsSubscriptions[eventName].nil?
				$dipsSubscriptions.delete(eventName)
				#send the unsubscription to the server
				event = { "EventName" => eventName , "ClientId" => @clientId, "MessageType" => "unsubscribe" }
				#send the event
				@ws.send JSON.generate(event)
			else
				raise "You are not subscribed to that event"
			end
		end

		#publish and event and send some parameter to the subscribers
		def Publish eventName, eventParameter
			#create the event
			parameter = JSON.generate(eventParameter)
			event = { "EventName" => eventName , "ClientId" => @clientId, "MessageType" => "publish", "EventParameter" => parameter	}
			#send the event
			@ws.send JSON.generate(event)
		end

		
	end
end