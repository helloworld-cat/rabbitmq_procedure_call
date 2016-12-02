$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'rabbitmq_procedure_call'

say_hello = RabbitmqProcedureCall::Caller.new(:say_hello, timeout = 4)
response = say_hello.call(name: 'Foo')
puts "-> #{response['msg']}"
