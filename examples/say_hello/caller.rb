$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'rabbitmq_procedure_call'

say_hello = RabbitmqProcedureCall::Caller.new(:say_hello)
response = say_hello.call(name: 'Foo', _timeout: 4)
puts "-> #{response['msg']}"
